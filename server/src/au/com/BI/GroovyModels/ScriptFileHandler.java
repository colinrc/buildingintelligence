/*
 * Created on Dec 15, 2004
 */
package au.com.BI.GroovyScripts;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author colinc
 *
 */
public class ScriptFileHandler {
        Logger logger;

        public ScriptFileHandler() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
        }

        public void loadScripts(Model myScriptModel, String dir, Map scriptRunBlockList) {

                Integer fileNum;
                fileNum = new Integer(0);
                int i = 0;
                Map myFiles = Collections.synchronizedMap(new LinkedHashMap(30));

                myFiles = loadScriptList(dir,scriptRunBlockList);

                logger.log(Level.FINE, "Script files loaded ");

                myScriptModel.setScriptFiles(myFiles);
                myScriptModel.setNumberOfScripts(myFiles.size());

        }

        public ArrayList fileRead(String myFile) { //throws ConfigError {
                ArrayList scriptList;
                String record = null;
                int recCount = 0;
                try {
                        FileReader fr = new FileReader(myFile);
                        BufferedReader br = new BufferedReader(fr);
                        scriptList = new ArrayList();
                        record = new String();

                        while ( (record = br.readLine()) != null) {
                                recCount++;
                                // remove lines we dont want
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

        public HashMap loadScriptList(String directoryName, Map scriptRunBlockList) { //throws ConfigError {
                //try {

                ArrayList linesOfFile;
                HashMap files;
                files = new HashMap();
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
                //catch (IOException e)
                return files;
                // throw new ConfigError(e);

        }
}
