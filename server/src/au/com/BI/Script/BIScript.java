/**
 * 
 */
package au.com.BI.Script;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.ValueNotUpdatedException;
import au.com.BI.LabelMgr.LabelMgr;
import au.com.BI.Macro.MacroHandler;
import groovy.lang.Binding;

/**
 * @author colin
 *
 */
public  class BIScript extends groovy.lang.Script {
	boolean ableToRunMultiple = false;
	boolean stoppable = false;
	boolean hidden = false;
	String [] fireOnChange = new String[0];
	String dummyArgs [] ;
	
	protected boolean triggerWasScript = false;
	protected String triggerCommand = "";
	protected String triggerExtra = "";
	protected String triggerExtra2 = "";
	protected String triggerExtra3 = "";
	protected String triggerExtra4 = "";
	protected String triggerExtra5 = "";
	protected long triggerTime = 0L;
	protected String triggerDisplayName = "";
	
	protected LabelMgr labelMgr;
	protected ScriptHandler scriptHandler;
	protected MacroHandler macroHandler;
	protected Cache cache;
	protected CommandInterface triggeringEvent;
	protected Model elife;
	protected au.com.BI.Patterns.Model patterns;
		
	public BIScript (){
		dummyArgs =new String [0];
	}
	
	public boolean isAbleToRunMultiple() {
		return ableToRunMultiple;
	}
	
	public void setAbleToRunMultiple(boolean isAbleToRunMultiple) {
		this.ableToRunMultiple = isAbleToRunMultiple;
	}
	
	public boolean isStoppable() {
		return stoppable;
	}
	
	public void setStoppable(boolean isStoppable) {
		this.stoppable = isStoppable;
	}
	
	public String[] getFireOnChange() {
		return fireOnChange;
	}
	
	public void setFireOnChange(String[] fireOnChange) {
		this.fireOnChange = fireOnChange;
	}
	
	public void doRegisterScript (LabelMgr labelMgr, au.com.BI.Patterns.Model patterns ){

		this.labelMgr = labelMgr;
		this.patterns = patterns;

		// can't rely on anything else yet being set up in the system.
		registerScript();
	}
	
	public Object  registerScript () {
		// this method is called when the script is first launched
		return null;
	}
	
    /**
     * @return Returns the current value for a device from a specified key.
     */
    public int minutesSinceChanged(String key) {
    	try {

            long duration = triggerTime - elife.getLastAccessTime(key);
            int returnVal = (int)(duration / 60000); // convert it to minutes
            return returnVal;
    	} catch (ValueNotUpdatedException ex){
    		return 0;
    	}
    }
    
	public Object run () {
		Binding binding = this.getBinding();
		labelMgr = (LabelMgr)binding.getVariable("labelMgr");
		scriptHandler = (ScriptHandler)binding.getVariable("scriptHandler");
		macroHandler = (MacroHandler)binding.getVariable("macroHandler");
		cache = (Cache)binding.getVariable("cache");
		triggeringEvent = (CommandInterface)binding.getVariable("triggeringEvent");
		elife = (Model)binding.getVariable("elife");
		patterns = (au.com.BI.Patterns.Model)binding.getVariable("patterns");
		
		if (triggeringEvent != null){
			triggerWasScript = triggeringEvent.isScriptCommand();
			triggerCommand = triggeringEvent.getCommandCode();
			triggerExtra = triggeringEvent.getExtraInfo();
			triggerExtra2 = triggeringEvent.getExtra2Info();
			triggerExtra3 = triggeringEvent.getExtra3Info();
			triggerExtra4 = triggeringEvent.getExtra4Info();
			triggerExtra5 = triggeringEvent.getExtra5Info();
			triggerTime = triggeringEvent.getCreationDate();
			triggerDisplayName = triggeringEvent.getDisplayName();
			if (triggerDisplayName.equals ("")) triggerDisplayName = triggeringEvent.getKey();
		}
		
		return main (dummyArgs);
	}
	
	public Object main (String [] arg){
		return null;
	}

	public boolean isHidden() {
		return hidden;
	}

	public void setHidden(boolean hidden) {
		this.hidden = hidden;
	}

}
