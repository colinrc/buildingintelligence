/**
 * 
 */
package au.com.BI.GroovyModels;
import au.com.BI.Command.*;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Util.*;

import java.util.logging.*;
/**
 * @author colin
 * @todo Add startup,poling, ETX  and  processing instructions from the device.
 */
public class GroovyModel extends SimplifiedModel implements DeviceModel {	
	public GroovyModel (){
		super();
	}
	
	public void finishedReadingConfig()throws SetupException  {
		super.finishedReadingConfig();
	}
	
	
	/*
	 * This function is called on model startup. The pattern will be similar to the doOutputItem below, and will contain a hook for a general whole of device sartup
	 * @see au.com.BI.Util.BaseModel#doStartup()
	 */
	public void doStartup () throws CommsFail {
		
	}
	

	 
	/*
	 * This function is called on model startup. The pattern will be similar to the doOutputItem below, and will contain a hook for a general whole of device sartup
	 * @see au.com.BI.Util.BaseModel#doOutputItem()
	 */
	public void doOutputItem(CommandInterface command) throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper ();

		
		try {
			decodeOutputItem (command, returnWrapper);
			addCheckSums(returnWrapper);
			sendWrapperItems (returnWrapper);			

		} catch (GroovyModelException ex){
			logger.log (Level.WARNING,"An error occured in " + this.getName() +" support " + ex.getMessage());
		}
		
	}
	
	public void doControlledItem (CommandInterface command) throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		
		try {
			processStringFromComms (command.getCommandCode(), returnWrapper);
			addCheckSums(returnWrapper);
			sendWrapperItems (returnWrapper);			
			
		} catch (CommsProcessException ex){
			logger.log (Level.WARNING,"An error occured in " + this.getName() +" support " + ex.getMessage());
		}
		
	}


	
	
}
