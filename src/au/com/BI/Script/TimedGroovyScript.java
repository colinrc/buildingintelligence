package au.com.BI.Script;



import java.util.*;

import java.util.logging.*;


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

public class TimedGroovyScript extends TimerTask {



  protected List script;

  protected Logger logger;

  protected GroovyScriptHandler scriptHandler;





  public TimedGroovyScript() {

    super();

    logger = Logger.getLogger(this.getClass().getPackage().getName());

  }



  public TimedGroovyScript(List script) {

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

  public GroovyScriptHandler getScriptHandler() {

    return scriptHandler;

  }



  /**

   * @param scriptHandler The scriptHandler to set.

   */

  public void setScriptHandler(GroovyScriptHandler scriptHandler) {

    this.scriptHandler = scriptHandler;

  }

}

