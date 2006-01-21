/*
 * Created on Feb 16, 2004
 *
 */
package au.com.BI.Admin;
import java.net.*;
import au.com.BI.Flash.ClientCommand;
import java.io.*;
import java.util.logging.*;
import java.util.*;
import org.jdom.*;
import org.jdom.input.SAXBuilder;
import au.com.BI.Comms.*;
import au.com.BI.User.*;
import au.com.BI.Command.*;

import org.jdom.output.*;
import au.com.BI.Util.*;



/**
 * @author Colin Canfield
 *
 **/
public class AdminClientHandler extends Thread
{
	protected Logger logger;
	protected Socket clientConnection;
	protected boolean thisThreadRunning;
	protected InputStream i;
	protected OutputStream o;
	protected User user;
	protected List commandList;
	protected long ID;
	protected boolean remoteServer = false;
	protected boolean isAdmin = false;
	protected HashMap modelRegistry;
	protected Collection modelList;
	protected Date startupTime;
	protected String startupFile;
	protected String logDir;
	protected au.com.BI.IR.Model irLearner;
	
	protected List clientList; // used to remove this thread in case of disaster
	protected XMLOutputter xmlOut;
	protected BufferedReader rd;
	
	public AdminClientHandler (Socket connection,List commandList, List clientList,
			HashMap modelRegistry, Date startupTime, String startupFile,String logDir) throws ConnectionFail {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		clientConnection = connection;
		this.commandList = commandList;
		this.modelRegistry = modelRegistry;
		this.startupTime = startupTime;
		this.startupFile = startupFile;
		this.logDir = logDir;
		this.setName("Admin Client Handler");

		ID = 0;
		//try {
			//clientConnection.setTcpNoDelay(true);
			//clientConnection.setSoTimeout(60000);
		//} catch (SocketException se) {
			//throw new ConnectionFail ("Connection failed",se);
		//}

		try {
			i = clientConnection.getInputStream();
			o = clientConnection.getOutputStream();
	        rd = new BufferedReader(new InputStreamReader(i));
		} catch (IOException ioe) {
			throw new ConnectionFail ("Could not get communication streams",ioe);
		}
		
		xmlOut = new XMLOutputter ();
		thisThreadRunning = false;
	}
	
	public Date getStartupTime () {
		return startupTime;
	}
	

	
	public String getStartupFile () {
		return startupFile;
	}
	
	public void setUser (User user) {
		this.user = user;
	}
	
	public void kill ()
	{
		thisThreadRunning = false;
	}
	
	/**
	 * @param commandList The synchronised fifo queue for ReceiveEvent objects
	 */
	public void setCommandList (List commandList){
		this.commandList = commandList;
	}
	
    /**
     * @param irLearner The irLearner to set.
     */
    public void setIrLearner(DeviceModel irLearner) {
        this.irLearner = (au.com.BI.IR.Model)irLearner;
    }
	

	public void run ()
	{
		logger.info("Client connection received. Handler started");
		thisThreadRunning = true;

		doStartupCacheItems();
		//sendStartupRequest();
		
		while (thisThreadRunning)
		{


			// endflag is set to true when we see a "null" byte
			String newBuffer = "";
			try {
				newBuffer = rd.readLine();
			} catch (IOException e) {
			    thisThreadRunning = false;
			    try {
					i.close();
				} catch (IOException e1) {
				}
			    try {
				    o.close();
				} catch (IOException e1) {
				}
			}
			if (newBuffer != null && !newBuffer.trim().equals ("")) {
				processBuffer (newBuffer.trim());
			}
		}
	}
	
	public void processBuffer (String readBuffer)
	
	{
		SAXBuilder saxb = new SAXBuilder(false); //get a SAXBuilder
		Document xmlDoc;           // xml document object to work with

		logger.log(Level.FINEST,"Received string from client, processing");
		// the array sent to the XML builder cannot have any extra space at the end
		// so we create a new array and copy everything accumulated in "readBuffer"
		
	
		try
		{
			xmlDoc = saxb.build(new StringReader(readBuffer));

			processXML(xmlDoc);
		}
		catch (JDOMException ex)
		{
			logger.log (Level.WARNING,"XML ERROR " + ex.getMessage());
			Element error = new Element ("error");
			error.setAttribute ("msg", "JDOM parsing error");
			Document replyDoc = new Document (error);
			try {
				sendXML (replyDoc);
			}
			catch (IOException io){
				logger.log(Level.SEVERE, "IO failed communicating with client " + io.getMessage());
				this.thisThreadRunning = false;
				this.clientList.remove(this);
			}
		}
		catch (IOException io){
			logger.log(Level.SEVERE, "IO failed communicating with client " + io.getMessage());
			this.thisThreadRunning = false;
			this.clientList.remove(this);
		}
	}

	
	public void processBuffer (byte [] readBuffer, int count)
	
