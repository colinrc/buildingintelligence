
package au.com.BI.M1;


/**
 * @author David Cummins
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Alert.AlertCommand;
import au.com.BI.M1.ControlledHelper;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommsFail;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.M1.Commands.OutputChangeUpdate;
import au.com.BI.M1.Commands.ZoneChangeUpdate;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.BaseModel;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import au.com.BI.Util.Utility;

public class Model extends BaseModel implements DeviceModel {

	protected String outputM1Command = "";
	protected M1Helper m1Helper;
	protected ControlledHelper controlledHelper;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		m1Helper = new M1Helper();
		controlledHelper = new ControlledHelper();
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
				 
				 if (device.getDeviceType() == DeviceType.TOGGLE_OUTPUT) {
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
		controlledHelper.doControlledItem(command, configHelper, cache, commandQueue, this);
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
			
			returnString = m1Helper.buildCompleteM1String("cn"+Utility.padString(command.getKey(),3)+"0000000")+"\r\n";
		} else if (command.getCommandCode().equals("pulse")) {
			// build off string
			
			returnString = m1Helper.buildCompleteM1String("cn"+Utility.padString(command.getKey(),3)+Utility.padString(command.getExtraInfo(),5)+"00")+"\r\n";
		} else if (command.getCommandCode().equals("off")) {
			returnString = m1Helper.buildCompleteM1String("cf"+Utility.padString(command.getKey(),3)+"00")+"\r\n";
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
