/*
 * Created on May 2, 2004
 */
package au.com.BI.Comfort;

import java.util.logging.*;

import au.com.BI.Command.*;
import au.com.BI.Util.*;
import au.com.BI.Lights.*;
import au.com.BI.Counter.*;
import au.com.BI.ToggleSwitch.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.PulseOutput.*;
import au.com.BI.Alert.*;
/**
 * @author colinc
 */
public class OutputHelper {
	/**
	 * 
	 */
	protected String STX;
	protected String ETX;
	protected Logger logger;
	protected String comfortSecond = "";
	protected String cBUS_UCM = "";
	protected String applicationCode = "38";
	protected CommandQueue commandQueue = null;
	protected Model model;
	
	public OutputHelper(Model model) {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.model= model;
	}
	

	public void doOutputItem (CommandInterface command, ComfortString comfortString, ConfigHelper configHelper, Cache cache, CommDevice comms, au.com.BI.Comfort.Model comfort) throws CommsFail {	

		DeviceType device = configHelper.getOutputItem(comfortString.comfortKey);

		logger.log(Level.FINER, "Monitored comfort event sending to " + comfortString.comfortKey + " :" + device.getName());
		cache.setCachedCommand(comfortString.comfortKey,command);
		buildAndSendOutputString ( device,  command, configHelper, comms, comfort);
	}
	

	public void sendToComfort (String outputRawCommand,String errorMsg, CommDevice comms) throws CommsFail {
		if (outputRawCommand != null) {
			synchronized (comms) {
			    if (comms.isCommandQueueEmpty()) {
			        comms.addCommandToQueue(new CommsCommand ("",outputRawCommand + ETX,null, errorMsg));
			        comms.sendNextCommand();
			    } else {
			        comms.addCommandToQueue(new CommsCommand ("",outputRawCommand + ETX,null, errorMsg));			        
			    }
				
			}
		}
	}
	
	public void sendKeypress (CommandInterface command, CommDevice comms) throws CommsFail {
		String keyPress = (String)command.getExtraInfo();
		if (keyPress.length() == 1) keyPress = "0" + keyPress;  
		sendToComfort (STX+"KD" + command.getExtraInfo()+ETX,"keypress "+ keyPress, comms);
	}
	
