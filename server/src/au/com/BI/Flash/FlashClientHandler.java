/*
 * Created on Feb 16, 2004
 *
 */
package au.com.BI.Flash;
import java.net.*;
import java.io.*;
import java.util.logging.*;
import java.util.*;
import au.com.BI.Util.TEA;
import java.security.InvalidKeyException;
import org.jdom.*;
import org.jdom.input.SAXBuilder;

import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Comms.*;
import au.com.BI.User.*;
import au.com.BI.Macro.*;
import au.com.BI.Messaging.*;


/**
 * @author Colin Canfield
 *
 **/
public class FlashClientHandler extends Thread {
    protected Logger logger;
    protected Socket clientConnection;
    protected boolean thisThreadRunning;
    protected InputStream i;
    protected OutputStream o;
    protected User user;
    protected List commandList;
    protected long ID;
    protected MacroHandler macroHandler = null;
    protected EventCalendar eventCalendar;
    protected AddressBook addressBook;
    protected long connectionTime;
    protected long serverID;
    
    
    protected List clientList; // used to remove this thread in case of disaster
    protected BufferedReader rd;
    
    private TEA decrypter = null;
    
    public FlashClientHandler(Socket connection,List commandList, List clientList,AddressBook addressBook) throws ConnectionFail {
	logger = Logger.getLogger(this.getClass().getPackage().getName());
	clientConnection = connection;
	this.addressBook = addressBook;
	this.commandList = commandList;
	this.setName("Flash Client Handler");
	
	byte[] key = new byte[]{1,2,3,4};
	decrypter = new TEA ();
	try {
		decrypter.engineInit(key,true);
	} catch (InvalidKeyException ex){
		logger.log (Level.SEVERE,"An invalid key has been specified for Flash communitation");
	}
	
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
	    rd = new BufferedReader(new InputStreamReader(connection.getInputStream()));
	} catch (IOException ioe) {
	    throw new ConnectionFail("Could not get communication streams",ioe);
	}
	

