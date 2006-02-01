/*
 * Created on Feb 16, 2004
 *
 */
package au.com.BI.Flash;
import java.net.*;
import java.io.*;
import java.util.logging.*;
import java.util.*;
import org.jdom.*;
import org.jdom.input.SAXBuilder;

import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Comms.*;
import au.com.BI.User.*;
import au.com.BI.Command.*;
import org.jdom.output.*;
import au.com.BI.Macro.*;
import au.com.BI.Messaging.*;


/**
 * @author Colin Canfield
 *
 **/
public class FlashClientHandler extends Thread
{
	protected Logger logger;
	protected Socket clientConnection;
	protected boolean thisThreadRunning;
	protected InputStream i;
	protected OutputStream o;
	protected User user;
	protected List commandList;
	protected long ID;
	protected au.com.BI.Command.Cache cache;
	protected MacroHandler macroHandler = null;
	protected boolean remoteServer = false;
	protected EventCalendar eventCalendar;
	protected AddressBook addressBook;
	protected long connectionTime;
	protected long serverID;
	
	protected List clientList; // used to remove this thread in case of disaster
	protected XMLOutputter xmlOut;
	protected BufferedReader rd;
	
	public FlashClientHandler (Socket connection,List commandList, List clientList,AddressBook addressBook) throws ConnectionFail {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		clientConnection = connection;
		this.addressBook = addressBook;
		this.commandList = commandList;
		this.setName("Flash Client Handler");
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
	
	public void run ()
	{
		logger.info("Client connection received. Handler started");
		thisThreadRunning = true;
		byte[] buf = new byte[0];  // buffer to read data off the input stream
		int leftOverCount = 0;     // counter for any data still in "buf" after detecting "null"
		int bufMarker = 0;         // counter to mark place in "buf"
		int avail = 0;             // the number of bytes available to be read
		int len = 0;               // the number of bytes actually read
		int readBufLength = 50000;

		doStartupCacheItems();
		
		while (thisThreadRunning)
		{
			// xml data is added to readbuffer once a full xml message
			// (null terminated) has been recieved 
			// maximum message size is set below -- currently 2k
			byte[] readBuffer = new byte[readBufLength];
			int count = 0;         // number of bytes written to readBuffer

			// endflag is set to true when we see a "null" byte
			
			boolean endFlag = false;
			
			do {
				endFlag = false;
				count = 0;

				if (leftOverCount == 0) {	
					//add available characters to byte collection
					try 
					{
						avail = i.available();    
						if (avail > 0) 
						{
							buf = new byte[avail];    //size the buffer based on the number of available bytes
							len = i.read(buf);        //read() returns the number of bytes actually read
							avail = len;              //make sure we don't try to read data that isn't there 	
						}
						bufMarker = 0;
					} catch (IOException io){
						logger.log(Level.WARNING,"IO Exception reading from client");
					}
				}
				else {
					//read leftover data

					avail = leftOverCount;
					bufMarker = len - leftOverCount;
				}	

				if (avail > 0)
				{
					// if we found something
					int bufLength = bufMarker+avail;
					
					//loop from our current place to the end of "buf"
					for (int i=bufMarker; i<bufLength ;i++ ) {
						if ((int) buf[i] <= 0) {
							
							leftOverCount = (bufMarker + avail - i) - 1; // compute number of extra bytes in "buf"
							endFlag = true; //set end of XML message flag
							avail = i - bufMarker; //re-compute the actual number of bytes to read since EOM was reached
							break; // do not continue reading "buf"
						}
						
						if (i == bufLength -1) {
						    endFlag = true;
						}

					}
					if (count + avail > readBufLength) {
						readBufLength += 50000;
						byte [] newReadBuffer = new byte[readBufLength];
						System.arraycopy (newReadBuffer,0,readBuffer,0,readBuffer.length);
						readBuffer = newReadBuffer;
					}
									// copy the contents we just examined from "buf" to our "readBuffer"
					System.arraycopy(buf,bufMarker,readBuffer,count,avail);
					count += avail;
				}

				if (!endFlag) {
					try {
					    if (i.available() == 0) {
					        Thread.sleep(200); // give the CPU a break
					    }
					} catch (InterruptedException e) {
					} catch (IOException e) {
				    }
					
					Thread.yield(); // ensure another process always has a chance
				}
			} while(!endFlag && thisThreadRunning); //keep going until EOM
		
			if (count > 0 && thisThreadRunning)
				processBuffer (readBuffer,count);
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
			sendXML (replyDoc);
		}
		catch (IOException io){
			logger.log(Level.SEVERE, "IO failed communicating with client " + io.getMessage());
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
			sendXML (replyDoc);
		}
		catch (IOException io){
			logger.log(Level.SEVERE, "IO failed communicating with client");
			this.clientList.remove(this);
		}
	}
	
	public void setMacroHandler (MacroHandler macroHandler){
		this.macroHandler = macroHandler;
	}
	
	protected void doStartupCacheItems () {

		if (cache == null) {
			logger.log (Level.WARNING,"Do Startup Cache Items called in flash, but cache has not yet been initialised");
			return;
		}
		try {
			Iterator startupItemList = cache.getStartupItemList();
			String key = "";
			CacheWrapper cachedObject = null;
			while (startupItemList.hasNext()){
				try {
					key = (String)startupItemList.next();
					cachedObject = cache.getCachedObject(key); 
					if (cachedObject == null) {
						logger.log (Level.FINE,"Cache returned a null object for key " + key);
						continue;
					}
				} catch (ClassCastException ex) {
					logger.log (Level.WARNING,"Cache key object is not a string " + ex.getMessage());
				}
				// logger.log (Level.WARNING,"object from cache for " + key + " is " + cachedObject.toString());
					// Cached items are sets if the device requires all instances of the command to be cached
					// cacheAllCommands returned true.
					// For example, on audio when mute on / off is transmitted seperately to volume up / down 
					// for the same audio device.
				if (cachedObject.isSet()) {
					Collection commandList = cache.getSetElements((cachedObject));
					Iterator commandListIt = commandList.iterator();
					while (commandListIt.hasNext()){
						Object theCommand = commandListIt.next();
						try {
							if (!doCacheItem ((Command)theCommand)) {
								logger.log (Level.FINE,"Client has disapeared, aborting startup");
								break;
							}
						} catch (ClassCastException ex) {
							logger.log (Level.FINE,"Cache item was marked as set, but was actually simple " + ex.getMessage());
						} catch (Exception ex) {
							logger.log (Level.FINE,"An unknown error occurred running doChacheItem on " + theCommand.toString());
						}
						
					}

				} else {
						try {
							if (!doCacheItem (cachedObject.getCommand())) {
								logger.log (Level.FINE,"Client has disapeared, aborting startup");
								break;
							}
						} catch (ClassCastException ex) {
							logger.log (Level.FINE,"Cache item was marked as set, but was actually simple " + ex.getMessage());
						}
					}
				}
		} catch (Exception ex) {
			logger.log (Level.WARNING,"Exception on client startup " + ex.getMessage());
		}
	}
	
	public boolean doCacheItem (CommandInterface command) {
		Element message = command.getXMLCommand();
		if (!this.sendXML(new Document (message))) 
			return false;
		else 
			return true;
	}
	
	protected void setCache (au.com.BI.Command.Cache cache){
		this.cache = cache;
	}

	
	/**
	 * Process the XML document sent from the client
	 * @param xmlDoc A Sax representation of the document
	 */
	protected void processXML (Document xmlDoc){

		String name = ""; // the name of the node
		String key = "";
		boolean commandBuilt = false;
		
		Element rootElement = xmlDoc.getRootElement(); 
		name = rootElement.getName();
		logger.log (Level.FINER,"ELEMENT "+ name);
		
		if (name.equals("CONTROL")) {
			key = rootElement.getAttributeValue("KEY");
			if (key != null){
				ClientCommand clientCommand = null;
				if (!commandBuilt && key.equals ("KEYPAD")){
					clientCommand = buildKeyPress (key,rootElement);
					commandBuilt = true;
				} 
				if (!commandBuilt && key.equals ("ID")){
					String command = rootElement.getAttributeValue("COMMAND");
					String extra = rootElement.getAttributeValue("EXTRA");
					if (command.equals("name")) {
						synchronized (addressBook) {
							addressBook.setName (extra,this.getID());
						}
					}
					if (command.equals("user")) {
						synchronized (addressBook) {
							addressBook.setUser (extra,this.getID());
						}
					}
					commandBuilt = true;
				} 
				if (!commandBuilt && clientCommand == null) {
						clientCommand = buildCommand (key,rootElement);
						commandBuilt = true;
				}
				if (clientCommand != null) {
					clientCommand.originatingID = this.getID();
					clientCommand.setMessageFromFlash(rootElement);
					synchronized (commandList){
						commandList.add (clientCommand);
						commandList.notifyAll ();
					}
				}
			}
		}
		if (name.equals("MESSAGE")) {
			ClientCommand clientCommand = buildMessage (rootElement);
			clientCommand.originatingID = this.getID();
			clientCommand.setMessageFromFlash(rootElement);
			clientCommand.setBroadcast(false);
			synchronized (commandList){
				commandList.add (clientCommand);
				commandList.notifyAll ();
			}
		}

		if (name.equals("LOGIN")) {
			String userName = (rootElement.getAttribute("USER")).getValue();
			String password = (rootElement.getAttribute("PASSWORD")).getValue();
			User user = new User (userName,password);
			this.setUser (user);
		}
		if (name.equals("MACROS")) {
			ClientCommand clientCommand = new ClientCommand();
			clientCommand.setMessageFromFlash(rootElement);
			clientCommand.setKey("MACRO");
			clientCommand.setCommand("saveList");

			clientCommand.originatingID = this.getID();
			clientCommand.setMessageFromFlash(rootElement);
			synchronized (commandList){
				commandList.add (clientCommand);
				commandList.notifyAll ();
			}			
		}
	}
	
	public ClientCommand buildKeyPress (String key, Element rootElement){
		String name = ""; // the name of the node
		String extra ="";	
		
		Attribute extraAttribute = rootElement.getAttribute("EXTRA");
		if (extraAttribute != null) extra = extraAttribute.getValue();
		logger.log (Level.FINEST,"key "+ extra);
		ClientCommand clientCommand = new ClientCommand ("SYSTEM","Keypress",user,extra);
		return clientCommand;

	}
	public ClientCommand buildMessage (Element rootElement){
		String name = ""; // the name of the node
		ClientCommand newCommand = new ClientCommand ();
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
	
	public ClientCommand buildCommand (String key,Element rootElement){
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
		logger.log (Level.FINER,"DISPLAY_NAME=" + key + " Command="+ command + " extra=" + extra);
		ClientCommand clientCommand = new ClientCommand (key,command,user,extra,extra2,extra3,extra4,extra5);
		return clientCommand;
	}
	
	public boolean sendXML (Document xmlDoc) {
		try	 {
			synchronized (this.o) {
				xmlOut.output(xmlDoc, this.o) ;
				this.o.write (0);
				this.o.flush();
				return true;
			}
		}
		catch (IOException ex)
		{
			logger.log (Level.FINER, "IO Exception talking to client " + this.ID + " : " + ex.getMessage());
			thisThreadRunning = false;
			return false;
		}
	}	


	public boolean sendXML (String xmlDoc) {
		try	 {
			synchronized (this.o) {
				this.o.write (xmlDoc.getBytes());
				this.o.write(0);
				this.o.flush();
				return true;
			}
		}
		catch (IOException ex)
		{
			logger.log (Level.FINER, "IO Exception talking to client " + ex.getMessage());
			thisThreadRunning = false;
			return false;
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

}
