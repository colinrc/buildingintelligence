/*
 * Created on Dec 28, 2003
 *
 */
package au.com.BI.Flash;

import java.io.*;
import java.util.logging.*;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.Security;
import au.com.BI.Config.TooManyClientsException;
import au.com.BI.Home.VersionManager;

import java.util.*;
import java.net.*;

import org.jdom.*;
import au.com.BI.Macro.*;
import au.com.BI.Messaging.*;
import au.com.BI.Messaging.AddressBook.Locations;

import org.jdom.output.*;
/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 * This thread listens for clients and establishes connections as they occur
 */
public class FlashControlListener extends Thread {
    
    protected ServerSocket iPPort = null;
    protected AddressBook addressBook = null;
    
    protected LinkedList <FlashClientHandler>flashControllers = null;
    protected int portNumber;
    protected String Address = null;
    protected InetAddress iPAddress = null;
    protected Logger logger;
    protected volatile boolean running;
    protected CommandQueue commandList = null;
    protected au.com.BI.Command.Cache cache = null;
    protected MacroHandler macroHandler = null;
    protected Document heartbeatDoc = null;
    protected VersionManager versionManager = null;
    private int numberFlashClients = 0;
    private Security security = null;
    private Date timeOfLastLicenseMessage  = null;
    protected long serverID = 0;
    protected XMLOutputter xmlOut = null;
	protected ClientCommandFactory clientCommandFactory;
    
    public FlashControlListener(LinkedList <FlashClientHandler>flashControllers, int portNumber, String Address,CommandQueue commandList,
	    VersionManager versionManager,Security security,AddressBook addressBook)
	    throws CommsFail {
	heartbeatDoc = new Document(new Element("heartbeat"));
	
	logger = Logger.getLogger(this.getClass().getPackage().getName());

	this.setName("Flash Control Listener");
	timeOfLastLicenseMessage = new Date();
	clientCommandFactory = ClientCommandFactory.getInstance();
	
	this.versionManager = versionManager;
	this.addressBook = addressBook;
	this.security = security;
	xmlOut = new XMLOutputter();
	
	try {
	    logger.fine("Listening for clients on port " + portNumber + " IP " + Address);
	    this.flashControllers = flashControllers;
	    this.portNumber = portNumber;
	    this.iPAddress = InetAddress.getByName(Address);
	    this.commandList = commandList;
	    
	    BroadcastHandler bsh = new BroadcastHandler(new BroadcastFormatter());
	    bsh.setFlashControlListener(this);
	    bsh.setLevel(Level.SEVERE);
	    Logger blogger = Logger.getLogger("au.com.BI");
	    blogger.addHandler(bsh);
	} catch (UnknownHostException uhe) {
	    throw new CommsFail("Cannot establish server for flash clients " + uhe.getMessage());
	}
    }
    
    public void setMacroHandler(MacroHandler macroHandler){
	this.macroHandler = macroHandler;
    }
    
    /**
     * Main thread.
     * Sits in a continuous loop creating FlashClientHandler objects as required to
     * to handle each flash client
     */
    
