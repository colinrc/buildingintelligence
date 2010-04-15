package au.com.BI.Integra;

import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ParameterException;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.SimplifiedModel;
import au.com.BI.Util.DeviceModel;

public class Model extends SimplifiedModel implements DeviceModel {

	//protected HashMap <String,AVState>state;
	protected Logger logger = null;
	protected IntegraHelper integraHelper = null;
	protected String deviceModel = null;	// the model number of the hardware
	
	/**
	 * Std constructor
	 * Initializes 
	 */
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		//state = new HashMap<String,AVState>();
	}
	/**
	 * Clears the state map and the config
	 */
	public void clearItems () {
		//state.clear();
		super.clearItems();
	}
	/**
	 * Add all of the state objects 
	 
	public void prepareToAttatchComms() {
		for (DeviceType avDevice : configHelper.getAllOutputDeviceObjects()){
			String key  = avDevice.getKey();
			state.put(key, new AVState());
		}
	}
	*/
	/**
	 * Get the Integra model string
	 */
	public void finishedReadingParameters () {
		super.finishedReadingParameters();

		deviceModel = getParameterValue("MODEL", DeviceModel.MAIN_DEVICE_GROUP);
		String line = this.getParameterValue("Connection_Type",DeviceModel.MAIN_DEVICE_GROUP);
		integraHelper = new IntegraHelper(logger, deviceModel,line);
		if (line.equals("IP"))
			setInterCommandInterval(500);
		else
			setInterCommandInterval(75);			
	}
	/**
	 * Startup method called to get the class ready
	 * clears the comms and deals with the XML config
	 */
	public void doStartup() throws CommsFail {
		
		synchronized (comms) {
			comms.clearCommandQueue();
		}
		
		for (DeviceType avDevice : configHelper.getAllOutputDeviceObjects()){
			String strCmd = null;
			// loop through the device config initializing the devices
			strCmd = buildOutputString(avDevice, "mute", "query");
			if (strCmd != null)
				comms.sendString(strCmd);
			strCmd = buildOutputString(avDevice, "volume", "query");
			if (strCmd != null)
				comms.sendString(strCmd);
			strCmd = buildOutputString(avDevice, "power", "query");
			if (strCmd != null)
				comms.sendString(strCmd);
			strCmd = buildOutputString(avDevice, "src", "query");
			if (strCmd != null)
				comms.sendString(strCmd);
			// FIXME may need to change preset to something else...
			strCmd = buildOutputString(avDevice, "preset", "query");
			if (strCmd != null)
				comms.sendString(strCmd);
		}
	}
	/**
	 * Sends a command on the serial port to the Integra device
	 * @param command 	The command from flash or other client
	 * @throws CommsFail throws from the comms classes if something goes very wrong 
	 */
	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		DeviceType device  = configHelper.getOutputItem(theWholeKey);
		String toSend = null;
		
		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			cache.setCachedCommand(command.getKey(),command);

			String theCommand = command.getCommandCode();
			String extra = ((String)command.getExtraInfo());

			toSend = buildOutputString(device, theCommand, extra);
			if (toSend != null && !toSend.isEmpty()) {

				logger.log(Level.FINER, "Integra event for zone " + device.getKey() + " received from flash");
				comms.sendString(toSend);
				logger.log (Level.FINEST,"Sent integra command " + toSend);
			}
			else {
				logger.log (Level.WARNING,"Error processing Integra message, no message to send");
			}
		}
	}
	/**
	 * Given a command get the device it corresponds to
	 * @param command	Input command string
	 * @return	Device of interest
	 */
	DeviceType getDevice(String command){
		String key = integraHelper.getDeviceKey(command);
		if (key.equals(""))
			return null;
		return configHelper.getControlItem(formatKey(key, null));
	}
	/**
	 * 
	 * @param srcCode
	 * @param catalogName
	 * @param device
	 * @return
	 * @throws ParameterException
	 */
	public String getKeyForParameterValue(String srcCode, String catalogName,
			DeviceType device) throws ParameterException {

		String groupName = device.getGroupName();
		String paramMapName = getParameterValue(catalogName, groupName);
		Map<String, String> inputParameters = getCatalogueDef(paramMapName);
		String returnVal = "";

		for (String eachItem : inputParameters.keySet()) {
			if (inputParameters.get(eachItem).equals(srcCode)) {
				returnVal = eachItem;
				break;
			}
		}
		if (returnVal.equals(""))
			throw new ParameterException(
					"An input device has been selected which has not been configured, please contact your integrator");
		return returnVal;
	}

	/**
	 * Controlled item is the default item type. 
	 * The system will call this function if it is not from flash.
	 * ie. It is from the serial port.
	 * @param command	The command received on the serial port
	 */
	public void doControlledItem (CommandInterface command) throws CommsFail
	{
		DeviceType avDevice = getDevice(command.getKey());
		ReturnWrapper commandObject = interpretStringFromIntegra (command, avDevice);
		for (CommandInterface eachCommand: commandObject.getOutputFlash()){
			this.sendToFlash(eachCommand, cache);
		}
	}
	/**
	 * Get the state instance from the state map for the key provided
	 * @param key	The key for the device we are interested in
	 * @return	The correct state variable
	 * TODO decide whether we need to keep the state
	public AVState getState(String key) {
		AVState currentState = state.get(key);
		if (currentState == null){
			currentState = new AVState();
			state.put(key, currentState);
		}
		return currentState;
	}
	 */
	/**
	 * Protocol handling function
	 * @param command 	The command received on the serial port
	 * @return ReturnWrapper	The encapsulated return type
	 * TODO This may not work as the serial string is terminated with EOF (^Z)
	 */
	public ReturnWrapper interpretStringFromIntegra (CommandInterface command, DeviceType avDevice){
		ReturnWrapper result = new ReturnWrapper();

		String recvdCmd = command.getKey();
		// lets pull apart the string a little
		String val = integraHelper.getInputValue(recvdCmd);
		String cmd = integraHelper.getInputCommand(recvdCmd);
		
		// get the state
		//AVState currentState = getState (avDevice.getKey());
		
		// if it is not am amplifier we don't know what to do with it
		if (!integraHelper.validSourceDevice(recvdCmd))
		{
			logger.log (Level.WARNING, "Received command not from Integra amplifier " + recvdCmd);
			//logger.log (Level.WARNING, "Expected 1 got " + String.valueOf(srcType));
			result.setError(true);
			result.setErrorDescription( "Received command not from Integra amplifier " + recvdCmd);
			return result;
		}
		
		// command switch..
		/* TODO change to switch on the flash commands, need to change the getCommand()?
		 * TODO change to a switch? think you can switch on strings in java...
		*/
		if (cmd.equals("PWR") || cmd.equals("ZPW") || cmd.equals("PW3"))
		{
			logger.log (Level.FINE, "Received power command " + cmd);
			// if command is off and currently on
			if (val.equals("00")){ // && currentState.testPower(true)){
				// power off (standby)
				result.addFlashCommand(buildCommandForFlash (avDevice, "off","","","","","",0));
				//currentState.setPower (false);
			} // if command is on and currently off
			else if (val.equals("01")){ // && currentState.testPower(false)){
				// power on 
				result.addFlashCommand(buildCommandForFlash (avDevice, "on","","","","","",0));
				//currentState.setPower (true);
			}
			else
			{
				result.setError(true);
				result.setErrorDescription("Power command returned unknown value ["+ val +"]");
			}
		}
		else if (cmd.equals("AMT") || cmd.equals("ZMT") || cmd.equals("MT3"))
		{
			logger.log (Level.FINE, "Received mute command " + cmd);
			if (val.equals("00")){ //&& currentState.isMute()){
				result.addFlashCommand(buildCommandForFlash (avDevice, "mute","off","","","","",0));
				//currentState.setMute(false);				
			}
			else if (val.equals("01")){ //&& !currentState.isMute()){
				result.addFlashCommand(buildCommandForFlash (avDevice, "mute","on","","","","",0));
				//currentState.setMute(true);				
			}
			else
			{
				result.setError(true);
				result.setErrorDescription("Mute command returned unknown value ["+ val +"]");
			}
		}
		else if (cmd.equals("MVL") || cmd.equals("ZVL") || cmd.equals("VL3"))
		{
			logger.log (Level.FINE, "Received volume command " + cmd);
			String volForFlash = integraHelper.scaleVolumeForFlash(val);
			
			if (!volForFlash.equals(""))
			{
				//currentState.setVolume(volForFlashString);
				result.addFlashCommand(buildCommandForFlash ( avDevice, "volume",volForFlash,"","","","",0));					
			}
		}
		else if (cmd.equals("SLI") || cmd.equals("SLZ") || cmd.equals("SL3"))
		{
			logger.log (Level.FINE, "Received line in command " + cmd);

			try {
				// get the code to send to flash
				String newSrc = getKeyForParameterValue(val, "AV_INPUTS", avDevice);
				// listening mode command
				result.addFlashCommand(buildCommandForFlash(avDevice, "src",newSrc,"","","","",0));
			} catch (ParameterException ex) {
				result.setError(true);
				result.setErrorDescription(ex.getMessage());
			}
		}
		else if (cmd.equals("LMD"))
		{
			logger.log (Level.FINE, "Received listening mode command " + cmd);
			try
			{
				// get the code to send to flash
				String newSrc = getKeyForParameterValue(val, "AV_SURROUND", avDevice);
				// listening mode command
				result.addFlashCommand(buildCommandForFlash(avDevice, "preset",newSrc,"","","","",0));
			}
			catch (ParameterException ex) {
				result.setError(true);
				result.setErrorDescription(ex.getMessage());
			}
		}
		else if (cmd.equals("LMZ"))
		{
			logger.log (Level.FINE, "Received listening mode command " + cmd);
			try
			{
				// get the code to send to flash
				String newSrc = getKeyForParameterValue(val, "AV_SURROUND_ZONE2", avDevice);
				// listening mode command
				result.addFlashCommand(buildCommandForFlash(avDevice, "preset",newSrc,"","","","",0));
			}
			catch (ParameterException ex) {
				result.setError(true);
				result.setErrorDescription(ex.getMessage());
			}
		}
		else if (cmd.equals(""))
		{
			// we don't handle this command just yet
			logger.log (Level.WARNING,"Malformed command from Integra " + recvdCmd);
			result.setError(true);
			result.setErrorDescription("Malformed command from Integra " + recvdCmd);			
		}
		else
		{
			// we don't handle this command just yet
			logger.log (Level.WARNING,"We do not handle command ["+ cmd +"] from Integra yet");
			result.setError(true);
			result.setErrorDescription("We do not handle command ["+ cmd +"] from Integra yet");
		}
		
		return result;
	}
	/**
	 * builds the output string for the integra device for the command 
	 * received from flash client
	 * @param device
	 * @param command
	 * @return ReturnWrapper	the encapsulated return command
	 */
	public String buildOutputString (DeviceType device, String theCommand, String extra){
		String returnVal = null;
		int key = Integer.parseInt(device.getKey());

		if (theCommand.equals("volume"))
		{
			returnVal = integraHelper.outVolume(key, extra);
		}
		else if (theCommand.equals("mute"))
		{
			returnVal = integraHelper.outMute(key, extra);
		}
		else if (theCommand.equals("power")) // may need to add on and off??
		{
			returnVal = integraHelper.outPower(key, extra);
		}
		else if (theCommand.equals("src"))
		{
			try 
			{
				extra = getCatalogueValue(extra, "AV_INPUTS", device);
				if (extra != null)
					returnVal = integraHelper.outSource(key, extra);
			} 
			catch (ParameterException e) {
				e.printStackTrace();
			}
		}
		// FIXME change the flash command? we have a preset as well...
		else if (theCommand.equals("preset"))
		{
			try
			{
				extra = getCatalogueValue(extra, "AV_SURROUND", device);
				if (extra != null)
					returnVal = integraHelper.outPreset(key, extra);
			}
			catch (ParameterException e) {
				e.printStackTrace();
			}
		}
		else
		{
			logger.log (Level.WARNING,"Integra does not handle command ["+ theCommand +"] from client yet");			
		}
		return returnVal;
	}
}


	