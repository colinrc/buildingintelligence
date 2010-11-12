/*
 * Created on Dec 15, 2004
 */
package au.com.BI.GroovyModels;

import java.io.File;
import java.io.FilenameFilter;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Config.ConfigError;

/**
 * @author colin
 *
 */
public class GroovyModelFileHandler {
        Logger logger;

        public GroovyModelFileHandler() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
        }


  
        public void loadGroovyModelList(String directoryName, Map <String,GroovyRunBlock>groovyModelRunBlockMap) throws ConfigError {
                // try {
    		logger.log(Level.INFO, "loading groovy models");

	                
	                FilenameFilter filter = new FilenameFilter() {
	                        public boolean accept(File dir, String name) {
	                        	if (name.endsWith(".groovy")) return true;	                        	
	                        	if (name.endsWith(".jar")) return true;
	                        	if (name.endsWith(".bi")) return true;
	                            return false;
	                        };
	                };
	
	                File dir = new File(directoryName);
	                String[] stFiles;
	                if (!dir.isDirectory()) return;
	                //stFiles = new String[dir.list(filter).length];
	                stFiles = dir.list(filter);
	
	                for (int i = 0; i < stFiles.length; i += 1) {
	                	String name = directoryName + stFiles[i];
						// String name = stFiles[i].substring(0, stFiles[i].length() - 3);
						synchronized (groovyModelRunBlockMap) {
							GroovyRunBlock GroovyModelRunBlock = null;
							if (!groovyModelRunBlockMap.containsKey(name)){
								GroovyModelRunBlock = new GroovyRunBlock();
								GroovyModelRunBlock.setFileName(name);
								groovyModelRunBlockMap.put(name,GroovyModelRunBlock);
							}
						}
	                }
	
                }/*
                catch (IOException e){
                	throw new ConfigError(e);
                }*/
}
