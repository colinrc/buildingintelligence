/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Patterns;

/**
 * @author Colin Canfield
 * @author Building Intelligence Pty Ltd
 * Supports certain common patterns from integrators
 *
*/


import java.util.HashMap;
import java.util.Map;
import java.util.logging.*;

import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Flash.ClientCommand;


public class Model extends SimplifiedModel implements DeviceModel {

	protected Map <String, IntegratorPattern> patterns;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		patterns  =new HashMap <String,IntegratorPattern>();
	}


	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		keyName = keyName.trim();
		
		if (patterns.containsKey(keyName)) 
			return true;
		else 
			return false;
	}


	
	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		
		IntegratorPattern pattern = patterns.get(theWholeKey);
		if (pattern != null) {
			pattern.run(command , cache);
		}

	}
	
	
	public void doControlledItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getDisplayName();
		
		IntegratorPattern pattern = patterns.get(theWholeKey);
		if (pattern != null) {
			pattern.run(command , cache);
		}

	}

	/**
	 * @param 
	 */
	
	public void addOnOffVolume (String triggerItem,  String destItem, boolean runFromScript )		{
		OnOffVolume onOffVolume = new OnOffVolume ();
		onOffVolume.setTriggerItem(triggerItem);
		onOffVolume.setDestItem(destItem);
		onOffVolume.setRunFromScript(runFromScript);
		onOffVolume.setPatterns(this);

		patterns.put(triggerItem, onOffVolume);
		
	}
	
	public void removeONOffVolume (String triggerItem) {
		patterns.remove(triggerItem);
		
	}


    /**
     * @param key,command,extra1,extra2,extra3,extra4,extra5 Create a command system command.
     * The same structure is used in the pattern module
     */
    public void addCommandToMainQueue(String key, String command, String extra1) {

        ClientCommand myCommand;
        myCommand = new ClientCommand();
        myCommand.setCommand(command);
        myCommand.setExtraInfo(extra1);

        myCommand.setTargetDeviceID(0);
        myCommand.setScriptCommand(true);
        myCommand.setKey(key);
        //  cache.setCachedCommand(key, myCommand);
        // don't cache it as it has to look like it came from flash, the target model will cache it as appropriate (ie. set or simple).
        
        commandQueue.add(myCommand);
        
        return;

    }

}
