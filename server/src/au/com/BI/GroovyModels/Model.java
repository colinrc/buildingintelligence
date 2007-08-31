/*
 * Created on Oct 25, 2004
 *
 */
package au.com.BI.GroovyModels;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.Config.*;
import au.com.BI.Device.DeviceType;

import groovy.lang.GroovyClassLoader;
import java.util.concurrent.ConcurrentHashMap;
import java.util.jar.*;
import java.util.logging.*;
import au.com.BI.Flash.*;
import au.com.BI.Home.Controller;
import au.com.BI.User.User;
import java.util.*;

import org.codehaus.groovy.control.CompilationFailedException;
import java.io.*;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 * This module provides an interface to the system for Scripts.
 * @see DeviceModel for methods level documentation and methods availlable for hooking into functionality
 */
public class Model
  extends SimplifiedModel implements DeviceModel {

        public  int numberOfScripts = 0;


        protected boolean control = true;
        protected String parameter;
        protected GroovyModelFileHandler groovyModelFileHandler;
		protected ConcurrentHashMap<String,GroovyRunBlock> groovyModelFiles = null;
		protected ConcurrentHashMap<String,GroovyRunBlock> groovyModelClasses = null;
		protected GroovyClassLoader gcl;


        public Model() {
                super();
                this.setName("GROOVY_MODEL_HANDLER");
                groovyModelFileHandler = new GroovyModelFileHandler();
                groovyModelFiles = new ConcurrentHashMap <String,GroovyRunBlock>(30); 
                groovyModelClasses = new ConcurrentHashMap <String,GroovyRunBlock>(30); 
                this.setConnected(true);
                this.setAutoReconnect(false);
                gcl = new GroovyClassLoader();
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


        public void loadGroovyModels(Controller controller,List<DeviceModel>deviceModels) {
                int j = 0;
                logger.log(Level.INFO,"Loading Groovy Models");

                String lsLine, lsCheck;

				//get the script files and prepare for parsing
                try {
	                groovyModelFileHandler.loadGroovyModelList( "./models/",this.groovyModelFiles);
	            	
	                for (GroovyRunBlock runBlock: groovyModelFiles.values()) {
	                	try {
	                		registerGroovyModel ( controller,runBlock, deviceModels);
	                	} catch (ConfigError ex){
	                		logger.log(Level.WARNING, "There was an error loading configuration for " + runBlock.getFileName() + " " + ex.getMessage());
	                	} catch (GroovyModelError ex){
	                		logger.log(Level.WARNING, "There was an error setting up support for " + runBlock.getFileName() + " " + ex.getMessage());               		
	                	}
	                }
	                
	                groovyModelFiles.clear();
	                
	                groovyModelFileHandler.loadGroovyModelList( "./models/au/com/BI/models/",this.groovyModelFiles);
	
	                for (GroovyRunBlock runBlock: groovyModelFiles.values()) {
	                	try {
	                		registerGroovyModel ( controller,runBlock, deviceModels);
	                	} catch (ConfigError ex){
	                		logger.log(Level.WARNING, "There was an error loading configuration for " + runBlock.getFileName() + " " + ex.getMessage());
	                	} catch (GroovyModelError ex){
	                		logger.log(Level.WARNING, "There was an error setting up support for " + runBlock.getFileName() + " " + ex.getMessage());               		
	                	}
	                }

	                logger.log(Level.INFO,"Groovy models loaded");
	            } catch (ConfigError ex){
	                	logger.log (Level.WARNING, " There was an error loading the groovy model " + ex.getMessage());
	            }
        }

        public void registerGroovyModel (Controller controller, GroovyRunBlock groovyRunBlock, List <DeviceModel>deviceModels) throws ConfigError, GroovyModelError{
        String completeFile = "";
        String fileName = groovyRunBlock.getFileName();
        try {
            File theGroovyFile = new File(fileName);
            if (!theGroovyFile.canRead()) throw new GroovyModelError("Error reading the file " + fileName);
            
            Class groovyClass = null;;
            
            if (fileName.endsWith(".jar") || fileName.endsWith (".bi")){
            	JarFile jarFile = new JarFile (theGroovyFile);
            	Enumeration <JarEntry>eachFileList = jarFile.entries();
            	
            	while  (eachFileList.hasMoreElements()){
            		JarEntry jarEntry = eachFileList.nextElement();
            		String theName = jarEntry.getName();
            		if (theName.endsWith(".groovy")){
            		       InputStream input = jarFile.getInputStream(jarEntry);
            		       groovyClass = gcl.parseClass(input);
            		       input.close();
            		}
            	}   
            } else {
                	groovyClass = gcl.parseClass(theGroovyFile);            	
            }
            
            if (groovyClass == null) throw new GroovyModelError ("Error registering the groovy model " + fileName);
            groovyRunBlock.setTheClass(groovyClass);
            Object aModel = groovyClass.newInstance();

            GroovyModel myModel = (GroovyModel) aModel;
            String modelName = myModel.getName();
            if (groovyModelClasses.containsKey(modelName)){
            	logger.log (Level.INFO,"Not registering groovy model " + fileName + " as a model by that name already exists, check for a the same name from a jar file to Groovy source");
            } else {
	            controller.setupModel(myModel);
	            deviceModels.add(myModel);
	            versionManager.setVersion(modelName,  myModel.getVersion());
	            logger.log(Level.INFO, "Registering model " + modelName + " version " + myModel.getVersion() );
	            this.groovyModelClasses.put(modelName, groovyRunBlock);
            }


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
                        throw new GroovyModelError ("Unknown error in the groovy model  " + e.getMessage());
        }
    }
        
        public GroovyModel setupGroovyModel(GroovyRunBlock groovyRunBlock, String description)  throws IllegalAccessException,InstantiationException {
			Object model = groovyRunBlock.getTheClass().newInstance();
			GroovyModel myModel = (GroovyModel) model;
			//String loggerName = myModel.getClass().getPackage().getName();
			//Logger newLogger = Logger.getLogger(loggerName);
			myModel.setLogger (Logger.getLogger(myModel.getClass().getName()));
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


		public ConcurrentHashMap<String, GroovyRunBlock> getGroovyModelClasses() {
			return groovyModelClasses;
		}


		public void setGroovyModelClasses(
				ConcurrentHashMap<String, GroovyRunBlock> groovyModelClasses) {
			this.groovyModelClasses = groovyModelClasses;
		}
}