	{
		SAXBuilder saxb = new SAXBuilder(false); //get a SAXBuilder
		Document xmlDoc;           // xml document object to work with

		logger.log(Level.FINEST,"Received string from client, processing");
		// the array sent to the XML builder cannot have any extra space at the end
		// so we create a new array and copy everything accumulated in "readBuffer"
		
		byte[] xmlByte = new byte[count];
		System.arraycopy(readBuffer,0,xmlByte,0,count);

		//build a Stream from the array
		ByteArrayInputStream bais = new ByteArrayInputStream(xmlByte);
		
		try
		{
			xmlDoc = saxb.build(bais); 
			processXML(xmlDoc);
		}
		catch (JDOMException ex)
		{
			logger.log (Level.WARNING,"XML ERROR " + ex.getMessage());
			Element error = new Element ("error");
			error.setAttribute ("msg", "JDOM parsing error");
			Document replyDoc = new Document (error);
			try {
				sendXML (replyDoc);
			}
			catch (IOException io){
				logger.log(Level.SEVERE, "IO failed communicating with client");
				this.thisThreadRunning = false;
				this.clientList.remove(this);
			}
		}
		catch (IOException io){
			logger.log(Level.SEVERE, "IO failed communicating with client");
			this.thisThreadRunning = false;
			this.clientList.remove(this);
		}
	}

	
	protected void doStartupCacheItems () {

	}
	
	protected String getLogDir () {
		return this.logDir;
	}
	
	
	/**
	 * Process the XML document sent from the client
	 * @param xmlDoc A Sax representation of the document
	 */
	protected void processXML (Document xmlDoc){

		String name = ""; // the name of the node
		
		Element rootElement = xmlDoc.getRootElement(); 
		name = rootElement.getName();
		
		if (name.equals("IR_LEARN")) {
			String irName = rootElement.getAttributeValue ("NAME");
		    logger.log (Level.FINE,"IR Learn command received : " + irName);
		    if (irLearner != null) {
		    		irLearner.learnCommand (irName);
		    }
		    else {
				logger.log (Level.WARNING,"IR Learn command received, but no IR learner configured");	
				Element returnXML = new Element("IR_LEARNT");
				returnXML.setAttribute("RESULT","IR Learn command received, but no IR learner configured");
				try {
					this.sendXML(returnXML);
				} catch (IOException io){
					logger.log(Level.SEVERE, "IO failed communicating with client");
					this.thisThreadRunning = false;
					this.clientList.remove(this);
				}
		    }
		}
		if (name.equals("ADMIN")) {
		    logger.log (Level.INFO,"Admin connection received");
		    this.setAdmin(true);
		}
		if (name.equals("DEBUG")) {
			String packageName = (rootElement.getAttributeValue("PACKAGE"));
			String levelStr = (rootElement.getAttributeValue("LEVEL"));
			Level newLevel;
			
			try {
			     if (levelStr != null) 
			     	newLevel = Level.parse(levelStr);
			     else
			     	newLevel = Level.INFO;
			} catch (IllegalArgumentException ex) {
			    newLevel = Level.INFO;
			}    

			if (packageName != null) {
				Logger theLogger = Logger.getLogger(packageName);
				theLogger.setLevel(newLevel);
				logger.log (Level.FINEST,"Debug level set. " + packageName + " " + newLevel);
			}
			else {
				logger.log (Level.WARNING,"Debug level command did not include a package name");				
			}

		}
		if (name.equals("DEBUG_PACKAGES")) {
			Element returnXML = new Element("DEBUG_PACKAGES");
			
			
			buildPackageMenuXML (returnXML,"BI","au.com.BI");
			buildPackageMenuXML (returnXML,"Config","au.com.BI.Config");
			buildPackageMenuXML (returnXML,"Comms","au.com.BI.Comms");
			buildPackageMenuXML (returnXML,"Script","au.com.BI.Script");
			
			Iterator allPackages = this.modelRegistry.keySet().iterator();
			
			while (allPackages.hasNext()) {
			    String shortName = (String)allPackages.next();
			    String fullClassName = (String)modelRegistry.get(shortName);
				buildPackageMenuXML (returnXML,shortName,fullClassName);
			}    

			try {
				this.sendXML(returnXML);
			} catch (IOException io){
				logger.log(Level.SEVERE, "IO failed communicating with client");
				this.thisThreadRunning = false;
				this.clientList.remove(this);
			}
		}
		if (name.equals("RELOAD_SCRIPTS")) {
            Command command = new Command ("SYSTEM","LoadScripts",user);
            synchronized (commandList){
            		commandList.add (command);
            		commandList.notifyAll();
            }
		}
		if (name.equals("RELOAD_MACROS")) {
            Command command = new Command ("SYSTEM","LoadMacros",user);
            synchronized (commandList){
            		commandList.add (command);
            		commandList.notifyAll();
            }
		}
		if (name.equals("RELOAD_IRDB")) {
            Command command = new Command ("SYSTEM","LoadIRDB",user);
            synchronized (commandList){
            		commandList.add (command);
            		commandList.notifyAll();
            }
		}
		if (name.equals("LIST_IR_ACTIONS")) {
			String device = rootElement.getAttributeValue("DEVICE");
			if (device != null){
	            AdminCommand command = new AdminCommand ("ADMIN","List_Actions",user);
	            command.setExtraInfo(device);
	            synchronized (commandList){
	            		commandList.add (command);
	            		commandList.notifyAll();
	            }
			}
		}
		if (name.equals("LIST_IR_DEVICES")) {
            AdminCommand command = new AdminCommand ("ADMIN","List_Devices",user);
            synchronized (commandList){
            		commandList.add (command);
            		commandList.notifyAll();
            }
		}
		if (name.equals("TEST_IR")) {
            ClientCommand command = new ClientCommand ("",rootElement.getAttributeValue("TARGET"),user,
            		rootElement.getAttributeValue("DEVICE") + "."+rootElement.getAttributeValue("ACTION"));
            command.setExtra2Info(rootElement.getAttributeValue("REPEAT"));

            synchronized (commandList){
            		commandList.add (command);
            		commandList.notifyAll();
            }
		}		
		if (name.equals("IR_CONFIG")) {
			String ir_command = rootElement.getAttributeValue ("EXTRA");
		    logger.log (Level.FINE,"IR Config command received : " + ir_command);
		    if (irLearner != null) {
		    		irLearner.sendConfigCommand (ir_command);
		    }
		    else {
				logger.log (Level.WARNING,"IR configuration command received, but no IR learner configured");	
				Element returnXML = new Element("IR_CONFIG");
				returnXML.setAttribute("RESULT","IR configuration command received, but no IR learner configured");
				try {
					this.sendXML(returnXML);
				} catch (IOException io){
					logger.log(Level.SEVERE, "IO failed communicating with client");
					this.thisThreadRunning = false;
					this.clientList.remove(this);
				}
		    }
		}
	}



