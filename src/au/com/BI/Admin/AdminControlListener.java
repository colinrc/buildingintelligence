/*
 * Created on Dec 28, 2003
 *
*/
package au.com.BI.Admin;

import java.io.*;
import java.util.logging.*;

import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.*;
import au.com.BI.Util.DeviceModel;

import java.util.*;
import java.net.*;

import org.jdom.*;

/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 * This thread listens for clients and establishes connections as they occur
 */
public class AdminControlListener extends Thread  
{
	
	protected ServerSocket iPPort;
	
	protected List <AdminClientHandler>adminControllers;
	protected int portNumber;
	protected String Address;
	protected InetAddress iPAddress;
	protected Logger logger;
	protected volatile boolean running;
	protected CommandQueue commandList;
	protected Document heartbeatDoc;
	protected boolean firstConnection = true;
	protected Level defaultDebugLevel;
	protected LogHandler sh = null;
	protected String logDir;
	protected AdminClientHandler currentAdminController = null;
	protected HashMap <String,DeviceModel>modelRegistry = null;
	protected Collection <DeviceModel> modelList;
	protected Date startupTime;
	protected String startupFile;
	protected au.com.BI.IR.Model irLearner;
	
	public AdminControlListener (List<AdminClientHandler> adminControllers, int portNumber, String address,CommandQueue commandList,Level defaultDebugLevel,
			HashMap <String,DeviceModel>modelRegistry, Date startupTime, String startupFile,String logDir, au.com.BI.IR.Model irLearner, LogHandler sh) 
		throws CommsFail
	{
		heartbeatDoc = new Document (new Element ("heartbeat"));
		
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.defaultDebugLevel = defaultDebugLevel;
		this.startupTime = startupTime;
		this.startupFile = startupFile;
		this.irLearner = irLearner;
		this.logDir = logDir;
		this.setName("Admin Control Listener");
		this.sh = sh;

		try {
			logger.fine("Listening for clients on port " + portNumber + " IP " + address);
			this.adminControllers = adminControllers;
			this.portNumber = portNumber;
			this.iPAddress = InetAddress.getByName (address);
			this.commandList = commandList;
			this.modelRegistry = modelRegistry;
		} catch (UnknownHostException uhe) {
			throw new CommsFail ("Cannot establish server for admin clients " + uhe.getMessage());
		}	
	}
	
	
	/**
	* Main thread. 
	* Sits in a continuous loop creating FlashClientHandler objects as required to 
	* to handle each admin client
	*/

	public void run ()
	{
		logger = Logger.getLogger(this.getClass().getPackage().getName());

		logger.fine("Openning port " + portNumber);
		running = true;
		
		try {
				//iPPort = new ServerSocket (portNumber,0,iPAddress);
				iPPort = new ServerSocket (portNumber);
				iPPort.setSoTimeout(60000);
				while (running) {

					//Block until I get a connection then go
					try {
	
						Socket adminConnection = iPPort.accept();
                                                if (adminConnection.isConnected()){
                                                    addTheHandler (adminConnection);
                                                }

					} catch (ConnectionFail conn){
						logger.log(Level.SEVERE,"Could not attatch handler to client request");
					} catch (SocketTimeoutException te) {
					    if (currentAdminController != null) {
							try {
								currentAdminController.sendXML (heartbeatDoc);
								// DEADLOCK HERE CC
							} catch (IOException io) {
						        currentAdminController.kill();
							}
					    }
					}catch (IOException io){
						logger.log(Level.WARNING, "Could not add admin handler " +io.getMessage());
					}
				}
			} catch (IOException ex) {
				logger.log (Level.WARNING,"Admin handler unable to startup due to network problems " +ex.getMessage());
			}
	}

