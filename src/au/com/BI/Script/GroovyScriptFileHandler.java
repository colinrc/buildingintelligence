/*
 * Created on Dec 15, 2004
 */
package au.com.BI.Script;

import groovy.lang.GroovyClassLoader;
import groovy.lang.GroovyObject;
import groovy.lang.GroovyRuntimeException;
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

import org.codehaus.groovy.control.CompilerConfiguration;
import org.codehaus.groovy.runtime.typehandling.GroovyCastException;

import au.com.BI.Config.ConfigError;
import au.com.BI.LabelMgr.LabelMgr;

/**
 * @author colinc
 *
 */
public class GroovyScriptFileHandler {
        Logger logger;
        protected GroovyScriptEngine gse;
        protected GroovyClassLoader groovyClassLoader;
        
        public GroovyScriptFileHandler() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
        }

        public void loadScripts(Model myScriptModel, String dir, ConcurrentHashMap <String,GroovyScriptRunBlock>scriptRunBlockList, 
        		au.com.BI.Patterns.Model patterns, LabelMgr labelMgr) throws ConfigError {

                Integer fileNum;

                
                try {
                	CompilerConfiguration cfg = new CompilerConfiguration();
                	cfg.setScriptBaseClass("au.com.BI.Script.BIScript");
                	groovyClassLoader =new GroovyClassLoader (this.getClass().getClassLoader(),cfg);
					gse = new GroovyScriptEngine (dir,groovyClassLoader);

	                fileNum = new Integer(0);
	                int i = 0;
	               loadScriptList(dir,scriptRunBlockList, patterns,labelMgr);
	
	                logger.log(Level.FINE, "Script files loaded ");
	
	                myScriptModel.setNumberOfScripts(scriptRunBlockList.size());
				} catch (IOException e) {
					logger.log (Level.WARNING,"Unable to load scripts");
					throw new ConfigError (e);

				}

        }


        public void loadScriptList(String directoryName, Map <String,GroovyScriptRunBlock>scriptRunBlockList, au.com.BI.Patterns.Model patterns,LabelMgr labelMgr)  throws ConfigError {
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
							String name = stFiles[i].substring(0, stFiles[i].length() - 7);

							
								try {
									Class  script = gse.loadScriptByName( name, groovyClassLoader);
									GroovyObject aScript = (GroovyObject)script.newInstance();

									/*
									java.lang.Class biScript = BIScript.class;
									String superName = aScript.getClass().getSuperclass().getName();
									*/
									BIScript ifc = (BIScript) aScript;
									
									GroovyScriptRunBlock scriptRunBlock;
									if (!scriptRunBlockList.containsKey(name)){
										 scriptRunBlock = new GroovyScriptRunBlock();
									} else {
										scriptRunBlock = scriptRunBlockList.get(name);
									}
									scriptRunBlock.setName(name);
									
									scriptRunBlock.setAbleToRunMultiple(ifc.isAbleToRunMultiple());
									scriptRunBlock.setHidden(ifc.isHidden());
									scriptRunBlock.setStoppable(ifc.isStoppable());
									scriptRunBlock.setFireOnChange(ifc.getFireOnChange());
									ifc.doRegisterScript(labelMgr, patterns);
									

									/*
									scriptRunBlock.setAbleToRunMultiple ((Boolean)aScript.invokeMethod( "isAbleToRunMultiple", null));
									scriptRunBlock.setStoppable ((Boolean)aScript.invokeMethod( "isStoppable",null) );
									scriptRunBlock.setFireOnChange ((String[])aScript.invokeMethod( "getFireOnChange",null) );
									*/
									scriptRunBlockList.put(name,scriptRunBlock);
									
								} catch (ResourceException e) {
									logger.log (Level.WARNING,"A problem occured reading the script " + name + " " + e.getMessage());
								} catch (ScriptException e) {
									logger.log (Level.WARNING,"A problem occured parsing the script " + name + " " + e.getCause().getMessage());
								} catch (InstantiationException e) {
									logger.log (Level.WARNING,"A problem occured instantiating the script " + name + " " + e.getMessage());
								} catch (IllegalAccessException e) {
									logger.log (Level.WARNING,"An illegal access occured from the script " + name + " " + e.getMessage());
								}catch (GroovyRuntimeException e) {
									logger.log (Level.WARNING,"A problem occured loading the script " + name + " " + e.getMessage());
								}catch (GroovyCastException e){
									logger.log (Level.WARNING,"A problem occured loading the script " + name + " " + e.getMessage());									
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
