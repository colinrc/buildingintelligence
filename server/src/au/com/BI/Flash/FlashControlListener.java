/*
 * Created on Dec 28, 2003
 *
*/
package au.com.BI.Flash;

import java.io.*;
import java.util.logging.*;

import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.Security;
import java.util.*;
import java.net.*;

import org.jdom.*;
import au.com.BI.Macro.*;
import au.com.BI.Messaging.*;

/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 * This thread listens for clients and establishes connections as they occur
 */
public class FlashControlListener extends Thread  
{
	
	protected ServerSocket iPPort;
	protected Socket masterSocket;
	protected AddressBook addressBook;

	protected LinkedList flashControllers;
	protected int portNumber;
	protected String Address;
	protected InetAddress iPAddress;
	protected Logger logger;
	protected boolean running;
	protected List commandList;
	protected au.com.BI.Command.Cache cache;
	protected MacroHandler macroHandler;
	protected Document heartbeatDoc;
	protected String masterIP;
	protected int masterPort;
    protected boolean connectedMaster = false;
    protected boolean masterNeeded = false;
	protected EventCalendar eventCalendar;
	protected String version;
	private int numberFlashClients = 0;
	private Security security = null;
	private Date timeOfLastLicenseMessage  = null;
	protected long serverID = 0;
	
	public FlashControlListener (LinkedList flashControllers, int portNumber, String Address,List commandList,
			String version,Security security,AddressBook addressBook) 
		throws CommsFail
	{
		heartbeatDoc = new Document (new Element ("heartbeat"));
		
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		masterSocket = null;
		this.setName("Flash Control Listener");
		timeOfLastLicenseMessage = new Date();

		
		this.version = version;
		this.addressBook = addressBook;
		this.security = security;

		try {
			logger.info("Listening for clients on port " + portNumber + " IP " + Address);
			this.flashControllers = flashControllers;
			this.portNumber = portNumber;
			this.iPAddress = InetAddress.getByName (Address);
			this.commandList = commandList;

			BroadcastHandler bsh = new BroadcastHandler(new BroadcastFormatter());
			bsh.setFlashControlListener(this);
			bsh.setLevel(Level.SEVERE);
			Logger blogger = Logger.getLogger("au.com.BI");
			blogger.addHandler(bsh);
		} catch (UnknownHostException uhe) {
			throw new CommsFail ("Cannot establish server for flash clients " + uhe.getMessage());
		}	
	}
	
	public void setMacroHandler (MacroHandler macroHandler){
		this.macroHandler = macroHandler;
	}
	
	/**
	* Main thread. 
	* Sits in a continuous loop creating FlashClientHandler objects as required to 
	* to handle each flash client
	*/

	public void run ()
	{

		logger.info("Openning port " + portNumber);
		running = true;
		
		try {
			boolean recentConnection = false;

			//iPPort = new ServerSocket (portNumber,0,iPAddress);
			iPPort = new ServerSocket (portNumber);
			iPPort.setSoTimeout(60000);
			while (running) {
			    while (!connectedMaster && masterNeeded) {
			        this.addMasterServerListener();
		    			if (!connectedMaster){
		    			    Thread.yield();
			            try {
			                Thread.sleep(2000);
			            } catch (InterruptedException ex) {}
		    			}
		    		}

				//Block until I get a connection then go
				try {

					Socket flashConnection = iPPort.accept();
					addTheHandler (flashConnection,false);
					numberFlashClients ++;

				} catch (ConnectionFail conn){
					logger.log(Level.SEVERE,"Could not attatch handler to client request");
				} catch (SocketTimeoutException te) {
				    synchronized (flashControllers) { 
				    		recentConnection = false;
					    ListIterator allControllers = flashControllers.listIterator();
						boolean keepGoing = true;
						numberFlashClients = 0;
						while (keepGoing && allControllers.hasNext() ){
						    FlashClientHandler flashClientHandler = (FlashClientHandler)allControllers.next();
						    if (!flashClientHandler.sendXML (heartbeatDoc)) {
							    	allControllers.remove();
							    if (flashClientHandler.isRemoteServer() ) {
								    logger.log (Level.INFO,"Lost connection to master server, re-establishing");
								    connectedMaster = false;
								    keepGoing = false;
								}
								else {
								    logger.log (Level.INFO,"Client went away, removing the handler");
								}
						    } else {
						    		if (System.currentTimeMillis() - flashClientHandler.getConnectionTime()  < 60*1000*3) {
						    			recentConnection = true;
						    		}
						    		numberFlashClients ++;
						    }
						}

					}
					if (!recentConnection && !security.allowClient(numberFlashClients)) {
						displayTooManyClients(numberFlashClients);
					}
				}
			}
		}catch (IOException io){
			logger.log(Level.SEVERE, "Could not add client handler " +io.getMessage());
			Command command = new Command();
			command.setKey("SYSTEM");
			command.setCommand("ShutDown");
			synchronized (commandList){
				commandList.add(command);
			}
		}
	}
	