	public void addTheHandler (Socket adminConnection) throws ConnectionFail, SocketTimeoutException,IOException{
            if (!adminConnection.isConnected()) {
                return ;
            }
            
            try {
			adminConnection.setKeepAlive(true);
		    sh.setOutputStream(adminConnection.getOutputStream());
		    if (firstConnection) {
			    logger.fine("Admin connection received");
			}
			else {
			    logger.fine("Admin connection received,closing existing admin connections");
			    if (currentAdminController != null) {
			        currentAdminController.kill();
			    }
			}
		} catch (java.net.SocketException ex) {}
		
		AdminClientHandler adminClientHandler = new AdminClientHandler (adminConnection,commandList,adminControllers, modelRegistry,startupTime,startupFile,logDir);
		adminClientHandler.setID(System.currentTimeMillis());
		adminClientHandler.setModelList(this.modelList);
		adminClientHandler.setIrLearner(this.irLearner);
		currentAdminController = adminClientHandler;

		newClient(adminClientHandler);
		adminControllers.add(adminClientHandler);
		firstConnection = false;
		adminClientHandler.start();
	}
	
	
	public void stopRunning () {
		running = false;

		try {
		    if (iPPort != null) iPPort.close();
		} catch (IOException io) { }
	}

	
	public void sendToOneClient (Document xmlDoc, long originatingID){
		Iterator <AdminClientHandler>clients = adminControllers.iterator();
		while (clients.hasNext()){
			AdminClientHandler client = (AdminClientHandler)clients.next();
			try {
				if (client.getID() == originatingID) client.sendXML(xmlDoc);
			} catch (IOException ex) {
				clients.remove();
				logger.log (Level.FINEST,"Admin connection broken, handler being removed");
			}
		}
	}
	
	public void sendToOneClient (String xmlDoc, long originatingID) {
		Iterator <AdminClientHandler>clients = adminControllers.iterator();
		while (clients.hasNext()){
			AdminClientHandler client = clients.next();
			try {
				if (client.getID() == originatingID) client.sendXML(xmlDoc);
			} catch (IOException ex) {
				clients.remove();
				logger.log (Level.FINEST,"Admin connection broken, handler being removed");
			}
		}
	}
	
	public void sendToAllClients (Element xmlElement, long originatingID)  {
	    Document docToSend = null;
	    if ((docToSend = xmlElement.getDocument()) == null)
	        docToSend = new Document (xmlElement);
	    sendToAllClients (docToSend,originatingID);
	}
    
	public void sendToAllClients (Document xmlDoc, long originatingID)  {
		Iterator <AdminClientHandler>clients = adminControllers.iterator();
		while (clients.hasNext()){
			AdminClientHandler client = clients.next();
			try {
				if (client.getID() != originatingID) client.sendXML(xmlDoc);
			} catch (IOException ex) {
				clients.remove();
				logger.log (Level.FINEST,"Admin connection broken, handler being removed");
			}
		}
	}
	
	public void sendToAllClients (String xmlDoc, long originatingID)  {
		Iterator <AdminClientHandler>clients = adminControllers.iterator();
		while (clients.hasNext()){
			AdminClientHandler client = clients.next();
			try {
				if (client.getID() != originatingID) client.sendXML(xmlDoc);
			} catch (IOException ex) {
				clients.remove();
				logger.log (Level.FINEST,"Admin connection broken, handler being removed");
			}
		}
	}

	protected void newClient (AdminClientHandler adminClientHandler) throws IOException {
			// tell the user that they're connected
			Document replyDoc = new Document (new Element ("connected"));	
			replyDoc.getRootElement().setAttribute ("launched",Long.toString(adminClientHandler.getStartupTime().getTime()));
			replyDoc.getRootElement().setAttribute ("config",adminClientHandler.getStartupFile());
			replyDoc.getRootElement().setAttribute ("logDir",adminClientHandler.getLogDir());
			if (irLearner!= null) 
				replyDoc.getRootElement().setAttribute ("irEndTime",irLearner.getInitEndTime());

			
			adminClientHandler.sendXML (replyDoc);
	
			int count = adminControllers.size();
			replyDoc = new Document (new Element ("Admin_Clients"));
			replyDoc.getRootElement().setAttribute ("count", "" + count);
			
			adminClientHandler.sendXML (replyDoc);

	}

	/**
	 * @return Returns the modelList.
	 */
	public Collection <DeviceModel>getModelList() {
		return modelList;
	}
	/**
	 * @param modelList The modelList to set.
	 */
	public void setModelList(Collection <DeviceModel>modelList) {
		this.modelList = modelList;
	}


	public String getLogDir() {
		return logDir;
	}


	public void setLogDir(String logDir) {
		this.logDir = logDir;
	}
}
