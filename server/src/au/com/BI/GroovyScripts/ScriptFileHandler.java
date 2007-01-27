/*
 * Created on Dec 15, 2004
 */
package au.com.BI.GroovyScripts;

import groovy.util.GroovyScriptEngine;
import groovy.util.ResourceException;
import groovy.util.ScriptException;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Config.ConfigError;

/**
 * @author colinc
 *
 */
public class ScriptFileHandler {
        Logger logger;
        protected GroovyScriptEngine gse;

        public ScriptFileHandler() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
        }

        public void loadScripts(Model myScriptModel, String dir, ConcurrentHashMap <String,ScriptRunBlock>scriptRunBlockList) throws ConfigError {

                Integer fileNum;
                try {
					gse = new GroovyScriptEngine (dir);

	                fileNum = new Integer(0);
	                int i = 0;
	               loadScriptList(dir,scriptRunBlockList);
	
	                logger.log(Level.FINE, "Script files loaded ");
	
	                myScriptModel.setNumberOfScripts(scriptRunBlockList.size());
				} catch (IOException e) {
					logger.log (Level.WARNING,"Unable to load scripts");
					throw new ConfigError (e);

				}

        }


        public void loadScriptList(String directoryName, Map <String,ScriptRunBlock>scriptRunBlockList)  throws ConfigError {
                try {

		                FilenameFilter filter = new FilenameFilter() {
		                        public boolean accept(File dir, String name) {
		                                return name.endsWith(".groovy");
		                        };
		                };
		
		                File dir = new File(directoryName);
		                /*
		                String[] stFiles;
		                stFiles = new String[dir.list(filter).length];
		                stFiles = dir.list(filter);
					*/
		                 String[] stFiles = dir.list(filter);
		                
		                if (stFiles == null) throw new ConfigError("Could not read the script directory " + directoryName);
		
		                for (int i = 0; i < stFiles.length; i += 1) {
							String name = stFiles[i].substring(0, stFiles[i].length() - 3);

							
								try {
									Class  script = gse.loadScriptByName(stFiles[i]);
									Object aScript = script.newInstance();

									BIScript ifc = (BIScript) aScript;
									ScriptRunBlock scriptRunBlock;
									if (!scriptRunBlockList.containsKey(name)){
										 scriptRunBlock = new ScriptRunBlock();
									} else {
										scriptRunBlock = scriptRunBlockList.get(name);
									}
									scriptRunBlock.setName(name);
									scriptRunBlock.setAbleToRunMultiple(ifc.isAbleToRunMultiple());
									scriptRunBlock.setStoppable(ifc.isStoppable());
									scriptRunBlock.setFireOnChange(ifc.getFireOnChange());
									
									scriptRunBlockList.put(name,scriptRunBlock);
									
								} catch (ResourceException e) {
									logger.log (Level.WARNING,"A problem occured reading the script " + stFiles[i] + " " + e.getMessage());
								} catch (ScriptException e) {
									logger.log (Level.WARNING,"A problem occured reading the script " + stFiles[i] + " " + e.getMessage());
								} catch (InstantiationException e) {
									logger.log (Level.WARNING,"A problem occured instantiating the script " + stFiles[i] + " " + e.getMessage());
								} catch (IllegalAccessException e) {
									logger.log (Level.WARNING,"An illegal access occured from the script " + stFiles[i] + " " + e.getMessage());
								}
			                }
							
		                   //   Class newGroovyScript = gcl.parseClass(new File(directoryName + stFiles[i].toString()));
		
		        } catch (SecurityException e){

		        	throw new ConfigError(e);
		        }

        }

		public GroovyScriptEngine getGse() {
			return gse;
		}
}
