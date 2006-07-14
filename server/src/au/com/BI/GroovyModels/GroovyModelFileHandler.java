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
 * @author colinc
 *
 */
public class GroovyModelFileHandler {
        Logger logger;

        public GroovyModelFileHandler() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
        }

        public void loadGroovyModelList(au.com.BI.Script.Model myScriptModel, String dir, Map <String,GroovyRunBlock>GroovyModelRunBlockList) throws ConfigError {

                Integer fileNum;
                fileNum = new Integer(0);
                int i = 0;
                Map <String,ArrayList>myFiles = Collections.synchronizedMap(new LinkedHashMap<String,ArrayList>(30));

                myFiles = loadGroovyModelList(dir,GroovyModelRunBlockList);

                logger.log(Level.FINE, "Groovy Models loaded ");

                myScriptModel.setScriptFiles(myFiles);
                myScriptModel.setNumberOfScripts(myFiles.size());

        }

  
        public Map <String,ArrayList> loadGroovyModelList(String directoryName, Map <String,GroovyRunBlock>GroovyModelRunBlockList) throws ConfigError {
                // try {

	                ArrayList linesOfFile;
	                HashMap <String,ArrayList> files;
	                files = new HashMap<String,ArrayList>();
	                
	                FilenameFilter filter = new FilenameFilter() {
	                        public boolean accept(File dir, String name) {
	                                return name.endsWith(".groovy");
	                        };
	                };
	
	                File dir = new File(directoryName);
	                String[] stFiles;
	                stFiles = new String[dir.list(filter).length];
	                stFiles = dir.list(filter);
	
	                for (int i = 0; i < stFiles.length; i += 1) {
						String name = stFiles[i].substring(0, stFiles[i].length() - 3);
						synchronized (GroovyModelRunBlockList) {
							GroovyRunBlock GroovyModelRunBlock = null;
							if (!GroovyModelRunBlockList.containsKey(name)){
								GroovyModelRunBlock = new GroovyRunBlock();
								GroovyModelRunBlock.setFileName(name);
								GroovyModelRunBlockList.put(name,GroovyModelRunBlock);
							}
						}
	                }
	                return files;
	
                }/*
                catch (IOException e){
                	throw new ConfigError(e);
                }*/
}
