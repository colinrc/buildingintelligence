package au.com.BI.Script;
import java.util.*;

public class GroovyScriptRunBlock {
	int repeatCount = 0;
	boolean enabled = true;
	LinkedList <ScriptParams>runs = null;
	public String statusString = "";
	public boolean stoppable = false;
	public Date lastUpdated = null;
	public String name = "";
	public String []fireOnChange;
	public boolean ableToRunMultiple = false;
	
	public GroovyScriptRunBlock () {
		runs = new LinkedList<ScriptParams>();
		lastUpdated = new Date();
	}
	
	public void addRun (ScriptParams param) {
		synchronized (runs){
			runs.add( param);
		}
	}
	
	public ScriptParams nextRun () {
		synchronized (runs){
			if (!runs.isEmpty() ) {
				ScriptParams params = (ScriptParams)runs.getFirst();
				runs.removeFirst();
				return params;
			} else { 
				return null;
			}
		}
	}
	
	
	
	public boolean moreToRun() {
		if (runs.isEmpty() || !this.enabled)
			return false;
		else
			return true;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public String getStatusString() {
		return statusString;
	}

	public void setStatusString(String statusString) {
		this.statusString = statusString;
	}

	public boolean isStoppable() {
		return stoppable;
	}

	public void setStoppable(boolean stoppable) {
		this.stoppable = stoppable;
	}

	public Date getLastUpdated() {
		return lastUpdated;
	}

	public void setLastUpdated(Date lastUpdated) {
		this.lastUpdated = lastUpdated;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @param fireOnChange
	 */
	public void setFireOnChange(String[] fireOnChange) {
		this.fireOnChange = fireOnChange;
		
	}

	public String[] getFireOnChange() {
		return fireOnChange;
	}

	public boolean isAbleToRunMultiple() {
		return ableToRunMultiple;
	}

	public void setAbleToRunMultiple(boolean ableToRunMultiple) {
		this.ableToRunMultiple = ableToRunMultiple;
	}
	



}
