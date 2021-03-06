/*
 * Created on Feb 15, 2004
 *
 */
package au.com.BI.Flash;

import au.com.BI.Command.*;
import au.com.BI.Config.Security;
import au.com.BI.Comms.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.User.User;
import au.com.BI.Util.*;
import au.com.BI.Macro.*;

import java.util.*;
import org.jdom.*;
import org.jdom.input.SAXBuilder;
import org.jdom.output.*;
import java.util.logging.*;
import java.io.*;
/**
 * @author Colin Canfield
 *
 **/
public class FlashHandler extends SimplifiedModel implements DeviceModel, ClientModel
{
	protected LinkedList <FlashClientHandler>flashClientHandlers; 
	protected FlashControlListener flashControlListener;


	protected HashMap parameters;
	private Security security;

	public int connectionType = DeviceModel.IP;
	public String IPAddress = "";
	public String devicePort = "10000";

	protected int instanceID;

	protected Map rawDefs;


	/**
	 * Sets up the client handling system
	 * @param numberClients An indicative number of clients,
	 * the actual number may be larger than this
	 */
	public FlashHandler (int numberClients, Security security){

		this.addControlledItem ("RawXML_Send",null,MessageDirection.FROM_HARDWARE);

		logger = Logger.getLogger(this.getClass().getPackage().getName());
		flashClientHandlers = new LinkedList <FlashClientHandler> ();
		rawDefs = new HashMap (NUMBER_CATALOGUES);
		parameters = new HashMap (NUMBER_PARAMETERS);
		this.security = security;
		this.setName("Flash");
        this.setAutoReconnect(false);
	}

    public void setParameter(String name, Object value) {
		parameters.put(name,value);
	}

	public Object getParameter (String Name){
		return parameters.get(name);
	}

	public void setCommandQueue (CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}

	public void attatchComms(CommandQueue commandQueue) {
		// meaningless for this
	}

	public void setCache (au.com.BI.Command.Cache cache){
		this.cache = cache;
	}

	public void setMacroHandler (MacroHandler macroHandler){
		this.macroHandler = macroHandler;
	}

	public boolean touchPanel () {
		return true;
	}

	// Ensure listening will restart after a config reload.

	public void startListenning (String address, int portNumber) throws CommsFail  {
	    if (flashControlListener != null ) {
	        flashControlListener.stopRunning();
	    }

		flashControlListener = new FlashControlListener (flashClientHandlers, portNumber,address,
				commandQueue,this.getVersionManager(),security,addressBook);
		flashControlListener.setCache(cache);
		flashControlListener.setMacroHandler (macroHandler);
		flashControlListener.setServerID(serverID);
		flashControlListener.start();
	}



	public boolean reEstablishConnection (){
		return true;
		// restart everything
	}

	public void addControlledItem (String name, DeviceType details, MessageDirection controlType) {
		configHelper.addControlledItem (name, details, controlType);
	}


	public void clearItems () {
		configHelper.clearItems();
	}