	public void displayTooManyClients (int numberFlashClients) {
		Date currentTime = new Date();
		//if ((currentTime.getTime() - timeOfLastLicenseMessage.getTime()) > 60*1000*2){ // 2 minute intervals

			Element conElement = new Element ("MESSAGE");
			conElement.setAttribute ("TITLE", "Security");
			conElement.setAttribute ("ICON", "warning");
			conElement.setAttribute ("AUTOCLOSE", "45");
			conElement.setAttribute ("HIDECLOSE", "TRUE");
			conElement.setAttribute ("TARGET", AddressBook.ALL);
			
			conElement.setAttribute ("CONTENT", "You have connected with more clients than you have purchased licenses for, please contact your integrator");
			Document replyDoc = new Document (conElement);	
			this.sendToAllClients (replyDoc,0);
			timeOfLastLicenseMessage =  currentTime;
		//}
	}

	public void addTheHandler (Socket flashConnection , boolean isServer) throws ConnectionFail, SocketTimeoutException,IOException{
		flashConnection.setKeepAlive(true);
		logger.info("Client connection received");
		FlashClientHandler flashClientHandler = new FlashClientHandler (flashConnection,commandList,flashControllers,addressBook);
		flashClientHandler.setID(System.currentTimeMillis());
		flashClientHandler.setConnectionTime (System.currentTimeMillis());
		flashClientHandler.setServerID (this.getServerID());
		flashClientHandler.setCache(cache);
		flashClientHandler.setMacroHandler (macroHandler);
		flashClientHandler.setRemoteServer(isServer);
		flashClientHandler.setEventCalendar(eventCalendar);

		
		synchronized (flashControllers) {
		    flashControllers.add (flashClientHandler);
		}
		newClient(flashClientHandler);
		flashClientHandler.start();

	}
	
	
	public void stopRunning () {
		running = false;
		try {
		    if (masterSocket != null) masterSocket.close();
		} catch (IOException io) { }
		
		try {
		    if (iPPort != null) iPPort.close();
		} catch (IOException io) { }
	}

	/**
	 * Adds a connection to a remote server. Messages from the remote master servers are reflected flash
	 * messages, hence the same listener is appropriate
	 * @param IP Remote server
	 * @param port Remote port (Usually 10000)
	 */
	public void addMasterServerListener (String IP, int port) {
	    masterIP = IP;
	    masterPort = port;	    
	    masterNeeded = true;
	}
	
	public void addMasterServerListener () {
		//iPPort = new ServerSocket (portNumber,0,iPAddress);
	    if (masterIP == null || masterPort == 0) return;
	    if (masterIP.equals ("")) return;
	    
	    SocketAddress sockaddr = new InetSocketAddress(masterIP, masterPort);
		logger.info("Openning IP " + masterIP + " port " + masterPort);
		
		try {
			masterSocket = new Socket ();
			
		    logger.log (Level.INFO, "Opening connection to master server " + masterIP);
		    masterSocket.connect(sockaddr, 5000);
		    addTheHandler (masterSocket,true);
		    connectedMaster = true;
		} catch (IOException io) {
		    logger.log (Level.INFO, "IO Exception communicating with master server " + io.getMessage());
		} catch (ConnectionFail fail) {			    
		    logger.log (Level.INFO, "Connection failed communicating with master server " + fail.getMessage());
		}
	}
	
	public void sendToOneClient (Document xmlDoc, long originatingID){
		synchronized (flashControllers) {
			Iterator clients = flashControllers.iterator();
			while (clients.hasNext()){
				FlashClientHandler client = (FlashClientHandler)clients.next();
				if (client.getID() == originatingID) client.sendXML(xmlDoc);
			}
		}
	}
	
	public void sendToOneClient (String xmlDoc, long originatingID){
		synchronized (flashControllers) {
			Iterator clients = flashControllers.iterator();
			while (clients.hasNext()){
				FlashClientHandler client = (FlashClientHandler)clients.next();
				if (client.getID() == originatingID) client.sendXML(xmlDoc);
			}
		}
	}

	public void sendToAllClients (Document xmlDoc, long originatingID){
		Iterator clients = flashControllers.iterator();
		while (clients.hasNext()){
			FlashClientHandler client = (FlashClientHandler)clients.next();
			if (client.getID() != originatingID) client.sendXML(xmlDoc);
		}
	}
	
	public void sendToAllClients (String xmlDoc, long originatingID){
		synchronized (flashControllers){
			Iterator clients = flashControllers.iterator();
			while (clients.hasNext()){
				FlashClientHandler client = (FlashClientHandler)clients.next();
				if (client.getID() != originatingID) client.sendXML(xmlDoc);
			}
		}
	}
	
	
	protected void setCache (au.com.BI.Command.Cache cache){
		this.cache = cache;
	}

	protected void newClient (FlashClientHandler flashClientHandler) {
		// tell the user that they're connected
		Element conElement = new Element ("connected");
		conElement.setAttribute ("version", version);
		Document replyDoc = new Document (conElement);	
		flashClientHandler.sendXML (replyDoc);
	}
	/**
	 * @return Returns the eventCalendar.
	 */
	public EventCalendar getEventCalendar() {
		return eventCalendar;
	}
	/**
	 * @param eventCalendar The eventCalendar to set.
	 */
	public void setEventCalendar(EventCalendar eventCalendar) {
		this.eventCalendar = eventCalendar;
	}

	public int getNumberFlashClients() {
		return numberFlashClients;
	}

	public long getServerID() {
		return serverID;
	}

	public void setServerID(long serverID) {
		this.serverID = serverID;
	}



}