	protected void buildPackageMenuXML (Element returnXML, String shortName, String fullClassName) {
		int lastSeperator = fullClassName.lastIndexOf('.');
		String packageName = fullClassName.substring(0,lastSeperator);
		if (shortName.equals("BI"))
		    shortName = "Global";
		Level currentLevel = (Logger.getLogger(packageName)).getLevel();
		String levelStr = "INFO";
		if (currentLevel != null) 
		    levelStr = currentLevel.getName();
		    
		Element newMenu = new Element ("DEBUG_MENU");
		newMenu.setAttribute("SHORTNAME",shortName);
		newMenu.setAttribute("PACKAGENAME",packageName);
		newMenu.setAttribute("LEVEL",levelStr);
		returnXML.addContent(newMenu);
	}

	public Command buildCommand (String key,Element rootElement){
		String commandString;
		String extra;
		commandString = rootElement.getAttributeValue("COMMAND");
		if (commandString == null) commandString = "";

		extra = rootElement.getAttributeValue("EXTRA");
		if (extra != null) extra = ""; 
		logger.log (Level.FINER,"DISPLAY_NAME=" + key + " Command="+ commandString + " extra=" + extra);
		Command command = new Command (key,commandString,user,extra);
		return command;
	}

	
	public boolean sendXML (Element xmlElement) throws IOException {
		synchronized (this.o) {
			Document xmlDoc = new Document();
			xmlDoc.addContent(xmlElement);
			xmlOut.output(xmlDoc, this.o) ;
			this.o.write (0);
			this.o.flush();
			return true;
		}
	}	
	
	public boolean sendXML (Document xmlDoc)throws IOException {
		synchronized (this.o) {
			xmlOut.output(xmlDoc, this.o) ;
			this.o.write (0);
			this.o.flush();
			return true;
		}
	}	


	public boolean sendXML (String xmlDoc) throws IOException {
		synchronized (this.o) {
			this.o.write (xmlDoc.getBytes());
			this.o.write(0);
			this.o.flush();
			return true;
		}
	}	
	
	/**
	 * @return Returns the iD.
	 */
	public long getID() {
		return ID;
	}
	/**
	 * @param id The iD to set.
	 */
	public void setID(long id) {
		ID = id;
	}
    /**
     * @return Returns the remoteServer.
     */
    public boolean isRemoteServer() {
        return remoteServer;
    }
    /**
     * @param remoteServer The remoteServer to set.
     */
    public void setRemoteServer(boolean remoteServer) {
        this.remoteServer = remoteServer;
    }

    /**
     * @return Returns the isAdmin.
     */
    public boolean isAdmin() {
        return isAdmin;
    }
    /**
     * @param isAdmin The isAdmin to set.
     */
    public void setAdmin(boolean isAdmin) {
        this.isAdmin = isAdmin;
    }
	/**
	 * @return Returns the modelList.
	 */
	public Collection getModelList() {
		return modelList;
	}
	/**
	 * @param modelList The modelList to set.
	 */
	public void setModelList(Collection modelList) {
		this.modelList = modelList;
	}

	public void setLogDir(String logDir) {
		this.logDir = logDir;
	}
}