	/**
	 Closes the connection	 */
	public void closeComms() throws ConnectionFail {
	    if (flashControlListener != null)
	        flashControlListener.stopRunning ();
	}

	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		return configHelper.checkForControl(keyName);
	}

	public void broadcastCommand (CommandInterface command){
		Element message = command.getXMLCommand();
		String key = command.getKey();
		String commandCode = command.getCommandCode();

		try {
			if (command.getTargetDeviceID() != 0)
			    flashControlListener.sendToOneClient (new Document (message),command.getTargetDeviceID());
			else {
			    if (key.startsWith("AV:") || (key.equals ("MACRO") && commandCode.equals ("getList"))||
			            key.equals ("CALENDAR") && commandCode.equals("getEvents"))  return;
			    flashControlListener.sendToAllClients (new Document (message),((ClientCommand)command).getOriginatingID());
			}
		} catch (IllegalAddException ex){
			logger.log (Level.WARNING,"Content was attempted to be sent to two clients rather than local copies made." + ex.getMessage());
		}
	}

	public void doCommand (CommandInterface command) {
		String theKey = command.getKey();
		boolean commandFound = false;

		if (theKey.equals ("RawXML_Send")) {
			logger.log( Level.FINER,"Sending raw XML to all clients " +(String)command.getExtraInfo());
			commandFound = true;
			SAXBuilder builder =new SAXBuilder();
			try {
				Document xmlDoc = builder.build(new StringReader((String)command.getExtraInfo()));
				flashControlListener.sendToAllClients (xmlDoc,-1);
			} catch (IOException error) {
				logger.log (Level.SEVERE,"Error in reading RAW XML");
			} catch (JDOMException error) {
				logger.log (Level.SEVERE,"Error in reading RAW XML");
			}
		}


		if (!commandFound && theKey.equals ("CLIENT_SEND")) {
			Element xmlCommand;
			commandFound = true;

			if (command.getDisplayName() == null ) {
				logger.log (Level.SEVERE,"No display name was specifed for command with key " + command.getKey());
				xmlCommand = null;
			}
			else {
				xmlCommand = command.getXMLCommand ();
				xmlCommand.setAttribute("KEY", command.getDisplayName());
			}


			if (xmlCommand != null){
				if (logger.isLoggable(Level.FINER)){
					XMLOutputter outputter = new XMLOutputter ();
					String stringVersion = outputter.outputString (xmlCommand);
					logger.log( Level.FINER,"Sending XML to client " + stringVersion);
				} else {
					if (logger.isLoggable(Level.FINE)){
						logger.log( Level.FINE,"Sending XML to " + command.getDisplayName());
					}

				}
				if (command.getTargetDeviceID() > 0)
				    flashControlListener.sendToOneClient (xmlCommand,command.getTargetDeviceID());
				else
				    flashControlListener.sendToAllClients (xmlCommand,-1);
			}
		}

		if (!commandFound && false) {
			// command is input on the flash client so need to create a command for the home controller to action it
			DeviceType controlRaw  = configHelper.getControlItem(theKey);

			try {
				DeviceType control;

				control  = (DeviceType)controlRaw;

				commandFound = true;
				Command automationCommand = new Command (control.getName(),command.getCommandCode(),command.getUser(),command.getExtraInfo());
				logger.log( Level.FINEST,"Sending automation command to " + automationCommand.getKey() + " " + automationCommand.getCommandCode());
				synchronized (commandQueue) {
					commandQueue.add (automationCommand);
				}
			} catch (ClassCastException ex) {}
			//commandQueue.notifyAll(); not running as a thread
		}

		if (!commandFound && false){
			// possibly a variable CC FIX THIS
			Command automationCommand = new Command ("",command.getCommandCode(),command.getUser(),command.getExtraInfo());
			logger.log( Level.FINEST,"Sending automation commnd to " + automationCommand.getKey() + " " + automationCommand.getCommandCode());
			synchronized (commandQueue) {
				commandQueue.add (automationCommand);
			}
		}
	}

	/** provide a login metod
	 * @see au.com.BI.Util.DeviceModel#login(au.com.BI.User.User)
	 */
	public int login(User user) throws CommsFail
	{
		return SUCCESS;
	}

	/** provide a non functional logout method
	 */
	public int logout(User user) throws CommsFail
	{
		return SUCCESS;
	}

	/**
	 * @return Returns the connectionType.
	 */
	public final int getConnectionType() {
		return connectionType;
	}
	/**
	 * @param connectionType The connectionType to set.
	 */
	public final void setConnectionType(int connectionType) {
		this.connectionType = connectionType;
	}

	public void addStartupQueryItem (String name, Object details, int controlType){};
	

	public boolean isConnected () {
		return true;
	}

	private final Security getSecurity() {
		return security;
	}

	public final void setSecurity(Security security) {
		this.security = security;
	}

	
}
