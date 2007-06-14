/*
 * Created on Jul 13, 2004
 *
*/
package au.com.BI.GC100;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.IR.IR;
import au.com.BI.Util.*;
import au.com.BI.User.*;
import au.com.BI.ToggleSwitch.*;

import java.util.*;
import java.util.logging.*;


public class Model extends SimplifiedModel implements DeviceModel {
	
	protected char STX=' ';
	protected char ETX='\r';
	protected String lastIR_ID = "";
	protected String lastConnectorID = "";
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setInterCommandInterval(10); // May need further tuning for GC100 IR
	}
	

	/**
	 * @return Returns the eTX.
	 */
	public char getETX() {
		return ETX;
	}
	/**
	 * @param etx The eTX to set.
	 */
	public void setETX(char etx) {
		ETX = etx;
	}

	public void clearItems () {
		super.clearItems();
	}
	
	// @TODO Change this to FROM_HARDWARE after changing input toggle
	public void addStartupQueryItem (String name, DeviceType details, MessageDirection controlType){
	    if (((String)this.getParameterValue("MODULE_TYPE" ,details.getGroupName())).equals("IR")
	            && controlType == MessageDirection.FROM_HARDWARE)
	        configHelper.addStartupQueryItem(details.getKey(),details,controlType);
	}
	
	public void addControlledItem (String name, DeviceType details, MessageDirection controlType) {
		String theKey = name;
    
		int deviceType = (details).getDeviceType();
		
		if (controlType != MessageDirection.FROM_FLASH) {
		    			    
		    String moduleNumber = (String)this.getParameterValue("MODULE" ,((DeviceType)details).getGroupName());
		    String connectorNumber = name;
		    try {
		        theKey = String.valueOf(Integer.parseInt(moduleNumber)) + ":" + String.valueOf(Integer.parseInt(connectorNumber));
		        ((DeviceType)details).setKey(theKey);
		        super.addControlledItem(theKey,details,controlType);
		    } catch (NumberFormatException ex) {
		        logger.log (Level.WARNING,"A device key or group number in the GC100 configuration is not numeric :" + name);
		    }
		}
		else {
		    super.addControlledItem(name,details,controlType);
		}
	}

	public String getHeartbeatString () {
		return "getversion,1\n";
	}

	public void doStartup() throws CommsFail {
		logger.warning("Connecting to the GC100");
	    Iterator startupItems = configHelper.getStartupQueryItemsList();
	    while (startupItems.hasNext()) {
				try { 
			        String nextKey =  (String)startupItems.next();
			        ToggleSwitch toggle =  (ToggleSwitch)configHelper.getStartupQueryItem(nextKey);
					CommsCommand gc100CommsCommand = new CommsCommand();
					gc100CommsCommand.setKey (toggle.getKey());
					gc100CommsCommand.setCommand("getstate,"+toggle.getKey()+ETX);
					gc100CommsCommand.setExtraInfo (toggle.getOutputKey());
					comms.addCommandToQueue (gc100CommsCommand);
				} catch (CommsFail e1) {
					throw new CommsFail ("Communication failed with GC100. " + e1.getMessage());
	        		} catch (ClassCastException ex) {};
        }
	}
	
	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		configHelper.wholeKeyChecked(keyName);

		if (configHelper.checkForOutputItem(keyName)) {
			configHelper.setLastCommandType (MessageDirection.FROM_FLASH);
			logger.log (Level.FINER,"Flash sent command : " +keyName);
			return true;
		}
		else {
			if (isClientCommand)
				return false;
			else {
				configHelper.setLastCommandType (MessageDirection.FROM_HARDWARE);
				// Anything coming over the serial port I want to process
				return true;
			}
		}
	}

	
	public void doOutputItem (CommandInterface command) throws CommsFail {	
		String theWholeKey = command.getKey();

		    
		DeviceType device = configHelper.getOutputItem(theWholeKey);
		String outputCommand;
		
		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {

			String outputIRCommand = null;
			cache.setCachedCommand(command.getKey(),command);
			
			switch (device.getDeviceType()) {
				case DeviceType.TOGGLE_OUTPUT :
					logger.log(Level.FINEST, "GC100 toggle event being sent to connector " + device.getKey());
					if ((outputCommand = buildRelayString ((ToggleSwitch)device,command)) != null) {
						CommsCommand gc100CommsCommand = new CommsCommand();
						gc100CommsCommand.setKey (device.getKey());
						gc100CommsCommand.setCommand(outputCommand);
						gc100CommsCommand.setExtraInfo (((ToggleSwitch)(device)).getOutputKey());
							try { 
								//comms.addCommandToQueue (gc100CommsCommand);
								comms.sendString(outputCommand);
							} catch (CommsFail e1) {
								throw new CommsFail ("Communication failed with GC100. " + e1.getMessage());
							} 
						logger.log (Level.FINEST,"Queueing GC100 command for " + (String)gc100CommsCommand.getExtraInfo());
					}
					break;

				case DeviceType.IR :
					logger.log(Level.FINEST, "GC100 IR code being sent to connector " + device.getKey());
					String eachIRName [] = command.getExtraInfo().split(",");
					for (int i = 0; i < eachIRName.length; i++){
						outputCommand = buildIRString ((IR)device,eachIRName[i],command.getExtra2Info());
						if (outputCommand != null && !outputCommand.equals("")) {
							if (logger.isLoggable(Level.FINER)) {
								logger.log (Level.FINER, "Sending IR command for " + eachIRName[i] + " " + outputCommand);
							}
							CommsCommand gc100CommsCommand = new CommsCommand();
							gc100CommsCommand.setKey (lastConnectorID);
							gc100CommsCommand.setCommand(outputCommand);
							gc100CommsCommand.setExtraInfo (((IR)(device)).getOutputKey());
							gc100CommsCommand.setExtra2Info(eachIRName[i]);
							gc100CommsCommand.setActionCode(lastConnectorID);
							gc100CommsCommand.setActionType(CommDevice.GC100_IRCommand);
							gc100CommsCommand.setKeepForHandshake(true);
								try { 
									comms.addCommandToQueue (gc100CommsCommand);
									/* if (!comms.sentQueueContainsCommand(CommDevice.GC100_IRCommand,this.lastConnectorID)) {
									    comms.sendNextCommand(CommDevice.GC100_IRCommand,this.lastConnectorID);
									} */
									if (!comms.sentQueueContainsCommand(CommDevice.GC100_IRCommand)) {
										comms.sendNextCommand(CommDevice.GC100_IRCommand,"");
									} 
									
								} catch (CommsFail e1) {
									throw new CommsFail ("Communication failed with GC100. " + e1.getMessage());
								} 
							logger.log (Level.FINEST,"Queueing GC100 command for " + (String)gc100CommsCommand.getExtraInfo());
						} else {
						    logger.log (Level.INFO, "IR Command string is null");
						}
					}
					break;						
			}
		}
	}
	
	protected String getIR_ID(String key) {
	    int module = 0;
	    int connector = 0;
	    try {
		    String [] parts = key.split(":");
		    module = Integer.parseInt (parts[0]);
		    connector = Integer.parseInt (parts[1]);
	    } catch (NumberFormatException ex) {
	        logger.log (Level.WARNING,"GC100 Received an invalid key " + key);
	        return "";
	    } catch (NullPointerException ex) {
	        logger.log (Level.WARNING,"GC100 Received an empty key");
	        return "";
	    } catch (ArrayIndexOutOfBoundsException ex) {
	        logger.log (Level.WARNING,"GC100 Received an invalid key " + key);
	        return "";
	    }
	    lastIR_ID = String.valueOf(module * 10 + connector);
	    lastConnectorID = String.valueOf (module) + ":"  + String.valueOf(connector);
	    return lastIR_ID;
	}

	protected String getIR_ID(String moduleStr, int connector) {
	    int module = 0;
	    try {
		    module = Integer.parseInt (moduleStr);
	    } catch (NumberFormatException ex) {
	        logger.log (Level.WARNING,"GC100 IR device configured with an invalid module number");
	        return "";
	    }
	    lastIR_ID = String.valueOf(module * 10 + connector);
	    lastConnectorID = String.valueOf (module) + ":"  + connector;
	    return lastIR_ID;
	}

	protected String buildRelayString (ToggleSwitch outswitch, CommandInterface command) {
		String connector = (String)this.getParameterValue ("MODULE",outswitch.getGroupName());
		if (connector.equals("")) {
			logger.log(Level.SEVERE,"No module number was specified for switch " + outswitch.getName() + " in group " + outswitch.getGroupName());
			return null;
		}
		connector = outswitch.getKey();
		
		if (command.getCommandCode().equals( "on")) {
			logger.log (Level.FINER,"Sending a relay on command to " + connector);
			return "setstate," + connector + ",1" + ETX;
		}
		else {
			logger.log (Level.FINER,"Sending a relay off command to " + connector);
			return "setstate," + connector + ",0" + ETX;
		}
	}

	protected String buildIRString (IR ir, String irName,String repCount) {
		String module = (String)this.getParameterValue ("MODULE",ir.getGroupName());
		int connector = 0;
		if (module.equals("")) {
			logger.log(Level.SEVERE,"No module number was specified for IR " + ir.getName() + " in group " + ir.getGroupName());
			return null;
		}
		try {
		    connector = Integer.parseInt(ir.getKey());
		} catch (NumberFormatException ex) {
		    logger.log (Level.SEVERE,"GC100 IR device configured with a non-numeric key");
		    return null;
		}
		String ID = this.getIR_ID(module,connector);
		if (ID.equals ("") ) return null;
		String outputString = "sendir," + module + ":" + connector + "," + ID;
		// One of the codes in the codes database
		String extra = irName;
		String commandRep = repCount;
		if (commandRep.equals("")) commandRep = "1";
		
		if (irCodeDB == null) {
		    logger.log (Level.WARNING,"IR Code Database was not initialised correctly");
		    return "";
		}
		if(extra != null && !extra.equals(""))   {
			String frequency = irCodeDB.getFrequency (extra);
	
			String codeSequence = irCodeDB.getCode (extra);
			
			if (frequency.equals("") || codeSequence.equals("")) {
			    logger.log (Level.WARNING,"An IR request was received for code '" + irName + "' which is unknown.");
			    return null;
			} else {
			    outputString += "," + frequency + "," + commandRep + "," + codeSequence +ETX;
			}
			return outputString;
		} else
		    return "";
	}
	/**
	 * Controlled item is the default item type. 
	 * The system will call this function if it is not from flash.
	 * ie. It is from the serial port.
	 */

	public void doControlledItem (CommandInterface command) throws CommsFail
	{
		boolean didCommand=false;
		if (!command.isCommsCommand()) return;
		String gc100String = command.getKey().trim();
		logger.log(Level.FINEST, "Command from GC100 : " + gc100String );
		User currentUser = command.getUser();

		String gc100StringParts[] = gc100String.split(",");
		try {
			if (gc100StringParts[0].equals("version")) {
				didCommand = true;
			}
		    	if (gc100StringParts[0].equals("completeir")) {
		    	    String deviceAddress =  gc100StringParts[1];
				
		    	    // comms.acknowlegeCommand(CommDevice.GC100_IRCommand,deviceAddress);
		    	    comms.acknowledgeCommand(CommDevice.GC100_IRCommand,"");
		    	    CommsCommand lastCommandSent;
		    	    if (comms.sendNextCommand(CommDevice.GC100_IRCommand)) {
		    	    //if (comms.sendNextCommand(CommDevice.GC100_IRCommand,deviceAddress)) {
					lastCommandSent = comms.getLastCommandSent();
		    	    } else {
		    	    		lastCommandSent = null;
		    	    }
		    	    logger.log (Level.FINER,"IR Command completed successfully");
				if (logger.isLoggable(Level.FINER)) {
					if (lastCommandSent != null) {
						String theName = lastCommandSent.getCommandCode();
						logger.log (Level.FINER,"Received acknowledge for command on " + deviceAddress + " sent next command "+ lastCommandSent.getExtra2Info());
					} else {
						logger.log (Level.FINER,"Received acknowledge for command on " + deviceAddress);						
					}
				}
				didCommand = true;
		    	}
		    	if (gc100StringParts[0].equals("statechange") || gc100StringParts[0].equals("state")) {
		    	    String deviceAddress = gc100StringParts[1];
		    	    String newState =  gc100StringParts[2];
		    	    
		    	    if (newState.equals("1"))
		    	        sendOutput (deviceAddress, "on", "", currentUser);
		    	    else
		    	        sendOutput (deviceAddress,  "off", "", currentUser);

		    	    logger.log (Level.FINER,"Received state change");
		    	    didCommand = true;
		    	}
		    	if (gc100StringParts[0].startsWith("unknowncommand")) {

		    	    if (!didCommand) {
					CommsCommand lastCommandSent = comms.getLastCommandSent();
					if (lastCommandSent != null) {
						String deviceAddress = lastCommandSent.getActionCode();
		    	       		logger.log (Level.WARNING,"The GC100 received a command it did not understand " + lastCommandSent.getExtra2Info());
		    	       		comms.acknowledgeCommand(CommDevice.GC100_IRCommand,deviceAddress);
		    	       		comms.sendNextCommand(CommDevice.GC100_IRCommand,deviceAddress);
					} else {
	    	       			comms.acknowledgeCommand(CommDevice.GC100_IRCommand);
					}

		    	    }

		    	    didCommand = true;
		    	}
		}
		catch (IndexOutOfBoundsException inEx) {
		}
		catch (CommsFail ex) {
			throw new CommsFail ("Communication failed with GC100. " + ex.getMessage());
		}
			
		if (!didCommand) {
			logger.log (Level.INFO,"Received a return code from GC100 I do not understand : " + gc100String);
		}
	}

	public String buildKey (String appCode, String moduleCode) {
		if (moduleCode.length() == 0 ) moduleCode = "0";
		return appCode + ":" + moduleCode;
	}
	
	public void sendOutput (String key, String command, String extra,User user) {

		ToggleSwitch toggle = (ToggleSwitch)configHelper.getControlledItem(key);
		
		if (toggle != null) {
			
				CommandInterface toggleSwitchCommand = toggle.buildDisplayCommand ();
				toggleSwitchCommand.setCommand (command);
				toggleSwitchCommand.setExtraInfo(extra);
				toggleSwitchCommand.setKey ("CLIENT_SEND");
				toggleSwitchCommand.setUser(user);
				cache.setCachedCommand(toggleSwitchCommand.getDisplayName(),toggleSwitchCommand);
				this.sendToFlash(-1,toggleSwitchCommand);
				//logger.log (Level.FINEST,"Sending to flash " + toggleSwitchCommand.getDisplayName() + " " + command;
		}
		else {
		}
	}
	
    /**
     * @return Returns the lastIR_ID.
     */
    public String getLastIR_ID() {
        return lastIR_ID;
    }
    /**
     * @param lastIR_ID The lastIR_ID to set.
     */
    public void setLastIR_ID(String lastIR_ID) {
        this.lastIR_ID = lastIR_ID;
    }
    
	public boolean doIPHeartbeat () {
	    return true;
	}
	
	public boolean doIControlIR () {
	    return true;
	}

    public void finishedReadingConfig() throws SetupException {
    	super.finishedReadingConfig();
    		IR iR_internal = new IR("DUMMY",DeviceType.IR,"DUMMY");
    		
        this.addControlledItem("IR_INTERNAL",iR_internal,MessageDirection.FROM_FLASH);
    }

}
