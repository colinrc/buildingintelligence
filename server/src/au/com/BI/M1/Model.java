
package au.com.BI.M1;


/**
 * @author David Cummins
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Dynalite.DynaliteDevice;
import au.com.BI.Dynalite.DynaliteInputDevice;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.*;
import au.com.BI.User.*;

import java.util.*;
import java.util.logging.*;


import au.com.BI.Lights.*;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.M1.Commands.OutputChangeUpdate;

public class Model extends BaseModel implements DeviceModel {

	protected String outputM1Command = "";
	protected M1Helper m1Helper;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		m1Helper = new M1Helper();
	}

	public void clearItems () {
		super.clearItems();
	}

	public void doStartup (List commandQueue) throws CommsFail{
		// TODO get all zones?
	}
	
	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		boolean findingState = false;
		
		ArrayList deviceList = (ArrayList)configHelper.getOutputItem(theWholeKey);

		if (deviceList == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			Iterator eachDev = deviceList.iterator();
			while (eachDev.hasNext()){
				 DeviceType device = (DeviceType)eachDev.next();
				 String retCode = "";
				 
				 if (device.getDeviceType() == DeviceType.CONTACT_CLOSURE) {
					 retCode = buildToggleOutput ((DeviceType)device,command);
				 }	
				 
				 logger.log(Level.INFO,retCode);

				if (!retCode.equals ("")){
					comms.sendString(retCode);
				}
			}
		}
	}
	
	/**
	 * 
	 */
	public void addControlledItem (String key, Object details, int controlType) {
		if (controlType == DeviceType.OUTPUT) {
			super.addControlledItem(key,details,controlType);			
		} else {
			super.addControlledItem(Utility.padString(key,3),details,controlType);
		}
	}
	
	

	/**
	 * Controlled item is the default item type.
	 * The system will call this function if it is not from flash.
	 * ie. It is from the serial port.
	 */
	public void doControlledItem (CommandInterface command) throws CommsFail
	{
		if (command.isCommsCommand()){	
			// create the command objects 
			CommandInterface m1Command =  buildCommandForFlash(command);
			cache.setCachedCommand(m1Command.getKey(),m1Command);
			this.sendToFlash(commandQueue,-1,m1Command);
		}

	}
	
	public void sendToFlash (List commandQueue, long targetFlashID, CommandInterface command) {

		String theKey = command.getKey();
		DeviceType device = (DeviceType) configHelper.getControlItem(theKey);

		command.setTargetDeviceID(targetFlashID);
		logger.log (Level.INFO,"Sending to flash " + theKey + ":" + command.getCommandCode() + ":" + command.getExtraInfo());
		synchronized (this.commandQueue){
			commandQueue.add( command);
		}
	}
	
	protected CommandInterface buildCommandForFlash (CommandInterface command){
		M1Command m1Command = M1CommandFactory.getInstance().getM1Command(command.getKey());
		
		if (m1Command.getClass().equals(OutputChangeUpdate.class)) {
		
			if (((OutputChangeUpdate)m1Command).getOutputState().equals("0")) {
				m1Command.setCommand("off");
			} else {
				m1Command.setCommand("on");
			}
			m1Command.setDisplayName(((ToggleSwitch)configHelper.getControlItem(m1Command.getKey())).getOutputKey());
			m1Command.setKey("CLIENT_SEND");
			m1Command.setUser(this.currentUser);
		}
		return m1Command;
	}
	
	
	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		configHelper.wholeKeyChecked(keyName);

		if (configHelper.checkForOutputItem(keyName)) {
			logger.log (Level.FINER,"Flash sent command : " +keyName);
			return true;
		}
		else {
			if (isClientCommand)
				return false;
			else {
				configHelper.setLastCommandType (DeviceType.MONITORED);
				// Anything coming over the serial port I want to process
				return true;
			}
		}
	}

	public String buildToggleOutput (DeviceType device, CommandInterface command) {
		String returnString = "";
		
		if (command.getCommandCode().equals ("on")){
			returnString = m1Helper.buildCompleteM1String("CC"+Utility.padString(command.getKey(),3)+"100")+"\r\n";
		} else {
			// build off string
			returnString = m1Helper.buildCompleteM1String("CC"+Utility.padString(command.getKey(),3)+"000")+"\r\n";
		}
		return(returnString);
	}

	public boolean doIPHeartbeat () {
	    return false;
	}



	public M1Helper getM1Helper() {
		return m1Helper;
	}



	public void setDynaliteHelper(M1Helper m1Helper) {
		this.m1Helper = m1Helper;
	}

}
