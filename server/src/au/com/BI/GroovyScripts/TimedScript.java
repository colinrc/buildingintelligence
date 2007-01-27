package au.com.BI.GroovyScripts;



import java.util.*;

import java.util.logging.*;


public class TimedScript extends TimerTask {



  protected List script;

  protected Logger logger;

  protected ScriptHandler scriptHandler;





  public TimedScript() {

    super();

    logger = Logger.getLogger(this.getClass().getPackage().getName());

  }



  public TimedScript(List script) {

    super();

    this.script = Collections.synchronizedList(script);

    logger = Logger.getLogger(this.getClass().getPackage().getName());

  }



  public void run() {

    String lsScript;

    synchronized (script) {

      Iterator eachScript = script.iterator();

      while (eachScript.hasNext()) {

        lsScript = (String)eachScript.next();

        logger.log(Level.FINE, "Running timed event " + lsScript);

        scriptHandler.run(lsScript,"", null, null);

        }

      }

    }



  /**

   * @return Returns the scriptHandler.

   */

  public ScriptHandler getScriptHandler() {

    return scriptHandler;

  }



  /**

   * @param scriptHandler The scriptHandler to set.

   */

  public void setScriptHandler(ScriptHandler scriptHandler) {

    this.scriptHandler = scriptHandler;

  }

}

