/*
 * Created on Oct 25, 2004
 *
 */
package au.com.BI.Script;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.Config.*;
import au.com.BI.Device.DeviceType;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.*;

import au.com.BI.ToggleSwitch.*;
import au.com.BI.Flash.*;

import au.com.BI.Script.ScriptHandler;
import au.com.BI.Script.Script.ScriptType;
import au.com.BI.User.User;
import org.jdom.Element;
import au.com.BI.JRobin.RRDValueObject;
import au.com.BI.Home.Controller;
import java.io.IOException;
import org.jrobin.core.*;
import java.io.*;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 * This module provides an interface to the system for Scripts.
 * @see DeviceModel for methods level documentation and methods availlable for hooking into functionality
 */
public class Model
  extends SimplifiedModel implements DeviceModel {

        public static int numberOfScripts = 0;
        public static final int numberRepeats = 4;
        public static final int MINUTE = 1;
        public static final int HOUR = 2;
        public static final int DAY = 3;
        protected boolean control = true;
        protected String parameter;
        protected Script deviceThatMatched;
        protected ScriptHandler scriptHandler;
        protected ScriptFileHandler scriptFileHandler;
        protected Controller mainController;
		protected Map <String,ScriptRunBlock>scriptRunBlockList = null;
		protected String statusFileName = "." + File.separator + "datafiles" + File.separator + "script_status.xml";
		protected String groovyStatusFileName = "." + File.separator + "datafiles" + File.separator + "groovy_script_status.xml";
        protected GroovyScriptHandler groovyScriptHandler;
        protected GroovyScriptFileHandler groovyScriptFileHandler;
		protected ConcurrentHashMap <String, GroovyScriptRunBlock>groovyScriptRunBlockList = null;
        
        protected Map scriptFiles;

        public Model() {
                super();
                this.setName("SCRIPT");
                scriptFileHandler = new ScriptFileHandler();
                groovyScriptFileHandler = new GroovyScriptFileHandler();
                groovyScriptRunBlockList = new ConcurrentHashMap <String, GroovyScriptRunBlock>(30);
                scriptRunBlockList = Collections.synchronizedMap(new LinkedHashMap<String,ScriptRunBlock> (30)); // 30 scripts to start with
                this.setAutoReconnect(false);
                try {
                        jbInit();
                }
                catch (Exception ex) {
                        ex.printStackTrace();
                }
        }

        public void setController(Controller myController) {
                mainController = myController;
        }

        public boolean removeModelOnConfigReload() {
                return false;
        }


        /**
         * New Devices are added via this method.
         * <P>
         * A script registering itself to listen to events should eventually call this method
         * The reference to the script will be an instance of au.com.BI.Script
         *
         */
        public void addControlledItem(String name, DeviceType details, MessageDirection controlType) {
                String theKey = name;
                if (configHelper.checkForControlledItem(theKey) == false) {
                        configHelper.addControlledItem(theKey, details, controlType);
                }
        }

        /**
         * Main test point for the controller to request from this model if it controls a particular Command
         * <P>
         * For items sent by flash this would be determed by the DISPLAY_NAME field in the command.
         * <BR>
         * For items from a comms port the actual received string will be interpretted.
         * <P>
         * CustomInput types will trigger particular Command structures to be built based on the string, which
         * could be tested for instead of the raw string.
         * <P>
         * Currently there is no mechanism for control from a particular model to stop other models also receiving
         * the command. For scripts that wish to block and interpret commands themself, changes will be needed to
         * the main DeviceModel list processing in the au.com.BI.Controller class
         */
        public boolean doIControl(String keyName, boolean isCommand) {
                configHelper.wholeKeyChecked(keyName);

                if (keyName.equals("SCRIPT"))return true;

                if (configHelper.checkForOutputItem(keyName)) {
                        logger.log(Level.FINER, "Flash sent command : " + keyName);
                        return true;
                }
                return false;
        }

        /**
         * After doIControl returns true doCommand will be called with the command in question.
         */
        public void doCommand(CommandInterface command) throws CommsFail {

                String theWholeKey = command.getKey();

				if (command.isClient()) {
					theWholeKey = command.getKey();
				} else {
					theWholeKey = command.getDisplayName();
				}

                if (theWholeKey.equals("SCRIPT")) {
                        doScriptItem(command, null); // script called via an explicit run command
                }
                else {
                        DeviceType device = configHelper.getOutputItem(theWholeKey);
                        logger.log(Level.FINE, "Extra Info: " + command.getExtraInfo());
                        if (device == null) {
                                logger.log(Level.WARNING,
                                  "Error in config, no output key for " + theWholeKey);
                        }
                        else {
                                if (device.getDeviceType() == DeviceType.SCRIPT) {

                                        try {
                                                CommandInterface newCommand;
                                                logger.log(Level.FINE,
                                                  "*********Running script " + ( (Script) device).getNameOfScript());
                                                newCommand = createInternalCommand("SCRIPT","", "run", ( (Script) device).getNameOfScript());
                                                newCommand.setTargetDeviceModel(0);
                                                //  configHelper.addControlledItem("SCRIPT", newCommand, DeviceType.OUTPUT);
                                                doScriptItem(newCommand, command); // called via a trigger
                                                // cache.setCachedCommand(newCommand.getKey(), newCommand);
                                                //   sendCommand("SCRIPT","run",( (Script) device).getNameOfScript());
                                        }
                                        catch (ClassCastException ex) {
                                                logger.log(Level.WARNING,
                                                  "An incorrect device type was marked as a script " +
                                                  ex.getMessage());
                                        }
                                }
                        }
                }
        }

    	
        public void doScriptItem(CommandInterface command, CommandInterface triggeringCommand) throws CommsFail {
                String theWholeKey = command.getKey();
                DeviceType device = configHelper.getOutputItem(theWholeKey);

                Command clientCommand = null;

                logger.log(Level.FINER, "Received script command");

                String commandStr = command.getCommandCode();
                String extra2 = command.getExtra2Info();
                User currentUser = command.getUser();
                if (commandStr.equals("run")) {
                	String scriptName = command.getExtraInfo();
	                   if (groovyScriptHandler.ownsScript (scriptName)){
	                        groovyScriptHandler.run(scriptName,command.getExtra2Info(), currentUser,triggeringCommand);
	                        logger.log(Level.FINER, "Run Groovy script request received " + command.getExtraInfo());
	                   } else {
	                        scriptHandler.run( scriptName,command.getExtra2Info(), currentUser,triggeringCommand);
	                        logger.log(Level.FINER, "Run Jython script request received " + command.getExtraInfo());	                	   
	                   }
                }

	            if (commandStr.equals("finished")) {
	            		String scriptName = command.getExtraInfo();
	                    logger.log(Level.FINER, "Finished script " + scriptName );
	                       
	                    if (!groovyScriptHandler.ownsScript (scriptName)){
	                    	// Old jython stuff
	                    	
	                       if (scriptHandler.finishedRunning(scriptName)) {
	                    	   	clientCommand = doGetList ("");  // no more to run, so update the client
	                       }
	                       else
	                       {
	                           scriptHandler.run(scriptName, triggeringCommand);
	                           logger.log(Level.FINER, "Running queued script " + command.getExtraInfo());
	                       }
	                   }
	                    	   
               }
				if (commandStr.equals("save")) {
	                if (extra2.equals("enabled")) {
	                	if (!groovyScriptHandler.enableScript( (String) command.getExtraInfo(), currentUser) && 
	                			!scriptHandler.enableScript( (String) command.getExtraInfo(), currentUser)  ){
	                		logger.log (Level.WARNING,"Enable was called for a script that does not exist");
	                }
	                else {
							clientCommand = doGetList ("");
	                        logger.log(Level.FINER, "Enable script " + command.getExtraInfo());
	                }
	                }
	                if (extra2.equals("disabled")) {
	                	if (!scriptHandler.disableScript( (String) command.getExtraInfo(), currentUser) &&
	                        !groovyScriptHandler.disableScript( (String) command.getExtraInfo(), currentUser) ) {
	                			logger.log (Level.WARNING,"Disable was called for a script that does not exist");
	                        } else {
								clientCommand = doGetList ("");
		                        logger.log(Level.FINER, "Disable script " + command.getExtraInfo());
		                    }
	                }
	                if (extra2.equals("enableAll")) {
	                        scriptHandler.enableAll();
	                        groovyScriptHandler.enableAll();
	                        
							clientCommand = doGetList ("");
	                        logger.log(Level.FINER, "Enable All scripts " + command.getExtraInfo());
	                }
	                if (extra2.equals("disableAll")) {
	                        scriptHandler.disableAll();
	                        groovyScriptHandler.disableAll();
							clientCommand = doGetList ("");
	                        logger.log(Level.FINER, "Disable All scripts " + command.getExtraInfo());
	                }
				}

                if (commandStr.equals("getList")) {
					clientCommand = doGetList (command.getExtraInfo());
                }

                if (commandStr.equals("setStatus")) {
					if (!groovyScriptHandler.setStatus(command.getExtraInfo(),command.getExtra2Info()) && 
							!scriptHandler.setStatus(command.getExtraInfo(),command.getExtra2Info())) {
			
						logger.log(Level.WARNING,
							"A script status update was received for a script that does not exist "
									+ name);
                	} else {
                		clientCommand = doGetList ("");
                		logger.log(Level.FINER, "Setting status for " + command.getExtraInfo() + "=" + command.getExtra2Info());
                	}
                }

                if (commandStr.equals("abort")) {
                	groovyScriptHandler.abort(command.getExtraInfo());
					scriptHandler.abort(command.getExtraInfo());
					clientCommand = doGetList ("");
                    logger.log(Level.FINER, "Aborting script " + command.getExtraInfo());
                }

                if (clientCommand != null) {
                        clientCommand.setTargetDeviceID(command.getTargetDeviceID());
                        clientCommand.setDisplayName("SCRIPT");
                        cache.setCachedCommand("SCRIPT", clientCommand);
                         commandQueue.add(clientCommand);
                }
        }
	        /*    
	    public void scriptFinished (long ID){
	    	Command clientCommand = null;
	    	
        		String scriptName = command.getExtraInfo();
                logger.log(Level.FINER, "Finished script " + scriptName );
               if (groovyScriptHandler.ownsScript (scriptName)){
                   if (groovyScriptHandler.finishedRunning(scriptName)) {
                	   	clientCommand = doGetList ("");  // no more to run, so update the client
                   }
                   else
                   {
                       groovyScriptHandler.run(scriptName, triggeringCommand);
                       logger.log(Level.FINER, "Running queued script " + command.getExtraInfo());
                   }
               }
               
               
               if (clientCommand != null ) {
            	   Command clientCommand = doGetList ("");
               }
                clientCommand.setTargetDeviceID(command.getTargetDeviceID());
                clientCommand.setDisplayName("SCRIPT");
                cache.setCachedCommand("SCRIPT", clientCommand);
                 commandQueue.add(clientCommand);
	    }
	    */
                   
		public void sendListToClient() {
			ClientCommand clientCommand = (ClientCommand)doGetList("");
			clientCommand.setTargetDeviceID(-1);
            cache.setCachedCommand("SCRIPT", clientCommand);
            commandQueue.add(clientCommand);
		}

		public ClientCommand doGetList (String key) {
            logger.log(Level.FINER, "Fetching script list");
            if (scriptHandler == null  || groovyScriptHandler == null){
            	logger.log (Level.WARNING,"The list of scripts was requested before it has been loaded");
            	return null;
            }
    		Element top = new Element("SCRIPT");
    		List <Element>eachScript = scriptHandler.get(key);
    		for (Element i : eachScript){    			
				try {
						top.addContent(i);
				} catch (NoSuchMethodError ex) {
					logger.log(Level.SEVERE, "Error calling jdom library "
							+ ex.getMessage());
				}
    		}
    		
    		List <Element>eachGroovyScript = groovyScriptHandler.get(key);
    		for (Element i : eachGroovyScript){    			
				try {
						top.addContent(i);
				} catch (NoSuchMethodError ex) {
					logger.log(Level.SEVERE, "Error calling jdom library "
							+ ex.getMessage());
				}
    		}
				
          ClientCommand clientCommand = new ClientCommand();
            clientCommand.setFromElement(top);
            clientCommand.setKey("CLIENT_SEND");
			return clientCommand;
	} 

        public void sendToFlash(CommandInterface command) {
                cache.setCachedCommand(command.getDisplayName(), command);
                commandQueue.add(command);
        }

        public CommandQueue getCommandQueue() {
                        return commandQueue;
        }

        public String buildDirectConnectString(ToggleSwitch device,
          CommandInterface command) {
                boolean commandFound = false;

                String rawSerialCommand = doRawIfPresent(command, device);
                if (rawSerialCommand != null) {
                        commandFound = true;
                }
                String theCommand = command.getCommandCode();
                if (!commandFound && theCommand == "") {
                        logger.log(Level.WARNING,
                          "Empty command received from client " + command.getCommandCode());
                        return null;
                }
                else {
                        logger.log(Level.FINER, "Build comms string " + rawSerialCommand);

                        return rawSerialCommand;
                }
        }

        public void finishedReadingConfig() throws SetupException {
        	super.finishedReadingConfig();
			loadScripts();
        }
        
 	    	public void doClientStartup(CommandQueue commandQueue, long targetFlashDeviceID, long serverID){
	    		if (scriptHandler != null) {
		    	    ClientCommand clientCommand = this.doGetList("");
		    	    clientCommand.setKey ("CLIENT_SEND");
		    	    clientCommand.setTargetDeviceID(targetFlashDeviceID);
		    	    commandQueue.add(clientCommand);
	    		}
	    	};
	    	
	    	public void loadScripts (){
	    		loadGroovyScripts();
	    		loadJythonScripts();
	    	}
	    	
	    	public void loadGroovyScripts () {
	        	try {
	        		groovyScriptFileHandler.loadScripts(this, "./script", groovyScriptRunBlockList, patterns,labelMgr);
	                groovyScriptHandler = new GroovyScriptHandler(this, groovyScriptRunBlockList, groovyStatusFileName,groovyScriptFileHandler.getGse());
	        		for (String scriptName :groovyScriptRunBlockList.keySet()){
	        			Script newScript = new Script();
	        			GroovyScriptRunBlock scriptRunBlock = groovyScriptRunBlockList.get (scriptName);
	        			newScript.setNameOfScript(scriptName);
	        			newScript.setScriptType (ScriptType.Groovy);
	        			registerGroovyScript (scriptName, newScript,  scriptRunBlock);
	        		}
	        		logger.log(Level.FINE,"Loaded Groovy scripts");
	        		groovyScriptHandler.loadScriptFile();
	        	} catch (ConfigError ex){
	        		logger.log (Level.WARNING,"Problem reading the script files " + ex.getMessage());
	        	}
	    	}

	    	public void registerGroovyScript (String myScript, Script currentScript,GroovyScriptRunBlock scriptRunBlock){
	    		for (String triggerTags :scriptRunBlock.getFireOnChange()){
	    		  addControlledItem(triggerTags, currentScript, MessageDirection.FROM_FLASH);
	    		}
	    	}
	    	
        public void loadJythonScripts() {
                int j = 0;
                logger.log(Level.FINE,"Loading scripts");

                String lsLine, lsCheck;
                ArrayList linesOfFile, scripts;
                Object hashKey;
                Map files;
                Script currentScript;

                lsLine = new String();
                lsCheck = new String();
                scripts = new ArrayList();
                try {
                        scriptHandler.removeAllTimers();

                }
                catch (Exception ex) {
                        //continue
                }
				//get the script files and prepare for parsing
                try {
	                scriptFileHandler.loadScripts(this, "./script/",this.scriptRunBlockList);
	
	                //loadScripts();
	                files = getScriptFiles();
	                Set sFiles = files.keySet();
	                Iterator iteratorHash = sFiles.iterator();
	
	                setNumberOfScripts(files.size());
	                scriptHandler = new ScriptHandler(getNumberOfScripts(), this, scriptRunBlockList,statusFileName); //,this.commandQueue);
	                scriptHandler.setCache (cache);
	
					scriptHandler.loadScriptFile();
	
	                scriptHandler.initTimerLists();
	                while (iteratorHash.hasNext()) {
	                        hashKey = iteratorHash.next();
	                        linesOfFile = (ArrayList) files.get(hashKey);
	                        scripts.add(new Script());
	                        currentScript = (Script) scripts.get(j);
	                        currentScript.setNameOfScript( (String) hashKey);
	
	                        int i = 0;
	                        lsLine = "";
	
	                        // Now collect the lines looking for items to remove.
	                        while (i < linesOfFile.size()) {
	                                lsLine = lsLine + linesOfFile.get(i);
	                                i++;
	                        }
	                        parseScript(lsLine, currentScript);
	                        j++;
	                }
	                scriptHandler.addTimerControls();
	                logger.log(Level.FINE,"Scripts loaded");
                } catch (ConfigError ex){
                	logger.log(Level.WARNING,"Scripts system could not be set up " + ex.getMessage());
                }
        }

        public void parseScript(String myScript, Script currentScript) {
                int begin = 0;
                int end = 0;
                int deviceType = 0;
                String controlled, duration;

                // Step 1. Look for any fireScriptOn commands, these will be controlled and cause the script to fire when the device value is changed, all other firing of commands will be ignored
                begin = myScript.indexOf("elife.fireScriptOn", 1);
                boolean found = false;
                while (begin > 0) {
                        found = true;
                        begin = myScript.indexOf("(\"", begin);
                        begin = begin + 2;
                        end = myScript.indexOf("\"", begin);
                        controlled = myScript.substring(begin, end);
                        //deviceType = getDeviceType(controlled);
                        //if (deviceType >= 0) {
                        addControlledItem(controlled, currentScript, MessageDirection.FROM_FLASH);

                        //}
                        begin = myScript.indexOf("elife.fireScriptOn", end);
                        if (begin > 0) {
                                begin = myScript.indexOf("(\"", begin);
                        }
                        ;
                }
                if (found == true)return;

                // Step 2. Look for any listenMacro commands, these will be controlled and cause the script to fire when the macro is run, all other firing of commands will be ignored
               begin = myScript.indexOf("elife.listenMacro", 1);
               while (begin > 0) {
                       begin = myScript.indexOf("(\"", begin);
                       begin = begin + 2;
                       end = myScript.indexOf("\"", begin);
                       controlled = myScript.substring(begin, end);
                       //deviceType = getDeviceType(controlled);
                       //if (deviceType >= 0) {
                       addControlledItem(controlled, currentScript, MessageDirection.FROM_FLASH);
                       //}
                       begin = myScript.indexOf("elife.listenMacro", end);
                       if (begin > 0) {
                               begin = myScript.indexOf("(\"", begin);
                       }
                       ;
               }

                // Step 3. Look for any getValue commands, these will be controlled and cause the script to fire when their value changes
                begin = myScript.indexOf("elife.getValue", 1);
                while (begin > 0) {
                        begin = myScript.indexOf("(\"", begin);
                        begin = begin + 2;
                        end = myScript.indexOf("\"", begin);
                        controlled = myScript.substring(begin, end);
                        //deviceType = getDeviceType(controlled);
                        //if (deviceType >= 0) {
                        addControlledItem(controlled, currentScript, MessageDirection.FROM_FLASH);
                        //}
                        begin = myScript.indexOf("elife.getValue", end);
                        if (begin > 0) {
                                begin = myScript.indexOf("(\"", begin);
                        }
                        ;
                }

                // Step 4. Look for any getCommand commands, these will be controlled and cause the script to fire when their value changes
                begin = myScript.indexOf("elife.getCommand", 1);
                while (begin > 0) {
                        begin = myScript.indexOf("(\"", begin);
                        begin = begin + 2;
                        end = myScript.indexOf("\"", begin);
                        controlled = myScript.substring(begin, end);
                        //deviceType = getDeviceType(controlled);
                        //if (deviceType >= 0) {
                        addControlledItem(controlled, currentScript, MessageDirection.FROM_FLASH);
                        //}
                        begin = myScript.indexOf("elife.getCommand", end);
                        if (begin > 0) {
                                begin = myScript.indexOf("(\"", begin);
                        }
                        ;
                }

                // Step 5. Look for any getLastAccessTimeDuration commands, these will be timmed and cause the script to fire at each timed interval

                begin = myScript.indexOf("elife.getLastAccessTimeDuration", 1);
                while (begin > 0) {
                        begin = myScript.indexOf("(\"", begin);
                        begin = begin + 2;
                        end = myScript.indexOf("\"", begin);
                        controlled = myScript.substring(begin, end);

                        begin = myScript.indexOf(",\"", end);
                        begin = begin + 2;
                        end = myScript.indexOf("\"", begin);
                        duration = myScript.substring(begin, end);

                        if (duration.equals("minute")) {
                                scriptHandler.addTimerListMinute(currentScript.getNameOfScript());
                        }
                        else if (duration.equals("hour")) {
                                scriptHandler.addTimerListHour(currentScript.getNameOfScript());
                        }
                        else if (duration.equals("day")) {
                                scriptHandler.addTimerListDay(currentScript.getNameOfScript());
                        }

                        begin = myScript.indexOf("elife.getLastAccessTimeDuration", end);
                        if (begin > 0) {
                                begin = myScript.indexOf("(\"", begin);
                        }
                        ;
                }
                // Step 6. Look for any isScriptStillRunning commands, these will be controlled and cause the script to fire when the device value is changed, all other firing of commands will be ignored
                begin = myScript.indexOf("elife.isScriptStillRunning", 1);
				synchronized (this.scriptRunBlockList) {
					String nameOfScript = ((Script)currentScript).nameOfScript;
					ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get(nameOfScript);
					if (scriptRunBlock != null) {
		                if (begin > 0) {
		                		scriptRunBlock.setStoppable(true);
						} else {
	                		scriptRunBlock.setStoppable(false);						}
					}
	             }
        }

        public MessageDirection getDeviceType(String key) {
                /**
                 * @return The device type
                 * @deprecated
                 */

                DeviceModel currentModel;
                ConfigHelper currentConfigHelper;
                String showModel;

                Iterator allModels = getModelList().iterator();

                while (allModels.hasNext()) {
                        currentModel = (DeviceModel) allModels.next();

                        showModel = currentModel.getName();
                        logger.log(Level.FINE, "Checking for script references in model ..." + showModel);
                        if (showModel != "SCRIPT") { //getName()) {

                                currentConfigHelper = currentModel.getConfigHelper();
                                if (currentConfigHelper.checkForControl(key)) {
                                        logger.log(Level.FINE, "Found Key:" + key + "... Processing model ..." + showModel);
                                        return MessageDirection.FROM_FLASH;
                                }

                        }
                }

                return MessageDirection.UNKNOWN;
        }

        /*
                if (currentConfigHelper.checkForInputItem(key)) {
                  return DeviceType.INPUT;
                }
                if (currentConfigHelper.checkForOutputItem(key)) {
                  return DeviceType.OUTPUT;
                }
                if (currentConfigHelper.checkForControlledItem(key)) {
                  return DeviceType.MONITORED;
                }

                return 2;

              }

            }

            return -1;

          }     */

        // Start of the scripting Objects

        // Used by the script by elife.method



        /**
         * @return Returns the current value for a device from a specified key.
         */
        public boolean isOn(String key) {
                CacheWrapper cachedValue = cache.getCachedObject(key);
                if (cachedValue == null) {
                        return false;
                }
                CommandInterface lastValue;
                if (cachedValue.isSet() == true) {
                	lastValue = (cachedValue.getMap()).get("on");
                } else {
					lastValue = cachedValue.getCommand();
                }
    			if (lastValue != null && lastValue.getCommandCode().equals ("on")) {
    				return true;
    			} else {
    				return false;
    			}
        }
        
        /**
         * @return Returns the current value for a device from a specified key.
         */
        public boolean isOff(String key) {
                CacheWrapper cachedValue = cache.getCachedObject(key);
                if (cachedValue == null) {
                        return false;
                }
                CommandInterface lastValue;
                if (cachedValue.isSet() == true) {
                	lastValue = (cachedValue.getMap()).get("off");
                } else {
					lastValue = cachedValue.getCommand();
                }
    			if (lastValue != null && lastValue.getCommandCode().equals ("off")) {
    				return true;
    			} else {
    				return false;
    			}
        }
        
        /**
         * @return Returns the current value for a device from a specified key.
         */
        public Object getValue(String key) {
                CacheWrapper cachedValue = cache.getCachedObject(key);
                if (cachedValue == null) {
                        return "None";
                }
                if (cachedValue.isSet() == false) {
                        Command retCommand;
                        retCommand = (Command) cachedValue.getCommand();
                        return retCommand.getExtraInfo();
                }else {
                	return "isSet";
                }
        }

        /**
         * @return Returns the current value for a device from a specified key.
         */
        public Object getValue(int extraVal, String key) {
            CacheWrapper cachedValue = cache.getCachedObject(key);
                if (cachedValue == null) {
                        return "None";
                }
                if (cachedValue.isSet() == false) {
                        Command retCommand;
                        retCommand = (Command) cachedValue.getCommand();
                        switch (extraVal) {
                                case 1:
                                        return retCommand.getExtraInfo();
                                case 2:
                                        return retCommand.getExtra2Info();
                                case 3:
                                        return retCommand.getExtra3Info();
                                case 4:
                                        return retCommand.getExtra4Info();
                                case 5:
                                        return retCommand.getExtra5Info();
                        }
                        return retCommand.getExtraInfo();
                }else {
                	return "isSet";
                }
        }

        
        /**
         * @return Returns the last accessed time of a device.
         */
        public Object getLastAccessTime(String key) {
                Object cachedValue;
                cachedValue = cache.getCachedTime(key);
                if (cachedValue == null | cachedValue.equals(new Long(0))) {
                        return "None";
                }
                return cachedValue;
        }

        /**
         * @return Returns the number of minutes since the device was last used.
         */
        public Object getLastAccessTimeDuration(String key, String interval) {
                Long cachedLongValue, retValue;
                Object cachedValue;
                long duration;
                long cachedTime = 0;
                java.lang.Double doubleValue;
                cachedValue = cache.getCachedTime(key);
                if (cachedValue == null | cachedValue.equals(new Long(0))) {
                        return "None";
                }
                cachedLongValue = (Long) cachedValue;
                cachedTime = cachedLongValue.longValue();
                duration = System.currentTimeMillis() - cachedTime;
                if (interval == "minute") {
                        duration = duration / 60000;
                }
                else if (interval == "hour") {
                        duration = duration / 3600000;
                }
                else if (interval == "day") {
                        duration = duration / 86400000;
                }
                retValue = new Long(duration);
                return retValue;
        }

        /**
         * @return Returns the current value for a device from a specified key and extra.
         * Jeff what are you trying to do here. this won't work?
         */
		/*
        public Object getValue(String key, String extra) {

                Object returnValue;
                HashMap ObjectAtributes;
                CacheWrapper cachedValue = cache.getCachedObject(key);
                if (cachedValue != null) {
                        if (cachedValue.isSet() == true) {
                                ObjectAtributes = (HashMap) cachedValue;
                                returnValue = ObjectAtributes.get(extra);
                                return returnValue.toString();
                        }
                }
                return "None";
        }
        */

        /**
         *  Returns all current commands .
         */
        public void dumpCommands() {
                Iterator cachedCommands;
                Iterator theHashCachedCommands;
                Object loCommand;
                String lsCommand;
                Collection hashCommands;
                Map ObjectAtributes;
                cachedCommands = cache.getStartupItemList();
                while (cachedCommands.hasNext()) {
                        loCommand = cachedCommands.next();
                        if (loCommand.getClass().getName().equals("java.util.Map")) {
                                theHashCachedCommands = (Iterator) loCommand;
                                while (theHashCachedCommands.hasNext()) {
                                        lsCommand = theHashCachedCommands.next().toString();
                                        logger.log(Level.FINE, "HashCommand : " + lsCommand);
                                }
                        }
                        else {
                                lsCommand = loCommand.toString();
                                logger.log(Level.FINE, "Command : " + lsCommand);
                        }
                }
        }

        /**
         * @return Returns the system Command for a given key.
         */
        public Object getCommand(String key) {
            CacheWrapper cachedValue = cache.getCachedObject(key);
                if (cachedValue == null) {
                        return "None";
                }
                if (cachedValue.isSet() == false) {
                        Command retCommand;
                        retCommand = (Command) cachedValue.getCommand();
                        return retCommand.getCommandCode();
                } else {
                	return "isSet";
                }
        }



     /**
           * @param key,command,extra Create a command system command.
           */
          private CommandInterface createInternalCommand(String key, String display, String command, String extra) {
                  CommandInterface sendCommand;
                      sendCommand = new Command();
                      sendCommand.setCommand(command);
                      sendCommand.setExtraInfo(extra);
                      sendCommand.setDisplayName(display);
                      sendCommand.setKey(key);
                      return sendCommand;
     }


          /**
           * @param key,command,extra Create a command system command.
           */
          public void sendCommand(String key, String command) {

       	   sendCommand ( key,  command,  "",  "",  "",  "","");
          }

       /**
        * @param key,command,extra Create a command system command.
        */
       public void sendCommand(String key, String command, String extra) {

    	   sendCommand ( key,  command,  extra,  "",  "",  "","");
       }

       /**
        * @param key,command,extra1,extra2 Create a command system command.
        */
       public void sendCommand(String key, String command, String extra1, String extra2) {

    	   sendCommand ( key,  command,  extra1,  extra2,  "",  "","");
       }

         /**
          * @param key,command,extra1,extra2,extra3 Create a command system command.
          */
         public void sendCommand(String key, String command, String extra1, String extra2, String extra3) {
        	 sendCommand ( key,  command,  extra1,  extra2,  extra3,  "","");
         }

         /**
          * @param key,command,extra1,extra2,extra3,extra4 Create a command system command.
          */
         public void sendCommand(String key, String command, String extra1, String extra2, String extra3, String extra4) {

        	 sendCommand ( key,  command,  extra1,  extra2,  extra3,  extra4,"");
         }

         /**
          * @param key,command,extra1,extra2,extra3,extra4,extra5 Create a command system command.
          * The same structure is used in the pattern module
          */
         public void sendCommand(String key, String command, String extra1, String extra2, String extra3, String extra4, String extra5) {

             ClientCommand myCommand;
             myCommand = new ClientCommand();
             myCommand.setCommand(command);
             myCommand.setExtraInfo(extra1);
             myCommand.setExtra2Info(extra2);
             myCommand.setExtra3Info(extra3);
             myCommand.setExtra4Info(extra4);
             myCommand.setExtra5Info(extra5);
             myCommand.setTargetDeviceID(0);
             myCommand.setScriptCommand(true);
             myCommand.setKey(key);
             sendToFlash(myCommand);
             
             return;

         }
         
         
       /**
        * @param rrd,dataSource, value Update an rrd named rrd.
        */
       public void updateRRD(String rrd, String dataSource, double value) {
               CommandInterface sendCommand;
               sendCommand = new Command();
               RRDValueObject rrdVO;
               rrdVO = new RRDValueObject();
               rrdVO.setRRD(rrd);
               rrdVO.setDataSource(dataSource);
               rrdVO.setRRDValue(value);
               sendCommand.setRrdValueObject(rrdVO);
               sendCommand.setKey("RRDUPDATE");
               sendToFlash(sendCommand);
       }

        /**
         * @param rrd, time, dataSource, value Update an rrd named rrd.
         */
        public void updateRRD(String rrd, float time, String dataSource, double value) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setRRD(rrd);
                rrdVO.setDataSource(dataSource);
                rrdVO.setRRDValue(value);

                long ltime;
                ltime = new Float(time).longValue();

                rrdVO.setStartTime(ltime);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDUPDATE");
                sendToFlash(sendCommand);
        }

        /**
         * @param rrd,dataSource, value Update an rrd named rrd.
         */
        public void updateRRD(String rrd, float time, double[] values) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setRRD(rrd);
                rrdVO.setRRDValues(values);

                long ltime;
                ltime = new Float(time).longValue();

                rrdVO.setStartTime(ltime);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDUPDATE");
                sendToFlash(sendCommand);
        }

        /**
         * @param rrd,dataSource fetch a record from the rrd named rrd.
         */
        public FetchData fetchDataRRD(String rrd, String dataSource, float startTime, float endTime) {
                RrdDb rrdDb;
                rrdDb = null;
                double rrdValue;
                rrdValue = 0;
                FetchData fetchData;
                fetchData = null;

                long lstart,lend;
                lstart = new Float(startTime).longValue();
                lend = new Float(endTime).longValue();


                try {
                        rrdDb = mainController.jRobinSupport.useRrd(mainController.jRobinSupport.getRRDBDIRECTORY() + rrd + ".rrd");
                        FetchRequest fetchRequest = rrdDb.createFetchRequest(dataSource, lstart, lend);
                        fetchData = fetchRequest.fetchData();
                }
                catch (IOException e) {
                        logger.log(Level.SEVERE,
                          "IO Exception error " + e.getMessage() + e.toString());
                }
                catch (RrdException e) {
                        logger.log(Level.SEVERE,
                          "RRD Exception error " + e.getMessage() + e.toString());
                }
                finally {
                        try {
                                mainController.jRobinSupport.releaseRrd(rrdDb);
                        }
                        catch (IOException e) {
                                logger.log(Level.SEVERE,
                                  "IO Exception error " + e.getMessage() + e.toString());
                        }
                        catch (RrdException e) {
                                logger.log(Level.SEVERE,
                                  "RRD Exception error " + e.getMessage() + e.toString());
                        }
                        return fetchData;
                }
        }

        /**
         * @param graphName, graphTemplate, width, height, quality, graphType, startTime, endTime, title
         * getGraph is used to produce graphs from the RRD's.
         */
        public void getGraph(String graphName, String graphTemplate, int width, int height, float quality, String graphType, float startTime, float endTime, String title) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setGraphName(graphName);
                rrdVO.setGraphTemplate(graphTemplate);
                rrdVO.setWidth(width);
                rrdVO.setHeight(height);
                rrdVO.setQuality(quality);
                rrdVO.setGraphType(graphType);

                long lstart,lend;
                lstart = new Float(startTime).longValue();
                lend = new Float(endTime).longValue();

                rrdVO.setStartTime(lstart);
                rrdVO.setEndTime(lend);
                rrdVO.setTitle(title);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDGRAPH");
                sendToFlash(sendCommand);
        }

        /**
         * @param graphName, graphTemplate, width, height, graphType, startTime, endTime, title
         * getGraph is used to produce graphs from the RRD's.
         */
        public void getGraph(String graphName, String graphTemplate, int width, int height, String graphType, float startTime, float endTime, String title) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setGraphName(graphName);
                rrdVO.setGraphTemplate(graphTemplate);
                rrdVO.setWidth(width);
                rrdVO.setHeight(height);
                rrdVO.setQuality(1.0f);
                rrdVO.setGraphType(graphType);

                long lstart,lend;
                lstart = new Float(startTime).longValue();
                lend = new Float(endTime).longValue();

                rrdVO.setStartTime(lstart);
                rrdVO.setEndTime(lend);
                rrdVO.setTitle(title);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDGRAPH");
                sendToFlash(sendCommand);
        }

        /**
         * @param graphName, graphTemplate, width, height, quality, graphType, startTime, endTime
         * getGraph is used to produce graphs from the RRD's.
         */
        public void getGraph(String graphName, String graphTemplate, int width, int height, String graphType, float startTime, float endTime) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setGraphName(graphName);
                rrdVO.setGraphTemplate(graphTemplate);
                rrdVO.setWidth(width);
                rrdVO.setHeight(height);
                rrdVO.setQuality(1.0f);
                rrdVO.setGraphType(graphType);

                long lstart,lend;
                lstart = new Float(startTime).longValue();
                lend = new Float(endTime).longValue();

                rrdVO.setStartTime(lstart);
                rrdVO.setEndTime(lend);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDGRAPH");
                sendToFlash(sendCommand);
        }

        /**
         * @param graphName, graphTemplate, width, height, quality, graphType
         * getGraph is used to produce graphs from the RRD's.
         */
        public void getGraph(String graphName, String graphTemplate, int width, int height, String graphType) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setGraphName(graphName);
                rrdVO.setGraphTemplate(graphTemplate);
                rrdVO.setWidth(width);
                rrdVO.setHeight(height);
                rrdVO.setQuality(1.0f);
                rrdVO.setGraphType(graphType);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDGRAPH");
                sendToFlash(sendCommand);
        }
        
        /**
         * @param dipslayName
         * getLabelState is used to find the state of a particular label. The returned string is the key from the lookup table.
         */
        public String getLabelState(String displayName) {
        	return labelMgr.getLabelState(displayName);
        }

        /**
         * @param graphName, graphTemplate, width, height
         * getGraph is used to produce graphs from the RRD's.
         */
        public void getGraph(String graphName, String graphTemplate, int width, int height) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setGraphName(graphName);
                rrdVO.setGraphTemplate(graphTemplate);
                rrdVO.setWidth(width);
                rrdVO.setHeight(height);
                rrdVO.setQuality(1.0f);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDGRAPH");
                sendToFlash(sendCommand);
        }

        /**
         * @param graphName, graphTemplate, title,width, height
         * getGraph is used to produce graphs from the RRD's.
         */
        public void getGraph(String graphName, String graphTemplate, String title, int width, int height) {
                CommandInterface sendCommand;
                sendCommand = new Command();
                RRDValueObject rrdVO;
                rrdVO = new RRDValueObject();
                rrdVO.setGraphName(graphName);
                rrdVO.setGraphTemplate(graphTemplate);
                rrdVO.setWidth(width);
                rrdVO.setHeight(height);
                rrdVO.setQuality(1.0f);
                rrdVO.setTitle(title);
                sendCommand.setRrdValueObject(rrdVO);
                sendCommand.setKey("RRDGRAPH");
                sendToFlash(sendCommand);
        }

        /**
         * @param title,icon,message,autoClose,hideClose Send a system message.
         */
        public void sendMessage(String title, String icon, String message, String autoClose, String hideClose) {
                ClientCommand sendMessage;
                sendMessage = new ClientCommand();
                sendMessage.setMessageType(CommandInterface.Message);
                sendMessage.setTitle(title);
                sendMessage.setIcon(icon);
                sendMessage.setContent(message);
                sendMessage.setAutoclose(autoClose);
                sendMessage.setHideclose(hideClose);
                sendToFlash(sendMessage);
        }

        /**
         * @param String,String,String Send video commands for key,command,extra.
         */
        public void video(String key, String command, String extra) {
                ClientCommand video;
                video = new ClientCommand();
                video.setMessageType(ClientCommand.Video);
                video.setCommand(command);
                video.setExtraInfo(extra);
                video.setDisplayName(key);
                video.setTargetDeviceID( 0);
                video.setKey(key);

                sendToFlash(video);
        }

        /**
         * @param String,String Turn on the device to the passed in value.
         */
        public void on(String key, String extra) {
        	this.sendCommand(key,"on", extra,"","","","");

        }

        /**
         * @param String,String Turn on the device to the passed in value.
         */
        public void on(String key, String extra, String extra2) {
        	this.sendCommand(key,"on", extra, extra2,"","","");
        }

        /**
         * @param String,String Turn on the device to the passed in value.
         */
        public void on(String key, String extra, String extra2, String extra3) {
        	this.sendCommand(key,"on", extra, extra2,extra3,"","");
        }

        /**
         * @param String,String Turn on the device to the passed in value.
         */
        public void on(String key, String extra, String extra2, String extra3, String extra4) {
        	this.sendCommand(key,"on", extra, extra2,extra3,extra4,"");
        }

        /**
         * @param String,String Turn on the device to the passed in value.
         */
        public void on(String key, String extra, String extra2, String extra3, String extra4, String extra5) {
        	this.sendCommand(key,"on", extra, extra2,extra3,extra4,extra5);
        }

        /**
         * @param String Turn on the device to 100.
         */
        public void on(String key) {
        	this.sendCommand(key,"on", "100", "","","","");
        }

        /**
         * @param String Turn off the device to 0.
         */
        public void off(String key) {
        	this.sendCommand(key,"off", "0", "","","","");
        }

        /**
           * @param String Turn off the device and set extra values as passed in.
           */
          public void off(String key, String extra) {
          	this.sendCommand(key,"off", extra,"","","","");
          }

          /**
           * @param String Turn off the device and set extra values as passed in.
           */
          public void off(String key, String extra, String extra2) {
          	this.sendCommand(key,"off", extra, extra2,"","","");
          }

          /**
           * @param String Turn off the device and set extra values as passed in.
           */
          public void off(String key, String extra, String extra2, String extra3) {
          	this.sendCommand(key,"off", extra, extra2,extra3,"","");
          }

          /**
           * @param String Turn off the device and set extra values as passed in.
           */
          public void off(String key, String extra, String extra2, String extra3, String extra4) {
          	this.sendCommand(key,"off", extra, extra2,extra3,extra4,"");
          }

          /**
           * @param String Turn off the device and set extra values as passed in.
           */
          public void off(String key, String extra, String extra2, String extra3, String extra4, String extra5) {
          	this.sendCommand(key,"off", extra, extra2,extra3,extra4,extra5);
          }
          
          /**
           * Send an IR instruction.
           */
          public void sendIR (String AVDevice, String IR_Key, String numberRepeats) {
          	this.sendCommand(AVDevice, "AV." + AVDevice ,IR_Key, numberRepeats);
          }

          /**
           * Send an IR instruction.
           */
          public void sendIR (String AVDevice, String IR_Key) {
          	this.sendCommand(AVDevice, "AV." + AVDevice ,IR_Key, "1");
          }

          public String getSource (String key)   {
              CacheWrapper cachedValue = cache.getCachedObject(key);
              if (cachedValue == null) {
                      return "unknown";
              }
              CommandInterface lastValue;
              if (cachedValue.isSet() == true) {
              	lastValue = (cachedValue.getMap()).get("src");
              } else {
					lastValue = cachedValue.getCommand();
              }
  			if (lastValue == null || lastValue.getExtraInfo().equals("")) {
  				return "unknown";
  			} else {
  				return lastValue.getExtraInfo();
 
  			}
          }
          
          public String getVolume (String key)   {
              CacheWrapper cachedValue = cache.getCachedObject(key);
              if (cachedValue == null) {
                      return "unknown";
              }
              CommandInterface lastValue;
              if (cachedValue.isSet() == true) {
              	lastValue = (cachedValue.getMap()).get("volume");
              } else {
					lastValue = cachedValue.getCommand();
              }
  			if (lastValue == null || lastValue.getExtraInfo().equals("") || lastValue.getExtraInfo().equals("up") || lastValue.getExtraInfo().equals("down")) {
  				return "unknown";
  			} else {
  				return lastValue.getExtraInfo();
  			}
        }
          
        public void listenMacro(String macro) {
                //do nothing
        }

        public void fireScriptOn(String controlled) {
                //do nothing
        }

        /**
         * @param String Run the macro.
         */
        public void runMacro(String macroName) {
                ClientCommand macroCommand;
                macroCommand = new ClientCommand();
                macroCommand.setCommand("run");
                macroCommand.setExtraInfo(macroName);
                macroCommand.setKey("MACRO");
                sendToFlash(macroCommand);
        }

        public void attatchComms(CommandQueue commandQueue) throws au.com.BI.Comms.
          ConnectionFail {};

        public void setScriptFiles(Map myScriptFiles) {
                this.scriptFiles = myScriptFiles;
        }

        public Map getScriptFiles() {
                return this.scriptFiles;
        }

        public boolean isScriptStillRunning(String scriptName) {
                return scriptHandler.isScriptRunning(scriptName);
        }

        /**
         * @return Returns the scriptHandler.
         */
        public ScriptHandler getScriptHandler() {
                return scriptHandler;
        }

        /**
         * @param scriptHandler The scriptHandler to set.
         */
        public void setScriptHandler(ScriptHandler scriptHandler) {
                this.scriptHandler = scriptHandler;
        }

        /**
         * @return Returns the number of scripts in the script directory.
         */
        public int getNumberOfScripts() {
                return this.numberOfScripts;
        }

        /**
         * @param int Sets the number of scripts in the script directory.
         */
        public void setNumberOfScripts(int numberOfScripts) {
                this.numberOfScripts = numberOfScripts;
        }

        /**
         * @return Returns the name.
         */
        public String getName() {
                return name;
        }

        /**
         * @param name The name to set.
         */
        public void setName(String name) {
                this.name = name;
        }

        private void jbInit() throws Exception {
        }

        public void log(boolean cont) {
                control = cont;
        }

        public void info(String message) {
            if (control == true) {
                     logger.log(Level.INFO, message);
            }
        }
        
        public void warn(String message) {
             logger.log(Level.WARNING, message);
        }
        
        public void severe(String message) {
            logger.log(Level.SEVERE, message);
       }
        
        public void log(String message) {
                if (control == true) {
                         logger.log(Level.FINE, message);
                }
        }

        public void log(String message, boolean use) {
                if (use==true) {
                        logger.log(Level.FINE, message);
                }
        }

        public boolean isConnected() {
                return true;
        }

		public GroovyScriptHandler getGroovyScriptHandler() {
			return groovyScriptHandler;
		}

		public void setGroovyScriptHandler(GroovyScriptHandler groovyScriptHandler) {
			this.groovyScriptHandler = groovyScriptHandler;
		}
        
}
