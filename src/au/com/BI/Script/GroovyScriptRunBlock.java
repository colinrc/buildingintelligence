package au.com.BI.Script;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.Level;
import java.util.logging.Logger;

public class GroovyScriptRunBlock {
	boolean enabled = true;
	ConcurrentLinkedQueue <ScriptParams>runs; 
	ConcurrentHashMap<Long,RunGroovyScript>running;
	public String statusString = "";
	public boolean stoppable = false;
	public boolean hidden = false;
	public Date lastUpdated = null;
	public String name = "";
	public String []fireOnChange;
	public boolean ableToRunMultiple = false;
	protected Logger logger;
	
	public GroovyScriptRunBlock () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		runs =new ConcurrentLinkedQueue<ScriptParams>();
		running = new ConcurrentHashMap<Long,RunGroovyScript>();
		lastUpdated = new Date();
	}
	
	public void clearRunningInfo (){
		runs.clear();
		running.clear();
	}
	
	public void addRun (ScriptParams param) {
		runs.add( param);
	}
	
	public void addRunningInfo (Long id, RunGroovyScript runGroovyScript){
		running.put(id, runGroovyScript);
	}
	
	public ScriptParams nextRun () {
			if (!runs.isEmpty() ) {
				ScriptParams params = runs.remove();
				return params;
			} else { 
				return null;
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
		
		for (RunGroovyScript runGroovyScript:running.values()){
			logger.log(Level.FINE, "Disable script " + this.getName());
			runGroovyScript.setEnable(enabled);
		}
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

	public boolean isHidden() {
		return hidden;
	}

	public void setHidden(boolean hidden) {
		this.hidden = hidden;
	}

	/**
	 * @param id
	 */
	public void scriptFinished(long id) {
		this.running.remove(id);
	}

	/**
	 * @return
	 */
	public boolean isRunning() {
		return (!this.running.isEmpty()) ;
	}

}
