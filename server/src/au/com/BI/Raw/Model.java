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

import java.util.*;
import java.util.regex.*;
import java.util.logging.*;
import au.com.BI.Flash.*;

import au.com.BI.CustomInput.*;

public class Model extends BaseModel implements DeviceModel {

	protected String parameter;
	protected CustomInput deviceThatMatched;
	protected boolean matched;
	protected Matcher matcherResults;
	protected Poll pollReaders[];
	protected String STX;
	protected String ETX;
	protected Logger logger;

	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		pollReaders = new Poll[10];
	}

    public void finishedReadingConfig () throws SetupException {
    	super.finishedReadingConfig();
		ETX = (String)this.getParameterMapName("ETX",DeviceModel.MAIN_DEVICE_GROUP);
		STX = (String)this.getParameterMapName("STX",DeviceModel.MAIN_DEVICE_GROUP);

		if (ETX == null) ETX = "";
		if (STX == null) STX = "";
	}

	public void doStartup () throws CommsFail 
	{
		for (int i = 1; i < 10 ; i++) {
			String startup = (String)this.getParameterMapName("STARTUP"+i,DeviceModel.MAIN_DEVICE_GROUP);
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
			String pollValue = (String)this.getParameterMapName("POLL_VALUE"+i,DeviceModel.MAIN_DEVICE_GROUP);
			String pollString = (String)this.getParameterMapName("POLL_STRING"+i,DeviceModel.MAIN_DEVICE_GROUP);
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

	public void addControlledItem (String name, DeviceType details, int controlType) {
		String theKey = name;

		configHelper.addControlledItem (theKey, details, controlType);
	}

	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		keyName = keyName.trim();
		configHelper.wholeKeyChecked(keyName);
		matched = false;


		if (configHelper.checkForOutputItem(keyName)) {
			logger.log (Level.FINER,"Flash sent command : " +keyName);
			return true;
		}
		else {
		    Iterator inputDeviceList = configHelper.getAllInputDevices();

			while (inputDeviceList.hasNext()){
			    DeviceType inputListItem = (DeviceType)inputDeviceList.next();
			    String inputListKey = "";
			    	matched = false;


		        CustomInput customInput = (CustomInput)inputListItem;
		        if (customInput.isHasPattern()){
		        		matcherResults = customInput.getMatcher(keyName);
		            if (matcherResults.matches()) {
						deviceThatMatched = customInput;
						configHelper.setLastCommandType(DeviceType.INPUT);
						return true;
		            }
		        }

			    if (!matched) {

			        inputListKey = inputListItem.getKey();

					if (inputListKey.equals("*")) {
						deviceThatMatched = (CustomInput)configHelper.getInputItem(inputListKey);
						configHelper.setLastCommandType(DeviceType.INPUT);
						parameter = keyName;
						return true;
					}
					else {
						if (keyName.startsWith(inputListKey)) {
							deviceThatMatched = (CustomInput)configHelper.getInputItem(inputListKey);
							configHelper.setLastCommandType(DeviceType.INPUT);
							parameter = keyName.substring (inputListKey.length());
							return true;
						}
					}
				}
			}
			return false;
		}
	}



	public void doCommand (CommandInterface command) throws CommsFail
	{
		String theWholeKey = command.getKey().trim();

		if ( configHelper.getLastCommandType() == DeviceType.OUTPUT) {
			doOutputItem (command);
		} else {
			if ( configHelper.getLastCommandType() == DeviceType.INPUT) {
			    Iterator inputDeviceList = configHelper.getAllInputDevices();

				while (inputDeviceList.hasNext()){
				    DeviceType inputListItem = (DeviceType)inputDeviceList.next();
				    String inputListKey = "";
				    	matched = false;


			        CustomInput customInput = (CustomInput)inputListItem;
			        if (customInput.isHasPattern()){
			        		matcherResults = customInput.getMatcher(theWholeKey);
			            if (matcherResults.matches()) {
							deviceThatMatched = customInput;
							configHelper.setLastCommandType(DeviceType.INPUT);
							doInputItem (command, deviceThatMatched, parameter);
			            }
			        }

				    if (!matched) {

				        inputListKey = inputListItem.getKey();

						if (inputListKey.equals("*")) {
							deviceThatMatched = (CustomInput)configHelper.getInputItem(inputListKey);
							configHelper.setLastCommandType(DeviceType.INPUT);
							parameter = theWholeKey;
							doInputItem (command, deviceThatMatched, parameter);
						}
						else {
							if (theWholeKey.startsWith(inputListKey)) {
								deviceThatMatched = (CustomInput)configHelper.getInputItem(inputListKey);
								configHelper.setLastCommandType(DeviceType.INPUT);
								parameter = theWholeKey.substring (inputListKey.length());
								doInputItem (command, deviceThatMatched, parameter);

							}
						}
					}
				}

			}
		}
	}

	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		DeviceType device = configHelper.getOutputItem(theWholeKey);

		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {

			String outputRawCommand = "";
			cache.setCachedCommand(command.getKey(),command);

			logger.log(Level.FINER, "Received flash event for RAW from " + theWholeKey);

			switch (device.getDeviceType()) {
				case DeviceType.RAW_INTERFACE :
					if ((outputRawCommand = buildDirectConnectString (device,command)) != null)
						sendToSerial (STX+outputRawCommand+ETX);
					break;
			}

		}
	}

	public void doInputItem (CommandInterface command, CustomInput inputFascade, String parameter) throws CommsFail
	{
		boolean isPattern = inputFascade.isHasPattern();
		logger.log(Level.FINEST, "Received custom command " + command.getKey());
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

		synchronized (commandQueue){
			commandQueue.add(inputCommand);
		}
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

		String rawSerialCommand = configHelper.doRawIfPresent (command, device);
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
			logger.log(Level.FINER, "Build comms string "+ rawSerialCommand);

			return rawSerialCommand;
		}
	}

}
