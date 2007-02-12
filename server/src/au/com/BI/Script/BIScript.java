/**
 * 
 */
package au.com.BI.Script;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.LabelMgr.LabelMgr;
import groovy.lang.Binding;

/**
 * @author colin
 *
 */
public  class BIScript extends groovy.lang.Script {
	boolean isAbleToRunMultiple = false;
	boolean isStoppable = false;
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
	protected Cache cache;
	protected CommandInterface triggeringEvent;
	protected Model elife;
		
	public BIScript (){
		dummyArgs =new String [0];
	}
	
	public boolean isAbleToRunMultiple() {
		return isAbleToRunMultiple;
	}
	
	public void setAbleToRunMultiple(boolean isAbleToRunMultiple) {
		this.isAbleToRunMultiple = isAbleToRunMultiple;
	}
	
	public boolean isStoppable() {
		return isStoppable;
	}
	
	public void setStoppable(boolean isStoppable) {
		this.isStoppable = isStoppable;
	}
	
	public String[] getFireOnChange() {
		return fireOnChange;
	}
	
	public void setFireOnChange(String[] fireOnChange) {
		this.fireOnChange = fireOnChange;
	}
	
	public Object run () {
		Binding binding = this.getBinding();
		labelMgr = (LabelMgr)binding.getVariable("labelMgr");
		cache = (Cache)binding.getVariable("cache");
		triggeringEvent = (CommandInterface)binding.getVariable("triggeringEvent");
		elife = (Model)binding.getVariable("elife");
		
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

}