	thisThreadRunning = false;
    }
    
    public void setUser(User user) {
	this.user = user;
    }
    
    public void kill() {
	thisThreadRunning = false;
    }
    
    /**
     * @param commandList The synchronised fifo queue for ReceiveEvent objects
     */
    public void setCommandList(List commandList){
	this.commandList = commandList;
    }
 
    public void run() {
	logger.info("Client connection received. Handler started");
	thisThreadRunning = true;
	Document xmlDoc = null;

	
	SAXBuilder saxb = new SAXBuilder(false); //get a SAXBuilder
		
	while (thisThreadRunning) {
	    
		try {
		    String nextItem = rd.readLine();
		    if (nextItem != null) {
				nextItem = nextItem.trim();
				if (!nextItem.equals ("")){
				    InputStream xmlStream = new ByteArrayInputStream(nextItem.getBytes());
	
				    try {
					xmlDoc = saxb.build(xmlStream);
					Element rootElement = xmlDoc.getRootElement();
					String name = rootElement.getName();

					if (name.equals("encrypted")) {
						logger.log(Level.FINER,"An encrypted packet has been received.");
						String data = rootElement.getText();
						byte[] decryptedPacket = null;
						byte[] srcBytes = data.getBytes(); 
						for (int i = 0; i < data.length() ; i +=decrypter.BLOCK_SIZE){
								//byte[] decryptedPacket = decrypter.engineCrypt
									//(data.substring(i * decrypter.BLOCK_SIZE, (i + 1) * decrypter.BLOCK_SIZE -1).getBytes(),i);
								decryptedPacket = decrypter.engineCrypt (srcBytes,i);
	
	
						}
							
						xmlDoc = saxb.build(data);
						rootElement = xmlDoc.getRootElement(); 
						processXML(rootElement); 
					}
					
			    } catch (JDOMException ex){
			    	logger.log (Level.WARNING,"XML message from Flash client was invalid " + ex.getMessage()); 
			    } catch (ArrayIndexOutOfBoundsException ex){
					logger.log (Level.WARNING,"Flash sent an invalid encrypted message"); 
			    }
				
				}  
		    } else {
	    		try {
	    			Thread.sleep(500); // hang around for a short time
	    		} catch (InterruptedException e) {

	    		}

		    }
		} catch (IOException ex){
		    thisThreadRunning = false;
		    logger.log(Level.FINER,"IO Exception communicating with client");
		} 
		    
		Thread.yield(); // ensure another process always has a chance
	 }
 
    }
    
    /**
    @TODO properly return a message block
    **/
    
    public void processBuffer(String readBuffer)
    
    {
	SAXBuilder saxb = new SAXBuilder(false); //get a SAXBuilder
	Document xmlDoc;           // xml document object to work with
	
	logger.log(Level.FINEST,"Received string from client, processing");
	// the array sent to the XML builder cannot have any extra space at the end
	// so we create a new array and copy everything accumulated in "readBuffer"
	
	
	try {
	    xmlDoc = saxb.build(new StringReader(readBuffer));
	    Element rootElement = xmlDoc.getRootElement();
	    processXML(rootElement);
	} catch (JDOMException ex) {
	    logger.log(Level.WARNING,"XML ERROR " + ex.getMessage());
	    /*
	    Element error = new Element("error");
	    error.setAttribute("msg", "JDOM parsing error");
	    Document replyDoc = new Document(error);
	    sendXML (replyDoc);
	     **/
	} catch (IOException io){
	    logger.log(Level.SEVERE, "IO failed communicating with client " + io.getMessage());
	    this.clientList.remove(this);
	}
    }
    
    /**
    @TODO properly return a message block
    **/
    
     public void processBuffer(byte [] readBuffer, int count)
    
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
	
	try {
	    xmlDoc = saxb.build(bais);
	    Element rootElement = xmlDoc.getRootElement();
	    processXML(rootElement);
	} catch (JDOMException ex) {
	    logger.log(Level.WARNING,"XML ERROR " + ex.getMessage());
	    /*
	    String badElement = new String(xmlByte);
	    System.out.println(badElement);
	    Element error = new Element("error");
	    error.setAttribute("msg", "JDOM parsing error, illegal message from the Client");
	    Document replyDoc = new Document(error);
	    sendXML (replyDoc);
	     */
	} catch (IOException io){
	    logger.log(Level.SEVERE, "IO failed communicating with client");
	    this.clientList.remove(this);
	}
    }
    
    public void setMacroHandler(MacroHandler macroHandler){
	this.macroHandler = macroHandler;
    }
    
 
    /**
     * Process the XML document sent from the client
     * @param xmlDoc A Sax representation of the document
     */
    protected void processXML(Element rootElement){
	
	String name = ""; // the name of the node
	String key = "";
	boolean commandBuilt = false;
	
	name = rootElement.getName();
	logger.log(Level.FINER,"ELEMENT "+ name);

	if (name.equals("CONTROL")) {
	    key = rootElement.getAttributeValue("KEY");
	    if (key != null){
		ClientCommand clientCommand = null;
		if (!commandBuilt && key.equals("KEYPAD")){
		    clientCommand = buildKeyPress(key,rootElement);
		    commandBuilt = true;
		}
		if (!commandBuilt && key.equals("ID")){
		    String command = rootElement.getAttributeValue("COMMAND");
		    String extra = rootElement.getAttributeValue("EXTRA");
		    if (command.equals("name")) {
			synchronized (addressBook) {
			    addressBook.setName(extra,this.getID());
			}
		    }
		    if (command.equals("user")) {
			synchronized (addressBook) {
			    addressBook.setUser(extra,this.getID());
			}
		    }
		    commandBuilt = true;
		}
		if (!commandBuilt && clientCommand == null) {
		    clientCommand = buildCommand(key,rootElement);
		    commandBuilt = true;
		}
		if (clientCommand != null) {
		    clientCommand.originatingID = this.getID();
		    clientCommand.setMessageFromFlash(rootElement);
		    synchronized (commandList){
			commandList.add(clientCommand);
			commandList.notifyAll();
		    }
		}
	    }
	}
	if (name.equals("MESSAGE")) {
	    ClientCommand clientCommand = buildMessage(rootElement);
	    clientCommand.originatingID = this.getID();
	    clientCommand.setMessageFromFlash(rootElement);
	    clientCommand.setBroadcast(false);
	    synchronized (commandList){
		commandList.add(clientCommand);
		commandList.notifyAll();
	    }
	}
	
	if (name.equals("LOGIN")) {
	    String userName = (rootElement.getAttribute("USER")).getValue();
	    String password = (rootElement.getAttribute("PASSWORD")).getValue();
	    User user = new User(userName,password);
	    this.setUser(user);
	}
	if (name.equals("MACROS")) {
	    ClientCommand clientCommand = new ClientCommand();
	    clientCommand.setMessageFromFlash(rootElement);
	    clientCommand.setKey("MACRO");
	    clientCommand.setCommand("saveList");
	    
	    clientCommand.originatingID = this.getID();
	    clientCommand.setMessageFromFlash(rootElement);
	    synchronized (commandList){
		commandList.add(clientCommand);
		commandList.notifyAll();
	    }
	}
    }
    
    public ClientCommand buildKeyPress(String key, Element rootElement){
	String name = ""; // the name of the node
	String extra ="";
	
	Attribute extraAttribute = rootElement.getAttribute("EXTRA");
	if (extraAttribute != null) extra = extraAttribute.getValue();
	logger.log(Level.FINEST,"key "+ extra);
	ClientCommand clientCommand = new ClientCommand("SYSTEM","Keypress",user,extra);
	return clientCommand;
	
    }
    public ClientCommand buildMessage(Element rootElement){
	String name = ""; // the name of the node
	ClientCommand newCommand = new ClientCommand();
	newCommand.setKey("MESSAGE");
	newCommand.setDisplayName("MESSAGE");
	newCommand.setMessageType(MessageCommand.Message);
	
	String title =rootElement.getAttributeValue("TITLE");
	if (title == null) title = "";
	newCommand.setTitle(title);
	
	String hideClose =rootElement.getAttributeValue("HIDECLOSE");
	if (hideClose == null) hideClose = "";
	newCommand.setHideclose(hideClose);
	
	String autoClose = rootElement.getAttributeValue("AUTOCLOSE");
	if (autoClose == null) autoClose = "";
	newCommand.setAutoclose(autoClose);
	
	String icon = rootElement.getAttributeValue("ICON");
	if (icon == null) icon = "";
	newCommand.setIcon(icon);
	
	String content = rootElement.getAttributeValue("CONTENT");
	if (content == null) content = "";
	newCommand.setContent(content);
	
	String target =rootElement.getAttributeValue("TARGET");
	if (target == null) target = "";
	newCommand.setTarget(target);
	
	String targetUser =rootElement.getAttributeValue("TARGET_USER");
	if (targetUser == null) targetUser = "";
	newCommand.setTargetUser(targetUser);
	
	return newCommand;
    }
    
    public ClientCommand buildCommand(String key,Element rootElement){
	String name = ""; // the name of the node
	String command =rootElement.getAttributeValue("COMMAND");
	if (command == null) command = "";
	String extra = rootElement.getAttributeValue("EXTRA");
	if (extra == null) extra = "";
	String extra2 = rootElement.getAttributeValue("EXTRA2");
	if (extra2 == null) extra2 = "";
	String extra3 = rootElement.getAttributeValue("EXTRA3");
	if (extra3 == null) extra3 = "";
	String extra4 = rootElement.getAttributeValue("EXTRA4");
	if (extra4 == null) extra4 = "";
	String extra5 = rootElement.getAttributeValue("EXTRA5");
	if (extra5 == null) extra5 = "";
	logger.log(Level.FINER,"DISPLAY_NAME=" + key + " Command="+ command + " extra=" + extra);
	ClientCommand clientCommand = new ClientCommand(key,command,user,extra,extra2,extra3,extra4,extra5);
	return clientCommand;
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
    
    public AddressBook getAddressBook() {
	return addressBook;
    }
    
    public void setAddressBook(AddressBook addressBook) {
	this.addressBook = addressBook;
    }
    
    public long getConnectionTime() {
	return connectionTime;
    }
    
    public void setConnectionTime(long connectionTime) {
	this.connectionTime = connectionTime;
    }
    
    public long getServerID() {
	return serverID;
    }
    
    public void setServerID(long serverID) {
	this.serverID = serverID;
    }
    
    public boolean isThisThreadRunning() {
	return thisThreadRunning;
    }
    
    public void setThisThreadRunning(boolean thisThreadRunning) {
	this.thisThreadRunning = thisThreadRunning;
    }
    
}
