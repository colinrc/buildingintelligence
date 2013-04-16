/**
 * 
 */
package au.com.BI.Patterns;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CacheWrapper;
import au.com.BI.Command.CommandInterface;

/**
 * @author colin
 *
 */
public class OnOffVolume  implements IntegratorPattern {
	
	String triggerItem ="";
	String destItem = "";
	boolean runFromScript  =false;
	protected Model patterns;
	protected Logger logger;
	
	public OnOffVolume () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	};
	
	public void run (CommandInterface command, Cache cache){
		if (command == null || (command.isScriptCommand() && runFromScript == false)) return;
		
		CacheWrapper previousValue = cache.getCachedObject(destItem);
		CommandInterface lastValue = null;
		boolean wasOn = false;
		try{
		if (previousValue  != null ) {
			if (previousValue.isSet()){
					lastValue = (previousValue.getMap()).get("on");
			} else {
					lastValue = previousValue.getCommand();
					}
			}
			if (lastValue != null && lastValue.getCommandCode().equals ("on")) {
				wasOn = true;
			}
		}
		catch (NullPointerException ex){};
		
		String theCommand = command.getCommandCode();
		
		if (theCommand.equals("on")){
			if (!wasOn) patterns.addCommandToMainQueue (destItem,"on","100");
			patterns.addCommandToMainQueue (destItem,"volume",command.getExtraInfo());
			logger.log (Level.FINEST,"On Off volume pattern was run with a level " + command.getExtraInfo() );
		} else {
			patterns.addCommandToMainQueue (destItem,"off","0");
			logger.log (Level.FINEST,"On Off volume pattern was run with command off");			
		}

	}
    
	public String getTriggerItem() {
		return triggerItem;
	}

	public void setTriggerItem(String triggerItem) {
		this.triggerItem = triggerItem;
	}

	public String getDestItem() {
		return destItem;
	}

	public void setDestItem(String destItem) {
		this.destItem = destItem;
	}

	public boolean isRunFromScript() {
		return runFromScript;
	}

	public void setRunFromScript(boolean runFromScript) {
		this.runFromScript = runFromScript;
	}

	public Model getPatterns() {
		return patterns;
	}

	public void setPatterns(Model patterns) {
		this.patterns = patterns;
	}
}