    public void run() {
	
	logger.fine("Openning port " + portNumber);
	running = true;
	
	try {
	    boolean recentConnection = false;
	    
	    //iPPort = new ServerSocket (portNumber,0,iPAddress);
	    iPPort = new ServerSocket(portNumber);
	    iPPort.setSoTimeout(60000);
	    while (running) {
		
			//Block until I get a connection then go
			try {
			    
			    Socket flashConnection = iPPort.accept();
	                    if (flashConnection.isConnected()){
	                        addTheHandler(flashConnection,false);
	                    }
			    
			} catch (ConnectionFail conn){
			    logger.log(Level.SEVERE,"Could not attatch handler to client request");
			} catch (SocketTimeoutException te) {
			    synchronized (flashControllers) {
					recentConnection = false;
					ListIterator <FlashClientHandler>allControllers = flashControllers.listIterator();
					boolean keepGoing = true;
					numberFlashClients = 0;
					while (keepGoing && allControllers.hasNext() ){
					    FlashClientHandler flashClientHandler = (FlashClientHandler)allControllers.next();
					    if (!sendXML(flashClientHandler,heartbeatDoc)) {
					    	flashClientHandler.close();
					    	addressBook.removeByID(flashClientHandler.getID());
					    	allControllers.remove();

							ClientCommand clientCommand = clientCommandFactory.buildListNamesCommand();
							if (clientCommand != null) {
									commandList.add(clientCommand);
							}
					    	
					    	logger.log(Level.FINE,"Client went away, removing the handler");
					    } else {
					    	if (System.currentTimeMillis() - flashClientHandler.getConnectionTime()  < 60*1000*3) {
					    		recentConnection = true;
							}
					    	numberFlashClients ++;
					    }
					}
				
			    }
			    try {
			    	 security.allowClient(numberFlashClients);
			    } catch (TooManyClientsException ex){
			    	if (!recentConnection) displayTooManyClients(numberFlashClients,ex);
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
    
    public void displayTooManyClients(int numberFlashClients, TooManyClientsException ex) {
	Date currentTime = new Date();
	//if ((currentTime.getTime() - timeOfLastLicenseMessage.getTime()) > 60*1000*2){ // 2 minute intervals
	
	Element conElement = new Element("MESSAGE");
	conElement.setAttribute("TITLE", "Security");
	conElement.setAttribute("ICON", "warning");
	conElement.setAttribute("AUTOCLOSE", "45");
	conElement.setAttribute("HIDECLOSE", "TRUE");
	conElement.setAttribute("TARGET", AddressBook.ALL);
	
	conElement.setAttribute("CONTENT", ex.getMessage());
	Document replyDoc = new Document(conElement);
	this.sendToAllClients(replyDoc,0);
	timeOfLastLicenseMessage =  currentTime;
	//}
    }
    
    public void addTheHandler(Socket flashConnection , boolean isServer) throws ConnectionFail, SocketTimeoutException,IOException{
	
	if (!flashConnection.isConnected()){
	    return;
	}
	flashConnection.setKeepAlive(true);
	logger.fine("Client connection received");
	ClientCommandFactory clientCommandFactory =   ClientCommandFactory.getInstance();
	clientCommandFactory.setOriginating_location(Locations.DIRECT);
	clientCommandFactory.setID(System.currentTimeMillis());
	clientCommandFactory.setAddressBook(addressBook);
	FlashClientHandler flashClientHandler = new FlashClientHandler(flashConnection,commandList,flashControllers, clientCommandFactory);
	flashClientHandler.setConnectionTime(System.currentTimeMillis());
	flashClientHandler.setServerID(this.getServerID());
	flashClientHandler.setMacroHandler(macroHandler);
	
	
	synchronized (flashControllers) {
	    flashControllers.add(flashClientHandler);
	}
	newClient(flashClientHandler,clientCommandFactory.getID(),this.getServerID());
	doStartupCacheItems(flashClientHandler);
	flashClientHandler.start();
	
    }
    
       protected void doStartupCacheItems(FlashClientHandler client) {
	
	if (cache == null) {
	    logger.log(Level.WARNING,"Do Startup Cache Items called in flash, but cache has not yet been initialised");
	    return;
	}
	try {
	    CacheWrapper cachedObject = null;
	    for (String key:cache.getStartupItemList()){
			try {
			    cachedObject = cache.getCachedObject(key);
			    if (cachedObject == null) {
					logger.log(Level.FINE,"Cache returned a null object for key " + key);
					continue;
			    }
			} catch (ClassCastException ex) {
			    logger.log(Level.WARNING,"Cache key object is not a string " + ex.getMessage());
			}
			if (!cachedObject.isSendWithStartup()){
				continue;
			}
			// logger.log (Level.WARNING,"object from cache for " + key + " is " + cachedObject.toString());
			// Cached items are sets if the device requires all instances of the command to be cached
			// cacheAllCommands returned true.
			// For example, on audio when mute on / off is transmitted separately to volume up / down
			// for the same audio device.
			if (cachedObject.isSet()) {
				for (CommandInterface theCommand: cache.getSetElements((cachedObject))){
					try {
					    if (!doCacheItem(client,(Command)theCommand)) {
						logger.log(Level.FINE,"Client has disapeared, aborting startup");
						break;
					    }
					} catch (ClassCastException ex) {
					    logger.log(Level.FINE,"Cache item was marked as set, but was actually simple " + ex.getMessage());
					} catch (Exception ex) {
					    logger.log(Level.FINE,"An unknown error occurred running doChacheItem on " + theCommand.toString());
					}
				
			    }
			    
			} else {
			    try {
				if (!doCacheItem(client,cachedObject.getCommand())) {
				    logger.log(Level.FINE,"Client has disapeared, aborting startup");
				    break;
				}
			    } catch (ClassCastException ex) {
				logger.log(Level.FINE,"Cache item was marked as set, but was actually simple " + ex.getMessage());
			    }
			}
	    }
	} catch (Exception ex) {
	    logger.log(Level.WARNING,"Exception on client startup " + ex.getMessage());
	}
    }
    
    public boolean doCacheItem(FlashClientHandler client,CommandInterface command) {
	Element message = command.getXMLCommand();
	if (!this.sendXML(client,message))
	    return false;
	else
	    return true;
    }
    
    
    public void stopRunning() {
	running = false;

	
	try {
	    if (iPPort != null) iPPort.close();
	} catch (IOException io) { }
	
	synchronized (flashControllers) {
		for (FlashClientHandler nextClientHandler: flashControllers){
			nextClientHandler.setThisThreadRunning(false);
	    }
	}
    }
    
    
    public void sendToOneClient(Document xmlDoc, long originatingID){
    	synchronized (flashControllers) {
			for (FlashClientHandler client: flashControllers) {
				if (client.getID() == originatingID) sendXML(client,xmlDoc);
		    }
    	}
    }
    
    public void sendToOneClient(Element xmlDoc, long originatingID){
	synchronized (flashControllers) {
		for (FlashClientHandler client: flashControllers) {
			if (client.getID() == originatingID) sendXML(client,xmlDoc);
	    }
	}
    }
    
    public void sendToAllClients(Document xmlDoc, long originatingID){
		for (FlashClientHandler client: flashControllers) {
			if (client.getID() != originatingID) sendXML(client,xmlDoc);
		}
    }
    
    public void sendToAllClients(String xmlDoc, long originatingID){
		for (FlashClientHandler client: flashControllers) {
			if (client.getID() != originatingID) sendXML(client,xmlDoc);
		}
    }
       
    public void sendToAllClients(Element xmlDoc, long originatingID){
		for (FlashClientHandler client: flashControllers) {
		    if (client.getID() != originatingID) sendXML(client,xmlDoc);
		}
    }
	   
    public boolean sendXML(FlashClientHandler client, Element xmlDoc) {
	try	 {
	    synchronized (client.o) {
		xmlOut.output(xmlDoc, client.o) ;
		client.o.write(0);
		client.o.flush();
		return true;
	    }
	} catch (IOException ex) {
	    logger.log(Level.FINER, "IO Exception talking to client " + client.getID() + " : " + ex.getMessage());
	    client.setThisThreadRunning(false);
	    return false;
	}
    }
	
    public boolean sendXML(FlashClientHandler client, Document xmlDoc) {
	try	 {
	    synchronized (client.o) {
		xmlOut.output(xmlDoc, client.o) ;
		client.o.write(0);
		client.o.flush();
		return true;
	    }
	} catch (IOException ex) {
	    logger.log(Level.FINER, "IO Exception talking to client " + client.getID() + " : " + ex.getMessage());
	    client.setThisThreadRunning(false);
	    return false;
	}
    }
    
    
    public boolean sendXML(FlashClientHandler client, String xmlDoc) {
	try	 {
	    synchronized (client.o) {
		client.o.write(xmlDoc.getBytes());
		client.o.write(0);
		client.o.flush();
		return true;
	    }
	} catch (IOException ex) {
	    logger.log(Level.FINER, "IO Exception talking to client " + ex.getMessage());
	    client.setThisThreadRunning(false);
	    return false;
	}
    }
    
    protected void setCache(au.com.BI.Command.Cache cache){
	this.cache = cache;
    }
    
    protected void newClient(FlashClientHandler flashClientHandler, long flashID, long serverID) {
	// tell the user that they're connected
		Element conElement = new Element("connected");
		
		String masterVersion = versionManager.getMasterVersion();
		conElement.setAttribute("version", masterVersion);

		Document replyDoc = new Document(conElement);
		sendXML(flashClientHandler, replyDoc);
		
		Command initConnection = new Command();
		initConnection.setKey("SYSTEM");
		initConnection.setCommand("ClientAttatch");
		initConnection.setExtraInfo(Long.toString(flashID));
		initConnection.setExtra2Info(Long.toString(serverID));
	    commandList.add(initConnection);

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

	public VersionManager getVersionManager() {
		return versionManager;
	}

	public void setVersionManager(VersionManager versionManager) {
		this.versionManager = versionManager;
	}
    
    
    
}
