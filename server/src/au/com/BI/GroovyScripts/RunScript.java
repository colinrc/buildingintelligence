package au.com.BI.GroovyScripts;
import au.com.BI.User.*;
import groovy.lang.Binding;
import groovy.util.GroovyScriptEngine;


import au.com.BI.Flash.*;

import java.util.logging.*;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;



public class RunScript extends Thread {

  protected User user;
  protected CommandQueue commandList;
  protected Logger logger;
  protected String scriptName;
  protected boolean enable = true;
  protected boolean runningInTimer = false;
  protected Model scriptModel;
  protected Cache cache;
  protected CommandInterface triggeringEvent;
  protected GroovyScriptEngine gse;

  public RunScript() {
    super();
    logger = Logger.getLogger(this.getClass().getPackage().getName());
  }

  public RunScript(String scriptName, User user, Model scriptModel, CommandInterface triggeringEvent, GroovyScriptEngine gse) {
    super();
    logger = Logger.getLogger(this.getClass().getPackage().getName());
    this.gse = gse;

    setScriptName(scriptName);
    setScriptModel(scriptModel);
    setCache(scriptModel.getCache());
    setCommandList (scriptModel.getCommandQueue());
    this.triggeringEvent = triggeringEvent;
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
      started.setDisplayName("SCRIPT");
      cache.setCachedCommand("SCRIPT",started);
       commandList.add(started);



      String lsLine;
      lsLine = new String();

      try {
        logger.log(Level.FINEST, "Running Groovy Script: " + scriptName);

        CommandInterface client;
        client = new ClientCommand();

        Binding binding = new Binding();
        binding.setVariable("elife", scriptModel);
        binding.setVariable("cache", scriptModel.getCache());
        binding.setVariable("triggeringEvent", triggeringEvent);
        binding.setVariable("client", client);
       
        gse.run(scriptName, binding);



        logger.log(Level.FINEST, "Completed Groovy Script: " + scriptName);
      }
      catch (Exception e) { //(PyException e) {
        logger.log(Level.WARNING,
                   "Groovy exception Handler: " + e.toString());

      }

      ClientCommand finished = new ClientCommand();
      finished.setKey("SCRIPT");
      finished.setExtraInfo(getScriptName());
      finished.setDisplayName("SCRIPT");
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
