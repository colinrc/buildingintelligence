package au.com.BI.Script;
import au.com.BI.User.*;
import java.util.*;

import au.com.BI.Flash.*;

import java.util.logging.*;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;

import org.python.util.PythonInterpreter;
import au.com.BI.Script.Model;

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

public class RunScript extends Thread {

  protected User user;
  protected CommandQueue commandList;
  protected Logger logger;
  protected String scriptName;
  protected boolean enable = true;
  protected boolean runningInTimer = false;
  protected ArrayList linesOfScript;
  protected Model scriptModel;
  protected Cache cache;

  public RunScript() {
    super();
    logger = Logger.getLogger(this.getClass().getPackage().getName());
  }

  public RunScript(String scriptName, User user, ArrayList linesOfScript,
                   Model scriptModel) {
    super();
    logger = Logger.getLogger(this.getClass().getPackage().getName());

    setScriptName(scriptName);
    setLinesOfScript(linesOfScript);
    setScriptModel(scriptModel);
	this.setName("Sript runner : " + scriptName);
    setUser(user);
  }

  public void setCommandList (CommandQueue commandList){
                this.commandList = commandList;
        }


  public void run()  {
    boolean repeating = false;
    boolean doOnce = true;
    boolean commandDone = false;

    while ( (doOnce || repeating) && enable) {
      doOnce = false; // just run it once

      ClientCommand started = new ClientCommand();
      started.setKey("SCRIPT");
      started.setExtraInfo(getScriptName());
      started.setCommand("started");
      cache.setCachedCommand("SCRIPT",started);
       commandList.add(started);



      String lsLine;
      lsLine = new String();

      try {

        PythonInterpreter interp = new PythonInterpreter();
        logger.log(Level.FINEST, "Running Jython Script: " + scriptName);

        interp.set("elife", scriptModel);
        CommandInterface client;
        client = new ClientCommand();
        interp.set("client", client);

        int i = 0;
        lsLine = "";

        //problem in getting :python lines to interp the next line properly
        //have entered lines in to one string and then processed, this allows for indentation in Python script to work.
        while (i < linesOfScript.size()) {
          lsLine = lsLine + (String) linesOfScript.get(i);
          i++;
        }
        ;

        logger.log(Level.FINEST,
                   "Script Lines: " + new Integer(i).toString() +
                   " Contains: " +
                   lsLine);

        interp.exec(lsLine);

        logger.log(Level.FINEST, "Completed Jython Script: " + scriptName);
      }
      catch (Exception e) { //(PyException e) {
        logger.log(Level.WARNING,
                   "Jython exception Handler: " + e.toString());

      }

      ClientCommand finished = new ClientCommand();
      finished.setKey("SCRIPT");
      finished.setExtraInfo(getScriptName());
      finished.setCommand("finished");
      cache.setCachedCommand ("SCRIPT",finished);
      commandList.add(finished);

    }
  }


  // catch (InterruptedException ex) {
  //    logger.log(Level.WARNING,
  //                "Exception while waiting: " + ex.toString());
  //   }
  //  }


  /**
   * @return Returns the name of the current script.
   */
  public String getScriptName() {
    return this.scriptName;
  }

  /**
   * @param scriptName Sets the name of the current script.
   */
  public void setScriptName(String scriptName) {
    this.scriptName = scriptName;
  }

  /**
   * @return Returns the contents of the current script.
   */
  public ArrayList getLinesOfScript() {
    return this.linesOfScript;
  }

  /**
   * @param linesOfScript Sets the contents of the script.
   */
  public void setLinesOfScript(ArrayList linesOfScript) {
    this.linesOfScript = linesOfScript;
  }

  /**
   * @return Returns the reference to the script Model.
   */
  public Model getScriptModel() {
    return this.scriptModel;
  }

  /**
   * @param scriptModel Sets the reference to the script Model.
   */
  public void setScriptModel(Model scriptModel) {
    this.scriptModel = scriptModel;
  }

  /**
   * @return Returns the current user.
   */
  public User getUser() {
    return this.user;
  }

  /**
   * @param scriptName Sets the current user.
   */
  public void setUser(User user) {
    this.user = user;
  }

   /**
   * @return Returns the script enable flag.
   */
  public boolean getEnable() {
    return enable;
  }

  /**
   * @param enable The script enable flag.
   */
  public void setEnable(boolean enable) {
    this.enable = enable;
  }

public Cache getCache() {
	return cache;
}

public void setCache(Cache cache) {
	this.cache = cache;
}

 }
