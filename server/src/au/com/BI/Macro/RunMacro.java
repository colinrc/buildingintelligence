/*
 * Created on Apr 13, 2004

 */
package au.com.BI.Macro;
import au.com.BI.User.*;
import java.util.*;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;

import au.com.BI.Flash.*;

import java.util.logging.*;

public class RunMacro extends Thread {

	protected List macro;
	protected User user;
	protected CommandQueue commandList;
	protected Logger logger;
	protected String macroName;
	protected boolean continueToEnd;
	protected Map runningMacros;
	protected boolean abort = false;
	protected boolean runningInTimer = false;
	protected CommandInterface origCommand;
	protected Cache cache = null;
	

	public RunMacro() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public RunMacro(List macro, User user, String macroName,CommandInterface origCommand) {
		super();
		this.macro = macro;
		this.user = user;
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.macroName = macroName;
		this.origCommand = origCommand;
		this.setName ("Macro runner : " + macroName);
	}
	
	public void setCommandList (CommandQueue commandList){
		this.commandList = commandList;
	}

	public void run () {
	    boolean repeating = false;
	    boolean doOnce = true;
	    boolean commandDone = false;
		ClientCommand started = new ClientCommand();
		started.setKey("MACRO");
		started.setExtraInfo(macroName);
		started.setCommand("started");
		started.setDisplayName("MACRO");
		cache.setCachedCommand("MACRO",started);
		commandList.add (started);
		
		while ((doOnce || repeating) && !continueToEnd && !abort) {
		    doOnce = false; // just run it once
			Iterator macroItems = macro.iterator();
			while (!abort && macroItems.hasNext()) {
			    commandDone = false;
			    try {
					ClientCommand clientCommand = (ClientCommand)((ClientCommand)(macroItems.next())).clone();
					clientCommand.setDisplayName(clientCommand.getKey());
				    if (origCommand != null) {
				    		if (clientCommand.getExtraInfo().startsWith("%")) {
				    			clientCommand.setExtraInfo(readParam(clientCommand.getExtraInfo()));
				    		}
				    		if (clientCommand.getExtra2Info().startsWith("%")) {
				    			clientCommand.setExtra2Info(readParam(clientCommand.getExtra2Info()));
				    		}
				    		if (clientCommand.getExtra3Info().startsWith("%")) {
				    			clientCommand.setExtra3Info(readParam(clientCommand.getExtra3Info()));
				    		}
				    		if (clientCommand.getExtra4Info().startsWith("%")) {
				    			clientCommand.setExtra4Info(readParam(clientCommand.getExtra4Info()));
				    		}
				    		if (clientCommand.getExtra5Info().startsWith("%")) {
				    			clientCommand.setExtra5Info(readParam(clientCommand.getExtra5Info()));
				    		}
				    		if (clientCommand.getCommandCode().startsWith("%")) {
				    			clientCommand.setCommand(readParam(clientCommand.getCommandCode()));
				    		}
				    		if (clientCommand.getKey().startsWith("%")) {
				    			clientCommand.setKey(readParam(clientCommand.getKey()));
				    		}
				    }
	
					if (clientCommand.getCommandCode().equals ("pause") && !continueToEnd) {
						long timeToSleep = 0;
						try {
							timeToSleep = Long.parseLong(clientCommand.getExtraInfo()) * (long)1000;
							logger.log(Level.FINEST,"Sleeping in macro for " + timeToSleep);
							Thread.sleep (timeToSleep);
							commandDone = true;
						} catch (NumberFormatException e) {
						} catch (InterruptedException e) {
							
						}
					}
					if (!commandDone && clientCommand.getCommandCode().equals ("enabled")) {
	
					}
					if (!commandDone &&  !runningInTimer &&  clientCommand.getCommandCode().equals ("goto")) {
					    commandDone = true;
					    if (clientCommand.getExtraInfo().equals ("start")) {
					        repeating = true;
					        logger.log (Level.FINE,"Repeating macro "+ macroName);
					    }
					}
						
					if (!commandDone) {
					    commandDone = true;
						commandList.add (clientCommand);
					}
			    } catch (CloneNotSupportedException ex){
			    	logger.log(Level.WARNING,"Macro execution failed, an element could not be run " + ex.getMessage());
			    }
			}
		}
		
		synchronized (runningMacros) {
		    runningMacros.remove(this.macroName);
		}
		
		ClientCommand finished = new ClientCommand();
		finished.setKey("MACRO");
		finished.setExtraInfo(macroName);
		finished.setCommand("finished");
		finished.setDisplayName("MACRO");
		synchronized (cache){
			cache.setCachedCommand("MACRO",finished);
		}
		commandList.add (finished);		
	}
	
	/*
	 * 
	 */
	public String readParam(String field){
		if (field.equals("%EXTRA%")){
			return origCommand.getExtra5Info();
		}
		if (field.equals("%EXTRA2%")){
			return origCommand.getExtra2Info();
		}
		if (field.equals("%EXTRA3%")){
			return origCommand.getExtra3Info();
		}
		if (field.equals("%COMMAND%")){
			return origCommand.getExtra4Info();
		}
		if (field.equals("%EXTRA5%")){
			return origCommand.getExtra5Info();
		}
		return field;
	}
	
    /**
     * @return Returns the runningMacros.
     */
    public Map getRunningMacros() {
        return runningMacros;
    }
    
    /**
     * @param runningMacros The runningMacros to set.
     */
    public void setRunningMacros(Map runningMacros) {
        this.runningMacros = runningMacros;
    }
    
    /**
     * @return Returns the continueToEnd.
     */
    public boolean isContinueToEnd() {
        return continueToEnd;
    }
    
    /**
     * @param continueToEnd The continueToEnd to set.
     */
    public void setContinueToEnd(boolean continueToEnd) {
        this.continueToEnd = continueToEnd;
    }
    /**
     * @return Returns the abort.
     */
    public boolean isAbort() {
        return abort;
    }
    /**
     * @param abort The abort to set.
     */
    public void setAbort(boolean abort) {
        this.abort = abort;
    }

	public Cache getCache() {
		return cache;
	}

	public void setCache(Cache cache) {
		this.cache = cache;
	}
}
