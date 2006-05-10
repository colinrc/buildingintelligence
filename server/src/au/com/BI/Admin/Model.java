/*
 * Created on Feb 15, 2004
 *
 */
package au.com.BI.Admin;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.User.User;
import au.com.BI.Util.*;

import java.util.*;

import org.jdom.*;

import java.util.logging.*;

import au.com.BI.Flash.*;
/**
 * @author Colin Canfield
 *
 **/
public class Model extends BaseModel implements DeviceModel, ClientModel
{
	protected LinkedList adminClientHandlers;
	protected AdminControlListener adminControlListener;
	
	
	protected Logger logger;
	
	public int connectionType = DeviceModel.IP;
	public String IPAddress = "";
	public String devicePort = "10001";
	protected Level defaultDebugLevel = Level.INFO;
	
	protected int InstanceID;
	protected HashMap modelRegistry;
	protected au.com.BI.IR.Model irLearner;
	protected LogHandler logHandler;
	
	
	/**
	 * Sets up the client handling system
	 * @param numberClients An indicative number of clients,
	 * the actual number may be larger than this
	 */
	public Model (int numberClients){
		
		configHelper = new ConfigHelper();
		this.addControlledItem ("RawXML_Send",null,DeviceType.MONITORED);
		
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		adminClientHandlers = new LinkedList ();
		rawDefs = new HashMap (NUMBER_CATALOGUES);
		parameters = new HashMap (NUMBER_PARAMETERS);
		this.setName("Admin");
        this.setAutoReconnect(false);
	}
	
	public boolean removeModelOnConfigReload () {
		return false;
	}
        
	public void attatchComms() {
		// meaningless for this
	}
	
        
	public void setIrLearner (DeviceModel irLearner) {
		this.irLearner = (au.com.BI.IR.Model)irLearner;
	}
	
	
	// Ensure listening will restart after a config reload.
	
	public void startListenning (String address, int devicePort) throws CommsFail  {
		if (adminControlListener != null ) {
			adminControlListener.stopRunning();
		}
		
		adminControlListener = new AdminControlListener (adminClientHandlers, devicePort,address,commandQueue,
				this.defaultDebugLevel, modelRegistry,bootstrap.getStartTime(),bootstrap.getConfigEntry(),
				bootstrap.getLogDir(),irLearner,logHandler);
		adminControlListener.setModelList(modelList);
		adminControlListener.start();
	}
	
	public boolean reEstablishConnection (){
		return true;
		// restart everything
	}
	

	/** General hook for a device to do any final startup once the configuration is cloaded */
	public void finishedReadingConfig () throws SetupException {
		AdminDevice admin = new AdminDevice();
		
		this.addControlledItem ("ADMIN",admin,DeviceType.OUTPUT);
	}
	
	
	public void clearItems () {
		configHelper.clearItems();
	}
	
	
	/**
	 Closes the connection	 */
	public void closeComms() throws ConnectionFail {
		if (false && adminControlListener != null)
			adminControlListener.stopRunning ();
	}
	
	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		return configHelper.checkForControl(keyName);
	}
	
	public void broadcastCommand (CommandInterface command){
		Element message = command.getXMLCommand();
		
		if (command.getTargetDeviceID() != 0)
			adminControlListener.sendToOneClient (new Document (message),command.getTargetDeviceID());
		else {
			adminControlListener.sendToAllClients (new Document (message),((ClientCommand)command).getOriginatingID());
		}
	}
	
	public void doCommand (CommandInterface command) {
		String theKey = command.getKey();
		boolean commandFound = false;
		
		
		if (!commandFound && theKey.equals("IR_INTERNAL")) {
			if (command.getCommandCode().equals("Learnt")) {
				logger.log (Level.INFO,"IR command learnt, sending confirmation to client");
				Element newIRDB = new Element ("IR_LEARNT");
				newIRDB.setAttribute("RESULT","Success : learnt " + command.getExtraInfo());
				this.irCodeDB.addIRElements(newIRDB);
				adminControlListener.sendToAllClients (newIRDB,-1);
				
			}
			if (command.getCommandCode().equals("EndChanged")) {
				logger.log (Level.INFO,"Setting IR end timeout confirmation");
				Element newIRDB = new Element ("IR_CHANGED");
				newIRDB.setAttribute("RESULT","IR learner timeout updated.");
				adminControlListener.sendToAllClients (newIRDB,-1);
				
			}
			
		}
		
		
		if (!commandFound && theKey.equals("ADMIN")) {
			logger.log (Level.FINEST,"Sending admin response.");
			
			if (command.getCommandCode().equals("List_Devices")) {
				commandFound = true;
				sendIRDeviceList();
			}
			if (command.getCommandCode().equals("List_Actions")) {
				commandFound = true;
				sendActionList(command.getExtraInfo());
			}
			
			if (!commandFound){
				Element xmlCommand = command.getXMLCommand();
				if (xmlCommand != null)
					try {
						
						adminControlListener.sendToAllClients (xmlCommand,0);
					} catch (IllegalAddException ex){
						logger.log (Level.WARNING,"Could not set admin response XML " + ex.getMessage());
					}
			}
		}
	}
	
	
	public void sendActionList (String device) { 
		Set actionList = this.irCodeDB.getActions (device);
		Element returnXML = new Element("IR_ACTION_LIST");
		if (actionList != null){
			Iterator eachAction = actionList.iterator();
			while (eachAction.hasNext()) {
				String actionName = (String)eachAction.next();
				Element newItem = new Element ("IR_ACTION_ITEM");
				newItem.setAttribute("NAME",actionName);
				returnXML.addContent(newItem);
			}
		}
		adminControlListener.sendToAllClients (returnXML,0);
	}
	
	public void sendIRDeviceList() {
		Set deviceList = irCodeDB.getDevices();
		Element returnXML = new Element("IR_DEVICE_LIST");
		if (deviceList != null){
			Iterator eachDevice = deviceList.iterator();
			while (eachDevice.hasNext()) {
				String actionName = (String)eachDevice.next();
				Element newItem = new Element ("IR_DEVICE_ITEM");
				newItem.setAttribute("NAME",actionName);
				returnXML.addContent(newItem);
			}
		}
		adminControlListener.sendToAllClients (returnXML,0);
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
	
	/**
	 * Sets the list of all known models in the system
	 * @param modelRegistry
	 */
	public void setModelRegistry (HashMap modelRegistry) {
		this.modelRegistry = modelRegistry;
	}
	
	/**
	 * @return Returns the logger.
	 */
	public Logger getLogger() {
		return logger;
	}
	/**
	 * @param logger The logger to set.
	 */
	public void setLogger(Logger logger) {
		this.logger = logger;
	}
	/**
	 * @return Returns the logHandler.
	 */
	public LogHandler getLogHandler() {
		return logHandler;
	}
	/**
	 * @param logHandler The logHandler to set.
	 */
	public void setLogHandler(LogHandler logHandler) {
		this.logHandler = logHandler;
	}
	
	
	public boolean isConnected () {
		return true;
	}
	
}
