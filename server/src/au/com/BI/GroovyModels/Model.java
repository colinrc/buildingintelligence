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

import org.codehaus.groovy.control.CompilationFailedException;
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
		protected ConcurrentHashMap<String,GroovyRunBlock> groovyModelFiles = null;
		protected ConcurrentHashMap<String,GroovyRunBlock> groovyModelClasses = null;
		protected GroovyClassLoader gcl;

        protected Map scriptFiles = null;

        public Model() {
                super();
                this.setName("GROOVY_MODEL_HANDLER");
                groovyModelFileHandler = new GroovyModelFileHandler();
                groovyModelFiles = new ConcurrentHashMap <String,GroovyRunBlock>(30); 
                groovyModelClasses = new ConcurrentHashMap <String,GroovyRunBlock>(30); 
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
                ArrayList  scripts;

                scripts = new ArrayList();

				//get the script files and prepare for parsing
                try {
	                groovyModelFileHandler.loadGroovyModelList( "./models/",this.groovyModelFiles);
	
	                for (GroovyRunBlock runBlock: groovyModelFiles.values()) {
	                	try {
	                		registerGroovyModel (runBlock);
	                	} catch (ConfigError ex){
	                		logger.log(Level.WARNING, "There was an error loading configuration for " + runBlock.getFileName() + " " + ex.getMessage());
	                	} catch (GroovyModelError ex){
	                		logger.log(Level.WARNING, "There was an error setting up support for " + runBlock.getFileName() + " " + ex.getMessage());               		
	                	}
	                }
	                	logger.log(Level.INFO,"Groovy models loaded");
	                } catch (ConfigError ex){
                	
                }
        }

        public void registerGroovyModel (GroovyRunBlock groovyRunBlock) throws ConfigError, GroovyModelError{
        		String completeFile = "";
        		String fileName = groovyRunBlock.getFileName();
        		try {
						Class groovyClass = gcl.parseClass(new File(fileName));
						groovyRunBlock.setTheClass(groovyClass);
						Object aScript = groovyClass.newInstance();
						GroovyModel myModel = (GroovyModel) aScript;
						String modelName = myModel.getName();
						logger.log(Level.INFO, "Registering model " + modelName);
						this.groovyModelClasses.put(modelName, groovyRunBlock);
						

				} catch (CompilationFailedException e) {
						throw new GroovyModelError ("Compilation error in the model " + fileName + " " + e.getMessage());
				} catch (IOException e) {
						throw new GroovyModelError ("File error in the model " + fileName + " " + e.getMessage());
				} catch (InstantiationException e) {
						throw new GroovyModelError ("Instantiation error in the model " + fileName + " " + e.getMessage());
				} catch (IllegalAccessException e) {
						throw new GroovyModelError ("Instantiation error in the model " + fileName + " " + e.getMessage());
				} catch (ClassCastException e) {
						throw new GroovyModelError ("Instantiation error in the model " + fileName + " " + e.getMessage());
				} catch (Exception e){
						throw new GroovyModelError ("Weird stuff happened " + e.getMessage());
				}
        }
        
        public GroovyModel setupGroovyModel(GroovyRunBlock groovyRunBlock, String description)  throws IllegalAccessException,InstantiationException {
			Object model = groovyRunBlock.getClass().newInstance();
			GroovyModel myModel = (GroovyModel) model;
			// myModel.setLogger (Logger.getLogger(myModel.getName()));
			return myModel;
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


		public ConcurrentHashMap<String, GroovyRunBlock> getGroovyModelFiles() {
			return groovyModelFiles;
		}


		public void setGroovyModelFiles(
				ConcurrentHashMap<String, GroovyRunBlock> groovyModels) {
			this.groovyModelFiles = groovyModels;
		}


		public ConcurrentHashMap<String, GroovyRunBlock> getGroovyModelClasses() {
			return groovyModelClasses;
		}


		public void setGroovyModelClasses(
				ConcurrentHashMap<String, GroovyRunBlock> groovyModelClasses) {
			this.groovyModelClasses = groovyModelClasses;
		}
}
