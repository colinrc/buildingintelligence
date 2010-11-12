/*
 * Created on Dec 15, 2004
 */
package au.com.BI.Script;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Config.ConfigError;

/**
 * @author colinc
 *
 */
public class ScriptFileHandler {
        Logger logger;

        public ScriptFileHandler() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
        }

        public void loadScripts(au.com.BI.Script.Model myScriptModel, String dir, Map <String,ScriptRunBlock>scriptRunBlockList) throws ConfigError {

                Map <String,ArrayList<String>>myFiles = Collections.synchronizedMap(new LinkedHashMap<String,ArrayList<String>>(30));

                myFiles = loadScriptList(dir,scriptRunBlockList);

                logger.log(Level.FINE, "Script files loaded ");

                myScriptModel.setScriptFiles(myFiles);
                myScriptModel.setNumberOfScripts(myFiles.size());

        }

        public ArrayList <String>fileRead(String myFile) { //throws ConfigError {
                ArrayList <String>scriptList;
                String record = null;
                int recCount = 0;
                try {
                        FileReader fr = new FileReader(myFile);
                        BufferedReader br = new BufferedReader(fr);
                        scriptList = new ArrayList<String>();
                        record = new String();

                        while ( (record = br.readLine()) != null) {
                                recCount++;
                                // remove lines we don't want
                                if (removeBadLines(record) == false) {
                                        scriptList.add(record + "\n");
                                }
                        }
                        ;
                        logger.log(Level.FINE, new Integer(recCount) + " lines of code in script file " + myFile);
                        return scriptList;

                }
                catch (IOException e) {
                        logger.log(Level.SEVERE, "Error in reading script file " + myFile + ":"
                          + e.getMessage());
                        return null;
                }

        }

        public boolean removeBadLines(String line) {
                // Only allow safe IMPORT's

                if (line.startsWith("import")) {
                        if (line.indexOf(" sys", 6) > 0) {
                                return false;
                        }
                        else if (line.indexOf(" time", 6) > 0) {
                                return false;
                        }
                        else {
                                //change line to return true when we want to stop imports.
                                return true;
                        }
                }
                if (line.trim().startsWith("#")) {
                        return true;
                }
                return false;
        }

        public Map <String,ArrayList<String>> loadScriptList(String directoryName, Map <String,ScriptRunBlock>scriptRunBlockList)  throws ConfigError {
                try {

		                ArrayList <String>linesOfFile;
		                HashMap <String,ArrayList<String>> files = new HashMap<String,ArrayList<String>>();
		                FilenameFilter filter = new FilenameFilter() {
		                        public boolean accept(File dir, String name) {
		                                return name.endsWith(".py");
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
							synchronized (scriptRunBlockList) {
								ScriptRunBlock scriptRunBlock = null;
								if (!scriptRunBlockList.containsKey(name)){
									scriptRunBlock = new ScriptRunBlock();
									scriptRunBlock.setName(name);
									scriptRunBlockList.put(name,scriptRunBlock);
								}
							}
		                     linesOfFile = fileRead(directoryName + stFiles[i].toString());
		                     files.put(name, linesOfFile);
		
		                }
		                return files;
		        } catch (SecurityException e){

		        	throw new ConfigError(e);
		        }

        }
}
