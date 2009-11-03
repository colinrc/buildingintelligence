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
 * This module provides an interface to the system for Scripts.
 * @see DeviceModel for methods level documentation and methods availlable for hooking into functionality
 */
public class Model
  extends SimplifiedModel implements DeviceModel {

        public int numberOfScripts = 0;
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
        
        protected Map <String, ArrayList<String>>scriptFiles;

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


 		public void doClientStartup(long targetFlashDeviceID, long serverID){
 			this.sendListToClient(targetFlashDeviceID);
 		};


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
                        doScriptItem(command.getExtraInfo(), command.getCommandCode(),command.getExtra2Info(),null,command.getTargetDeviceID()); // script called via an explicit run command
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
                                                if (((Script)device).getScriptType() == ScriptType.Jython) {
                                                	// String scriptName = ((Script) device).getNameOfScript();
                                                	
                                                	for (String scriptName:(((Script)device).getScriptListForCommand(""))){
                                                		doScriptItem(scriptName,  "run", "", command,0L); 
                                                	}

                                                } else {
                                                	// Groovy script (s)
                                                	for (String scriptName:(((Script)device).getScriptListForCommand(""))){
                                                		doScriptItem(scriptName,  "run", "", command,0L); 
                                                	}
                                                	String launchingCommand = command.getCommandCode();
                                                	if (!launchingCommand.equals("")){
	                                                	for (String scriptName:(((Script)device).getScriptListForCommand(launchingCommand))){
	                                                		doScriptItem(scriptName,  "run", "", command,0L); 
	                                                	}
                                                	}
                                                }
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

    	
        public void doScriptItem(String scriptName, String commandStr, String scriptExtra, CommandInterface triggeringCommand, Long targetDeviceModel) throws CommsFail {
            	logger.log(Level.FINE,"Running script " + scriptName);
            
                Command clientCommand = null;

                logger.log(Level.FINER, "Received script command");


                if (commandStr.equals("run")) {
	                   if (groovyScriptHandler.ownsScript (scriptName)){
	                        groovyScriptHandler.run(scriptName,scriptExtra, currentUser,triggeringCommand);
	                        logger.log(Level.FINER, "Run Groovy script request received " + scriptName);
	                   } else {
	                        scriptHandler.run( scriptName,scriptExtra, currentUser,triggeringCommand);
	                        logger.log(Level.FINER, "Run Jython script request received " + scriptName);	                	   
	                   }
                }

	            if (commandStr.equals("finished")) {
	                    logger.log(Level.FINER, "Finished script " + scriptName );
	                       
	                    if (!groovyScriptHandler.ownsScript (scriptName)){
	                    	// Old jython stuff
	                    	
	                       if (scriptHandler.finishedRunning(scriptName)) {
	                    	   	clientCommand = doGetList ("");  // no more to run, so update the client
	                       }
	                       else
	                       {
	                           scriptHandler.run(scriptName, triggeringCommand);
	                           logger.log(Level.FINER, "Running queued script " + scriptName);
	                       }
	                   }
	                    	   
               }
				if (commandStr.equals("save")) {
	                if (scriptExtra.equals("enabled")) {
	                	if (!groovyScriptHandler.enableScript( scriptName, currentUser) && 
	                			!scriptHandler.enableScript( scriptName, currentUser)  ){
	                		logger.log (Level.WARNING,"Enable was called for a script that does not exist");
	                }
	                else {
							clientCommand = doGetList ("");
	                        logger.log(Level.FINER, "Enable script " + scriptName);
	                }
	                }
	                if (scriptExtra.equals("disabled")) {
	                	if (!scriptHandler.disableScript( scriptName, currentUser) &&
	                        !groovyScriptHandler.disableScript(scriptName, currentUser) ) {
	                			logger.log (Level.WARNING,"Disable was called for a script that does not exist");
	                        } else {
								clientCommand = doGetList ("");
		                        logger.log(Level.FINER, "Disable script " + scriptName);
		                    }
	                }
	                if (scriptExtra.equals("enableAll")) {
	                        scriptHandler.enableAll();
	                        groovyScriptHandler.enableAll();
	                        
							clientCommand = doGetList ("");
	                        logger.log(Level.FINER, "Enable All scripts " + scriptName);
	                }
	                if (scriptExtra.equals("disableAll")) {
	                        scriptHandler.disableAll();
	                        groovyScriptHandler.disableAll();
							clientCommand = doGetList ("");
	                        logger.log(Level.FINER, "Disable All scripts " + scriptName);
	                }
				}

                if (commandStr.equals("getList")) {
					clientCommand = doGetList (scriptName);
                }

                if (commandStr.equals("setStatus")) {
					if (!groovyScriptHandler.setStatus(scriptName,scriptExtra) && 
							!scriptHandler.setStatus(scriptName, scriptExtra)) {
			
						logger.log(Level.WARNING,
							"A script status update was received for a script that does not exist "
									+ name);
                	} else {
                		clientCommand = doGetList ("");
                		logger.log(Level.FINER, "Setting status for " + scriptName+ "=" + scriptExtra);
                	}
                }

                if (commandStr.equals("abort")) {
                	groovyScriptHandler.abort(scriptName);
					scriptHandler.abort(scriptName);
					clientCommand = doGetList ("");
                    logger.log(Level.FINER, "Aborting script " + scriptName);
                }

                if (clientCommand != null) {
                        clientCommand.setTargetDeviceID(targetDeviceModel);
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
                   
		public void sendListToClient(long targetFlashClient) {
			ClientCommand clientCommand = (ClientCommand)doGetList("");
			clientCommand.setTargetDeviceID(targetFlashClient);
			cache.setCachedCommand("SCRIPT", clientCommand,false);
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
        
	    	
	    	public void loadScripts (){
	    		loadGroovyScripts();
	    		loadJythonScripts();
	    	}
	    	
	    	public void loadGroovyScripts () {
	        	try {
	        		groovyScriptFileHandler.loadScripts(this, "./script", groovyScriptRunBlockList, patterns,labelMgr);
	                groovyScriptHandler = new GroovyScriptHandler(this, groovyScriptRunBlockList, groovyStatusFileName,groovyScriptFileHandler.getGse());
	        		for (String scriptName :groovyScriptRunBlockList.keySet()){

	        			GroovyScriptRunBlock scriptRunBlock = groovyScriptRunBlockList.get (scriptName);
	        			registerGroovyScript (scriptName, scriptRunBlock);
	        		}
	        		logger.log(Level.FINE,"Loaded Groovy scripts");
	        		groovyScriptHandler.loadScriptFile();
	        	} catch (ConfigError ex){
	        		logger.log (Level.WARNING,"Problem reading the script files " + ex.getMessage());
	        	}
	    	}

	    	public void registerGroovyScript (String myScript, GroovyScriptRunBlock scriptRunBlock){
	    		for (String triggerTag :scriptRunBlock.getFireOnChange()){
	    			String tagParts[] = triggerTag.split(":");
	    			String triggerDisplayName = tagParts [0];
	    			try {
	        			Script newScript = null;
	        			if (configHelper.checkForOutputItem(triggerDisplayName)) {
	        				newScript = (Script)configHelper.getOutputItem(triggerDisplayName);
	        				// Already have a script responding to this display name
	        			} else {
	        				newScript = new Script();
		        			newScript.setScriptType (ScriptType.Groovy);
		        			newScript.setKey(myScript);
	        				// No scripts yet listening for this display name
	        			}
	        			
		    			if (tagParts.length == 1){
		    				newScript.addScriptForCommand ("*", myScript) ;
		    			} 
		    			if (tagParts.length == 2){
		    				newScript.addScriptForCommand (tagParts[1], myScript) ;
		    			}
		    			configHelper.addControlledItem(triggerDisplayName, newScript, MessageDirection.FROM_FLASH);
	    			} catch (ClassCastException ex){
	    				logger.log (Level.WARNING,"A non-script has been added to the script handler");
	    			}
	    		}
	    	}
	    	
	    	
        public void loadJythonScripts() {
                int j = 0;
                logger.log(Level.FINE,"Loading scripts");

                String lsLine, lsCheck;
                ArrayList <String>linesOfFile;
                ArrayList <Script> scripts;
                Object hashKey;
                Map <String, ArrayList<String>>files;

                lsLine = new String();
                lsCheck = new String();
                scripts = new ArrayList <Script>();
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
	                
	
	                setNumberOfScripts(files.size());
	                scriptHandler = new ScriptHandler(getNumberOfScripts(), this, scriptRunBlockList,statusFileName); //,this.commandQueue);
	                scriptHandler.setCache (cache);
	
					scriptHandler.loadScriptFile();
	
	                scriptHandler.initTimerLists();
	                for (String scriptName:files.keySet()){
	                        linesOfFile =  files.get(scriptName);
	                        
	                        int i = 0;
	                        lsLine = "";
	
	                        // Now collect the lines looking for items to remove.
	                        while (i < linesOfFile.size()) {
	                                lsLine = lsLine + linesOfFile.get(i);
	                                i++;
	                        }
	                        parseScript(lsLine,scriptName);
	                }
	                scriptHandler.addTimerControls();
	                logger.log(Level.FINE,"Scripts loaded");
                } catch (ConfigError ex){
                	logger.log(Level.WARNING,"Scripts system could not be set up " + ex.getMessage());
                }
        }

        public void parseScript(String myScript, String scriptName) {
                int begin = 0;
                int end = 0;
                int deviceType = 0;
                String controlled, duration;
                Script newScript = null;
    			

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
            			
	        			if (configHelper.checkForOutputItem(controlled)) {
	        				newScript = (Script)configHelper.getOutputItem(controlled);
	        				// Already have a script responding to this display name
	        			} else {
	        				newScript = new Script();
		        			newScript.setScriptType (ScriptType.Jython);
		        			newScript.setKey(controlled);
	        				// No scripts yet listening for this display name
	        			}
	        			newScript.addScriptForCommand("", scriptName);
                        addControlledItem(controlled, newScript, MessageDirection.FROM_FLASH);

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
                       
	        			if (configHelper.checkForOutputItem(controlled)) {
	        				newScript = (Script)configHelper.getOutputItem(controlled);
	        				// Already have a script responding to this display name
	        			} else {
	        				newScript = new Script();
		        			newScript.setScriptType (ScriptType.Jython);
		        			newScript.setKey(controlled);
	        				// No scripts yet listening for this display name
	        			}
	        			newScript.addScriptForCommand("", scriptName);
                        addControlledItem(controlled, newScript, MessageDirection.FROM_FLASH);

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
	        			if (configHelper.checkForOutputItem(controlled)) {
	        				newScript = (Script)configHelper.getOutputItem(controlled);
	        				// Already have a script responding to this display name
	        			} else {
	        				newScript = new Script();
		        			newScript.setScriptType (ScriptType.Jython);
		        			newScript.setKey(controlled);
	        				// No scripts yet listening for this display name
	        			}
	        			newScript.addScriptForCommand("", scriptName);
                        addControlledItem(controlled, newScript, MessageDirection.FROM_FLASH);

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
	        			if (configHelper.checkForOutputItem(controlled)) {
	        				newScript = (Script)configHelper.getOutputItem(controlled);
	        				// Already have a script responding to this display name
	        			} else {
	        				newScript = new Script();
		        			newScript.setScriptType (ScriptType.Jython);
		        			newScript.setKey(controlled);
	        				// No scripts yet listening for this display name
	        			}
	        			newScript.addScriptForCommand("", scriptName);
                        addControlledItem(controlled, newScript, MessageDirection.FROM_FLASH);
                        //}
                        begin = myScript.indexOf("elife.getCommand", end);
                        if (begin > 0) {
                                begin = myScript.indexOf("(\"", begin);
                        }
                        ;
                }

                // Step 5. Look for any getLastAccessTimeDuration commands, these will be timed and cause the script to fire at each timed interval

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
                                scriptHandler.addTimerListMinute(scriptName);
                        }
                        else if (duration.equals("hour")) {
                                scriptHandler.addTimerListHour(scriptName);
                        }
                        else if (duration.equals("day")) {
                                scriptHandler.addTimerListDay(scriptName);
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
					ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get(scriptName);
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

                ConfigHelper currentConfigHelper;
                String showModel;

    
                for (DeviceModel currentModel:getModelList()){

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

        public void setScriptFiles(Map <String, ArrayList<String>>myScriptFiles) {
                this.scriptFiles = myScriptFiles;
        }

        public Map <String, ArrayList<String>>getScriptFiles() {
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