	public void buildAndSendOutputString (DeviceType device, CommandInterface command, ConfigHelper configHelper, CommDevice comms, au.com.BI.Comfort.Model comfort ) throws CommsFail {
		String outputRawCommand = "";
		switch (device.getDeviceType()) {
			case DeviceType.LIGHT_CBUS : 
			case DeviceType.COMFORT_LIGHT_X10 :
				if ((outputRawCommand = buildLightString ((LightFascade)device,command,configHelper,comfort)) != null) {
					sendToComfort (outputRawCommand,((LightFascade)device).getOutputKey(), comms);
				}
				break;
			case DeviceType.TOGGLE_OUTPUT : 
			case DeviceType.TOGGLE_OUTPUT_MONITOR :
				if ((outputRawCommand = buildDirectConnectString ((ToggleSwitch)device,command,configHelper, comfort)) != null)
					sendToComfort (outputRawCommand,((ToggleSwitch)device).getOutputKey(), comms);
				break;
			case DeviceType.ALARM : 
				if ((outputRawCommand = buildAlarmString ((Alarm)device,command,configHelper, comfort)) != null)
					sendToComfort (outputRawCommand,((Alarm)device).getOutputKey(), comms);
				break;
			case DeviceType.PULSE_OUTPUT :
				if ((outputRawCommand = buildPulseOutputString ((PulseOutput)device,command,configHelper, comfort)) != null)
					sendToComfort (outputRawCommand,((PulseOutput)device).getOutputKey(), comms);
				break;
			case DeviceType.RAW_INTERFACE :
				if ((outputRawCommand = buildDirectConnectString ((ToggleSwitch)device,command,configHelper, comfort)) != null)
					if (outputRawCommand != null) { 
						sendToComfort (outputRawCommand+"\r",((ToggleSwitch)device).getOutputKey(), comms);
					}
				break;
			case DeviceType.COUNTER : 
				if ((outputRawCommand = buildCounterString ((Counter)device,command, configHelper, comfort)) != null)
					sendToComfort (outputRawCommand,((Counter)device).getOutputKey(), comms);
				break;
			case DeviceType.VIRTUAL_OUTPUT : 
				if ((outputRawCommand = buildVirtualOutputString ((Counter)device,command, configHelper, comfort)) != null)
					sendToComfort (outputRawCommand,((Counter)device).getOutputKey(), comms);
				break;
			}
		
	}
	public String buildLightString (LightFascade device, CommandInterface command, ConfigHelper configHelper, au.com.BI.Comfort.Model comfort){
		String comfortCommand = "";
		boolean commandFound = false;
		
		String rawBuiltCommand = model.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			comfortCommand = STX + rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		

		if (	!commandFound ){
			switch (device.getDeviceType()) {
	
				case LightFascade.TOGGLE_OUTPUT : 
					if (!commandFound && command.getCommandCode().equals ("off")) {
						comfortCommand = STX + "O!" + device.getKey() + "00";
						commandFound = true;
						break;
						} 
					if (!commandFound && command.getCommandCode().equals ("on")) {
						comfortCommand = STX + "O!" + device.getKey() + "01";
						commandFound = true;
						break;
						} 
					if (!commandFound && command.getCommandCode().equals ("change")) {
						comfortCommand = STX + "O!" + device.getKey() + "02";
						commandFound = true;
						break;
						} 
					if (!commandFound && command.getCommandCode().equals ("pulse")) {
						comfortCommand = STX + "O!" + device.getKey() + "03";
						commandFound = true;
						break;
						} 
					if (!commandFound && command.getCommandCode().equals ("flash")) {
						comfortCommand = STX + "O!" + device.getKey() + "04";
						commandFound = true;
						break;
						} 
					break;

					
					case LightFascade.LIGHT_CBUS: 
					    String escapedKey;
						String realApplicationCode = applicationCode;
						if (!device.getApplicationCode().equals ("")) {
						    realApplicationCode = device.getApplicationCode();
						}
						if (realApplicationCode.equals("0F")) {
						    realApplicationCode = "0F0F";
						}
						
						if (device.getKey().equals ("0F"))
						    escapedKey = "0F0F";
						else
						    escapedKey = device.getKey();
					
						if (command.getCommandCode().equals ("on")) {
							if (command.getExtraInfo().equals ("")) {
								comfortCommand = STX + "DAC5" + cBUS_UCM + escapedKey + "79" + realApplicationCode;						
								commandFound = true;
								break;
							} else {
								int level;
								try {
									level = Integer.parseInt((String)command.getExtraInfo());
								} catch (NumberFormatException ex) {
									level = 0;
								}
								level = 255 * level/100;
								String hexLevel;
								if (level == 255) {
								    hexLevel = "0FFD";
								}
								else {
								    hexLevel = Integer.toHexString(level).toUpperCase();
								}
								if (hexLevel.length() == 1) hexLevel = "0" + hexLevel;
								
							    comfortCommand = STX + "DAC5" + cBUS_UCM + escapedKey + "02" + hexLevel + realApplicationCode;
								commandFound = true;
								break;
							}
						} else {
							comfortCommand = STX + "DAC5" + cBUS_UCM + escapedKey + "01" + realApplicationCode;	
							commandFound = true;
						}
						break;

					case LightFascade.COMFORT_LIGHT_X10: 
						String unitKey = device.getKey();
						if (unitKey.length() == 1) unitKey = "0" + unitKey;
						if (command.getCommandCode().equals ("on")) {
							String level = command.getExtraInfo();
							if (level.equals("100") || level.equals("")) {
								comfortCommand = STX + "X!" + device.getX10HouseCode() + unitKey + "05";						
								commandFound = true;
								break;
							} else {
								String X10Level = "1E";
								comfortCommand = STX + "DA8C"+X10Level+"31";
								comfortSecond += "C3" + device.getX10HouseCode() + unitKey + "0F";	
								//comfortCommand = STX + "DAC3" + device.getX10HouseCode() + unitKey + "03";
								commandFound = true;
								break;
								
							}
						} 
						if (command.getCommandCode().equals ("off")) {
							comfortCommand = STX + "X!" + device.getX10HouseCode() + unitKey + "07";						
							commandFound = true;
							break;
						}	
						if (command.getCommandCode().equals ("bright")) {
							comfortCommand = STX + "X!" + device.getX10HouseCode() + unitKey + "0B";						
							commandFound = true;
							break;
						}	
						if (command.getCommandCode().equals ("dim")) {
							comfortCommand = STX + "X!" + device.getX10HouseCode() + unitKey + "09";						
							commandFound = true;
							break;
						}	
						break;
				}
			}
		if (!commandFound){
			logger.log(Level.WARNING, "Unknown command received from client "+ command.getCommandCode());
			return null;
		}
		else {
			logger.log(Level.FINER, "Build comms string "+ comfortCommand);

			
				return comfortCommand;
			}
		}

