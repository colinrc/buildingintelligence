/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Raw;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;

import java.util.regex.*;
import java.util.logging.*;
import au.com.BI.Flash.*;

import au.com.BI.CustomInput.*;
import au.com.BI.Device.DeviceType;

public class Model extends SimplifiedModel implements DeviceModel {

	protected String parameter;
	protected CustomInput deviceThatMatched;
	protected boolean matched;
	protected Matcher matcherResults;
	protected Poll pollReaders[];
	protected String STX;
	protected String ETX;

	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		pollReaders = new Poll[10];
	}

    public void finishedReadingConfig () throws SetupException {
    	super.finishedReadingConfig();
		ETX = (String)this.getParameterValue("ETX",DeviceModel.MAIN_DEVICE_GROUP);
		STX = (String)this.getParameterValue("STX",DeviceModel.MAIN_DEVICE_GROUP);

		if (ETX == null) ETX = "";
		if (STX == null) STX = "";
	}

	public void doStartup () throws CommsFail 
	{
		for (int i = 1; i < 10 ; i++) {
			String startup = (String)this.getParameterValue("STARTUP"+i,DeviceModel.MAIN_DEVICE_GROUP);
			if (startup != null && !startup.equals ("")) {
				try {
					comms.sendString(startup);
				} catch (CommsFail ex) {
					throw new CommsFail ("Communication failed starting RAW device");
				}
			}
		}

		for (int i = 1; i < 10 ; i++) {
			long poll = 30000; //default to every 30 seconds
			String pollValue = (String)this.getParameterValue("POLL_VALUE"+i,DeviceModel.MAIN_DEVICE_GROUP);
			String pollString = (String)this.getParameterValue("POLL_STRING"+i,DeviceModel.MAIN_DEVICE_GROUP);
			if (pollValue != null && pollString != null && !pollValue.equals( ("")) && !pollString.equals("")){
				try {
					poll = Long.parseLong(pollValue) * 1000;
				} catch (NumberFormatException ex){
					poll = 0;
				}
				if (poll != 0) {
					if (poll < 5000) poll = 5000; // 5 seconds minimum to make sure we don't flood comfort.
					Poll pollReader = new Poll();
					pollReader.setCommandQueue(commandQueue);
					pollReader.setDeviceNumber(this.InstanceID);
					pollReader.setComms(comms);
					pollReader.setPollValue(poll);
					pollReader.setPollString(Utility.unEscape(pollString));
					pollReaders[i] = pollReader;
					pollReader.start();

				}

			}
		}
	}

	public void addControlledItem (String name, DeviceType details, MessageDirection controlType) {
		String theKey = name;

		configHelper.addControlledItem (theKey, details, controlType);
	}

	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		if (isClientCommand && configHelper.checkForOutputItem(keyName) ) {
				logger.log (Level.FINER,"Flash sent command : " +keyName);
				return true;
		}
		else {
			if (!isClientCommand){
				configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
				return true;
			}
			else 
				return false;
		} 
	}


	public void processStringFromComms(String command,
			ReturnWrapper returnWrapper) throws CommsProcessException {
		
		for (DeviceType inputListItem: configHelper.getAllControlledDeviceObjects()) {
			String theWholeKey = command.trim();
		    String inputListKey = "";
	    	matched = false;
	    	if (inputListItem.getDeviceType() != DeviceType.CUSTOM_INPUT) continue;

	        CustomInput customInput = (CustomInput)inputListItem;
	        if (customInput.isHasPattern()){
	        		matcherResults = customInput.getMatcher(theWholeKey);
		            if (matcherResults.matches()) {
						deviceThatMatched = customInput;
						configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
						doInputItem (command, deviceThatMatched, parameter);
		            }
		        }

		    if (!matched) {

		        inputListKey = inputListItem.getKey();

				if (inputListKey.equals("*")) {
					deviceThatMatched = (CustomInput)configHelper.getControlledItem(inputListKey);
					configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
					parameter = theWholeKey;
					doInputItem (command, deviceThatMatched, parameter);
				}
				else {
					if (theWholeKey.startsWith(inputListKey)) {
						deviceThatMatched = (CustomInput)configHelper.getControlledItem(inputListKey);
						configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
						parameter = theWholeKey.substring (inputListKey.length());
						doInputItem (command, deviceThatMatched, parameter);

					}
				}
			}
		}
	}



	public void buildRAWControlString(DeviceType device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {

		String outputRawCommand = "";
		if ((outputRawCommand = buildDirectConnectString (device,command)) != null)
			returnWrapper.addCommOutput(STX+outputRawCommand+ETX);
	}
	
	public void doInputItem (String command, CustomInput inputFascade, String parameter) throws CommsFail
	{
		boolean isPattern = inputFascade.isHasPattern();
		logger.log(Level.FINEST, "Received custom command " + command);
		ClientCommand inputCommand = new ClientCommand ();
		String key = inputFascade.getOutputKey();
		String commandStr = inputFascade.getCommand();
		String extra ;
		if (inputFascade.getExtra() != null)
		    extra = inputFascade.getExtra();
		else
		    extra = parameter;

		if (isPattern) {
			key = replacePattern (key,this.matcherResults);
			commandStr = replacePattern (commandStr,this.matcherResults);
			extra = replacePattern (extra,this.matcherResults);
		}

		//inputCommand.setKey ("CLIENT_SEND");
		inputCommand.setDisplayName(key);
		inputCommand.setCommand(commandStr);
		inputCommand.setExtraInfo(extra);

		commandQueue.add(inputCommand);
		CustomInputCommand flashCommand = new CustomInputCommand ();
		flashCommand.setKey ("CLIENT_SEND");
		flashCommand.setDisplayName(key);
		flashCommand.setCommand(commandStr);
		flashCommand.setExtraInfo(extra);
		sendToFlash (flashCommand,cache);

	}

	public String replacePattern (String str,Matcher matcher) {
		if (str == null) return "";
		int numberPatterns = matcher.groupCount();
		if (numberPatterns > 9) numberPatterns = 0;
		for (int i = 0; i <= numberPatterns ; i ++ ) {
			String pattern = "@" + i;
			str = str.replaceAll(pattern,matcher.group(i));
		}
		return str;
	}


	public String buildDirectConnectString (DeviceType device, CommandInterface command){
		boolean commandFound = false;

		String rawSerialCommand = doRawIfPresent (command, device);
		if (rawSerialCommand != null)
		{
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}
		else {
			logger.log(Level.FINER, "Build custom string "+ rawSerialCommand);

			return rawSerialCommand;
		}
	}

}
