/*
 * Created on Oct 25, 2004
 *
 */
package au.com.BI.GroovyModels;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.Config.*;

import groovy.lang.GroovyClassLoader;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.*;

import au.com.BI.ToggleSwitch.*;
import au.com.BI.Flash.*;

import au.com.BI.Script.ScriptHandler;
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
  extends BaseModel implements DeviceModel {

        public  int numberOfScripts = 0;


        protected boolean control = true;
        protected String parameter;
        protected GroovyModelFileHandler groovyModelFileHandler;
		protected ConcurrentHashMap<String,GroovyRunBlock> groovyRunBlockList = null;
		protected GroovyClassLoader gcl;

        protected Map scriptFiles = null;

        public Model() {
                super();
                this.setName("GROOVY_MODEL_HANDLER");
                groovyModelFileHandler = new GroovyModelFileHandler();
                groovyRunBlockList = new ConcurrentHashMap <String,GroovyRunBlock>(30); 
                this.setConnected(true);
                this.setAutoReconnect(false);
                gcl = new GroovyClassLoader();
    			loadGroovyModels();
          }


        public boolean removeModelOnConfigReload() {
                return false;
        }

 
        public boolean doIControl(String keyName, boolean isCommand) {
                configHelper.wholeKeyChecked(keyName);

                if (keyName.equals("GROOVY_MODEL"))return true;

                return false;
        }

        public void doOuptutCommand (CommandInterface command) throws CommsFail {
                String theWholeKey = command.getKey();
                DeviceType device = configHelper.getOutputItem(theWholeKey);

                Command clientCommand = null;

                logger.log(Level.FINER, "Received script command");

                String commandStr = command.getCommandCode();
                String extra2 = command.getExtra2Info();
                User currentUser = command.getUser();
                if (commandStr.equals("getList")) {
					clientCommand = doGetList ();
                }


                if (clientCommand != null) {
                        clientCommand.setTargetDeviceID(command.getTargetDeviceID());
                         commandQueue.add(clientCommand);
                }
        }

		public void sendListToClient() {
			ClientCommand clientCommand = (ClientCommand)doGetList();
			clientCommand.setTargetDeviceID(-1);
            commandQueue.add(clientCommand);
		}

		public Command doGetList () {
            logger.log(Level.FINER, "Fetching script list");

                ClientCommand clientCommand = new ClientCommand();
                //clientCommand.setFromElement(list);
                clientCommand.setKey("CLIENT_SEND");
				return clientCommand; 
		} 

		public void finishedReadingConfig() throws SetupException {
        	super.finishedReadingConfig();
        }

        public void loadGroovyModels() {
                int j = 0;
                logger.log(Level.INFO,"Loading scripts");

                String lsLine, lsCheck;
                ArrayList linesOfFile, scripts;
                Object hashKey;

                scripts = new ArrayList();

				//get the script files and prepare for parsing
                try {
	                groovyModelFileHandler.loadGroovyModelList( "./models/",this.groovyRunBlockList);
	
	                for (String fileName: groovyRunBlockList.keySet()) {
	                	try {
	                		launchGroovyModel (fileName);
	                	} catch (ConfigError ex){
	                		logger.log(Level.WARNING, "There was an error loading configuration for " + fileName + " " + ex.getMessage());
	                	} catch (GroovyModelError ex){
	                		logger.log(Level.WARNING, "There was an error setting up support for " + fileName + " " + ex.getMessage());               		
	                	}
	                }
	                	logger.log(Level.INFO,"Groovy models loaded");
	                } catch (ConfigError ex){
                	
                }
        }

        public void launchGroovyModel (String fileName) throws ConfigError, GroovyModelError{
        	
        }
        
         public void attatchComms(CommandQueue commandQueue) throws au.com.BI.Comms.
          ConnectionFail {};


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
}