	public String buildAlarmString (Alarm device, CommandInterface command, ConfigHelper configHelper, au.com.BI.Comfort.Model comfort){
		String comfortCommand = "";
		boolean commandFound = false;
		
		String rawBuiltCommand = model.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			comfortCommand = STX + rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		

		if (theCommand.startsWith ("ARM:")) {
		    String commandBits [] = theCommand.split(":");
		    if (commandBits[1] != null && !commandBits[1].equals("")) {
				String userID = command.getExtraInfo();
				if (userID.equals("")) 
				    userID = (String)comfort.getParameterValue("Password",DeviceModel.MAIN_DEVICE_GROUP);
				
			    String alarm_mode = device.getModeCode (commandBits[1]);
			    
				comfortCommand = STX + "M!" + alarm_mode + userID;	
				commandFound = true;
		    }
		}
		if (command.getCommandCode().equals ("event_log")) {
			comfortCommand = STX + "E?";	
			commandFound = true;
		}
		logger.log(Level.FINER, "Build comms string "+ comfortCommand);
		
		return comfortCommand;
	}
	
	public String buildPulseOutputString (PulseOutput device, CommandInterface command, ConfigHelper configHelper, au.com.BI.Comfort.Model comfort){
		String comfortCommand = "";
		boolean commandFound = false;
		
		String rawBuiltCommand = model.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			comfortCommand = STX + rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		
		if (command.getCommandCode().equals ("on")) {

			if (command.getExtraInfo().equals ("")) {
				comfortCommand = STX + "P!" + device.getKey() + "FF";						
				commandFound = true;
			} else {
				int level = Integer.parseInt((String)command.getExtraInfo());
				level = 255 * level/device.getMax();
				String hexLevel = Integer.toHexString(level).toUpperCase();
				if (hexLevel.length() == 1) hexLevel = "0" + hexLevel;
	
				comfortCommand = STX + "P!" +  device.getKey() + hexLevel;
				commandFound = true;
			}
		} else {
			comfortCommand = STX + "P!" + device.getKey() + "00";	
			commandFound = true;
		}
		logger.log(Level.FINER, "Build comms string "+ comfortCommand);
		
		return comfortCommand;
	}
	
