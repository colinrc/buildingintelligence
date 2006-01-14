package au.com.BI.Script;
import java.util.*;

public class ScriptRunBlock {
	int repeatCount = 0;
	boolean enabled = true;
	LinkedList runs = null;
	public String statusString = "";
	public boolean stoppable = false;
	public Date lastUpdated = null;
	public String name = "";
	
	public ScriptRunBlock () {
		runs = new LinkedList();
		lastUpdated = new Date();
	}
	
	public void addRun (ScriptParams param) {
		synchronized (runs){
			if (runs.size() < 4 ) runs.add( param);
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
	



}
