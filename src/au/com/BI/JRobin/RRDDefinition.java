package au.com.BI.JRobin;

/**
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2004</p>
 *
 * <p>Company: Building Intelligence</p>
 *
 * @author Jeff Kitchener
 * @version 1.0
 */

import java.util.*;

import java.util.logging.*;
import java.io.File;
import java.io.IOException;

import org.jrobin.core.*;
import java.io.FilenameFilter;
import java.io.BufferedReader;
import java.io.FileReader;

public class RRDDefinition {
    protected Logger logger;
    protected String fileName;

    public RRDDefinition() {
      logger = Logger.getLogger(this.getClass().getPackage().getName());
    }

    public void startUp(String RRDDirectory, String RRDDefDirectory) {
      HashMap xmlFiles;
      HashMap rrdFiles;
      Object hashKey;
      String key;

      xmlFiles = loadRRDList(".xml", RRDDefDirectory);
      rrdFiles = loadRRDList(".rrd", RRDDirectory);

      //check if RRD exists, if not then create

      Set sFiles = xmlFiles.keySet();
      Iterator iteratorHash = sFiles.iterator();
      logger.log(Level.INFO,"..........IN RRDDefinition.startUp");
      while (iteratorHash.hasNext()) {
        hashKey = iteratorHash.next();
        key = (String)hashKey;
        if (rrdFiles.containsKey(key) == false) {
          createRRD(key, RRDDirectory, RRDDefDirectory + xmlFiles.get(hashKey).toString());
        };

      }

    }

    public void createRRD(String key, String rrdPath, String RRDTemplateName)  {
      try {
        logger.log(Level.INFO, "In createRRD");
        String rrdTemplate;
        rrdTemplate = fileRead(RRDTemplateName);
        RrdDb.setLockMode(RrdDb.NO_LOCKS);

        // creation from the template
        logger.log(Level.INFO, "==> Creating RRD file from " + RRDTemplateName + " rrdTemplate => " + rrdTemplate);
        RrdDefTemplate defTemplate = new RrdDefTemplate(rrdTemplate);
        logger.log(Level.INFO, "==> path variable =>" + rrdPath + key + ".rrd");
        //make sure file name is known
        defTemplate.setVariable("path", rrdPath + key + ".rrd");
        //defTemplate.setVariable("start", start - 1);     Dont use at this stage
        logger.log(Level.INFO,"==>  ..Initializing rrdDef..");
        RrdDef rrdDef = defTemplate.getRrdDef();

        logger.log(Level.INFO, rrdDef.dump());

        RrdDb rrdDb = new RrdDb(rrdDef);
        rrdDb.close();
        logger.log(Level.INFO, "==> RRD file created and closed.");
      }
      catch (RrdException e) {
        logger.log(Level.SEVERE, "RRDException in createRRD" + e.getMessage());
                }
                catch (IOException eio) {
                  logger.log(Level.SEVERE, "IOException in createRRD " + eio.getMessage());
                }


    }

    public String fileRead(String myFile) {
      logger.log(Level.FINE, "In fileRead");
      String record = null;
      int recCount = 0;
      try {
        FileReader fr = new FileReader(myFile);
        BufferedReader br = new BufferedReader(fr);
        StringBuffer rrdTemplate = new StringBuffer();
        record = "";

        while (( record = br.readLine()) != null) {
               recCount++;
               rrdTemplate.append(rrdTemplate + record + "\n");
        };
        logger.log(Level.INFO, recCount + " lines in xml file " + myFile);
        return rrdTemplate.toString();

      } catch (IOException e) {
        logger.log(Level.SEVERE, "Error in reading xml file " + myFile + ":"
                                  + e.getMessage());
        return null;
      }
    }


    public HashMap loadRRDList(final String extFilter, String directoryName ) {
      logger.log(Level.FINE, "In loadRRDList");
      HashMap files;
      files = new HashMap();

      FilenameFilter filter = new FilenameFilter() {
        public boolean accept(File dir, String name) {
          return name.endsWith( extFilter);
        };
      };

      File dir = new File(directoryName);
      try {
		  if (!dir.canRead()) {
			  logger.log (Level.WARNING,"Cannot read RRD directory " + directoryName);
		  }
        String [] stFiles = dir.list(filter);

        for (int i = 0; i < stFiles.length; i += 1) {
          files.put(stFiles[i].substring(0, stFiles[i].length() - 4),
                    stFiles[i].toString());
        }
      }
      catch (NullPointerException e) {
		  logger.log (Level.WARNING,"Listing of RRD definition files failed");
        // continue with no entries in files
      }
      return files;
    }

  }