	public String buildVirtualOutputString (Counter device, CommandInterface command, ConfigHelper configHelper, au.com.BI.Comfort.Model comfort){
		String comfortCommand = "";
		boolean commandFound = false;
		
		String rawBuiltCommand = model.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			comfortCommand = STX + rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		
		if (command.getCommandCode().equals ("on")) {

			if (command.getExtraInfo().equals ("")) {
				comfortCommand = STX + "OV" + device.getKey() + "FF";						
				commandFound = true;
			} else {
				int level = Integer.parseInt((String)command.getExtraInfo());
				level = 255 * level/device.getMax();
				String hexLevel = Integer.toHexString(level).toUpperCase();
				if (hexLevel.length() == 1) hexLevel = "0" + hexLevel;
	
				comfortCommand = STX + "OV" +  device.getKey() + hexLevel;
				commandFound = true;
			}
		} else {
			comfortCommand = STX + "OV" + device.getKey() + "00";	
			commandFound = true;
		}
		logger.log(Level.FINER, "Build comms string "+ comfortCommand);
		
		return comfortCommand;
	}

	
	public String buildCounterString (Counter device, CommandInterface command, ConfigHelper configHelper, au.com.BI.Comfort.Model comfort){
		String comfortCommand = "";
		boolean commandFound = false;
		
		String rawBuiltCommand = model.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			comfortCommand = STX + rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		
		if (command.getCommandCode().equals ("on")) {

			if (command.getExtraInfo().equals ("")) {
				comfortCommand = STX + "C!" + device.getKey() + "FF";						
				commandFound = true;
			} else {
				int level = Integer.parseInt((String)command.getExtraInfo());
				level = 255 * level/device.getMax();
				String hexLevel = Integer.toHexString(level).toUpperCase();
				if (hexLevel.length() == 1) hexLevel = "0" + hexLevel;
	
				comfortCommand = STX + "C!" +  device.getKey() + hexLevel;
				commandFound = true;
			}
		} else {
			comfortCommand = STX + "C!" + device.getKey() + "00";	
			commandFound = true;
		}
		logger.log(Level.FINER, "Build comms string "+ comfortCommand);
		
		return comfortCommand;
	}
	
	public String buildDirectConnectString (ToggleSwitch device, CommandInterface command, ConfigHelper configHelper, au.com.BI.Comfort.Model comfort){
		String comfortCommand = "";
		boolean commandFound = false;
		
		String rawBuiltCommand = model.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			comfortCommand = STX + rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}
		
		if (!commandFound && command.getCommandCode().equals ("off")) {
				comfortCommand = STX + "O!" + device.getKey() + "00";
				commandFound = true;
		} 
		if (!commandFound && command.getCommandCode().equals ("on")) {
			comfortCommand = STX + "O!" + device.getKey() + "01";
			commandFound = true;
		} 
		if (!commandFound && command.getCommandCode().equals ("toggle")) {
			comfortCommand = STX + "O!" + device.getKey() + "02";
			commandFound = true;
		} 
		if (!commandFound && command.getCommandCode().equals ("pulse")) {
			comfortCommand = STX + "O!" + device.getKey() + "03";
			commandFound = true;
		} 
		if (!commandFound && command.getCommandCode().equals ("flash")) {
			comfortCommand = STX + "O!" + device.getKey() + "04";
			commandFound = true;
		} 
		if (!commandFound){
			logger.log(Level.WARNING, "Unknown command received from client "+ command.getCommandCode());
			return null;
		}
		else {
			logger.log(Level.FINER, "Build comms string "+ comfortCommand);
		
			return comfortCommand;
		}
	}




	/**
	 * @return Returns the sTX.
	 */
	public String getSTX() {
		return STX;
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setSTX(String stx) {
		STX = stx;
	}
	/**
	 * @return Returns the eTX.
	 */
	public String getETX() {
		return ETX;
	}
	/**
	 * @param etx The eTX to set.
	 */
	public void setETX(String etx) {
		ETX = etx;
	}
	/**
	 * @return Returns the cBUS_UCM.
	 */
	public String getCBUS_UCM() {
		return cBUS_UCM;
	}
	/**
	 * @param cbus_ucm The cBUS_UCM to set.
	 */
	public void setCBUS_UCM(String cbus_ucm) {
		cBUS_UCM = cbus_ucm;
	}
	/**
	 * @return Returns the applicationCode.
	 */
	public String getApplicationCode() {
		return applicationCode;
	}
	/**
	 * @param applicationCode The applicationCode to set.
	 */
	public void setApplicationCode(String applicationCode) {
		this.applicationCode = applicationCode;
	}


	public CommandQueue getCommandQueue() {
		return commandQueue;
	}


	public void setCommandQueue(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}
}
