package au.com.BI.GroovyScripts;

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

import java.io.*;
import java.util.*;

import org.jdom.*;
import org.jdom.output.Format;
import org.jdom.input.*;
import org.jdom.output.XMLOutputter;
import au.com.BI.Flash.*;
import au.com.BI.User.*;
import java.util.logging.*;

public class ScriptHandler {
	/**
	 *
	 */
	protected String fileName;

	protected Map scripts, abortingScript;

	protected Logger logger;

	//  protected List commandList;
	protected Map runningScripts, scriptRunBlockList;

	protected Model scriptModel;

	protected String statusFileName;

	public static final int maxRepeats = 4;


	public ScriptHandler(int numberOfScripts,
			Model scriptModel, Map scriptRunBlockList,
			String statusFileName) { //,List commandList) {
		super();
		//scripts = new HashMap (numberOfScripts);
		this.statusFileName = statusFileName;

		logger = Logger.getLogger(this.getClass().getPackage().getName());
		runningScripts = Collections.synchronizedMap(new LinkedHashMap());
		abortingScript = Collections.synchronizedMap(new HashMap());
		this.scriptRunBlockList = scriptRunBlockList;
		// this.setCommandList(commandList);
		this.scriptModel = scriptModel;
		scripts = scriptModel.getScriptFiles();
	}

	public boolean finishedRunning(String scriptName) {
		boolean returnCode = true;
		
		synchronized (this.scriptRunBlockList) {
			ScriptRunBlock scriptRunBlock = (ScriptRunBlock) scriptRunBlockList
					.get(scriptName);
			if (scriptRunBlock.moreToRun()) {
				returnCode = false; // don't flag it as finished; and run enxt one.
				scriptRunBlockList.put(scriptName, scriptRunBlock);
			}
		}
		if (returnCode) {
			synchronized (runningScripts) {
				runningScripts.remove(scriptName);
			}
		}
		return returnCode;
	}

	public boolean run(String scriptName) {
		ScriptRunBlock scriptRunBlock = (ScriptRunBlock) scriptRunBlockList
				.get(scriptName);
		ScriptParams params = scriptRunBlock.nextRun();
		if (scriptRunBlock != null) {
			return runScript(scriptName,  params.getUser(),scriptModel);
		} else {
			return false;
		}

	}

	public boolean run(String scriptName, String parameter, User user) {
		boolean doNotRun = false;

		synchronized (this.scriptRunBlockList) {
			ScriptRunBlock scriptRunBlock = (ScriptRunBlock) scriptRunBlockList
					.get(scriptName);
			if (scriptRunBlock == null) {
				logger.log(Level.FINER, "Run script : " + scriptName
						+ " was sent, but script is unknown");
				return false;
			}
			if (!scriptRunBlock.isEnabled()) {
				logger.log(Level.FINER, "Run script : " + scriptName
						+ " was sent, but script is disabled");
				return false;
			}
		}

		boolean scriptAlreadyRunning = false;
		boolean noQueue = false; // DEFAULT SHOULD BE FALSE CC
		if (parameter.equals("no_queue"))
			noQueue = true;
		synchronized (runningScripts) {
			if (runningScripts.containsKey(scriptName)) {
				scriptAlreadyRunning = true;
			}
		}
		if (scriptAlreadyRunning && noQueue) {
			logger.log(Level.FINE, "User attempted to run " + scriptName
					+ " twice");
			return false;
		}
		if (scriptAlreadyRunning && !noQueue) {
			ScriptParams params = new ScriptParams(parameter, user);
			synchronized (scriptRunBlockList) {
				ScriptRunBlock scriptRunBlock = (ScriptRunBlock) scriptRunBlockList
						.get(scriptName);
				scriptRunBlock.addRun(params);
				scriptRunBlockList.put(scriptName, scriptRunBlock);
			}
			logger.log(Level.FINER, "Queued script " + scriptName);
			return true;
			// Do not run at this stage, instead queue to be run after completion
		}

		return runScript(scriptName, user, scriptModel);

	}

	public boolean runScript(String scriptName, User user, Model scriptModel) {
		ArrayList linesOfScript = null;
		synchronized (scripts) {
			linesOfScript = (ArrayList) scripts.get(scriptName);
		}

		if (linesOfScript == null) {
			logger
					.log(Level.WARNING,
							"Specifed script not found, or script empty: "
									+ scriptName);
			return false;
		} else {
			abortingScript.put(scriptName, new Integer(0)); // Why ?????? CC
			RunScript newScript = new RunScript(scriptName, user,
					linesOfScript, scriptModel);
			newScript.setCommandList(scriptModel.getCommandQueue());
			newScript.setName("Script:" + scriptName);
			synchronized (runningScripts) {
				runningScripts.put(scriptName, newScript);
			}
			newScript.start();
			logger.log(Level.FINE, "Started script " + scriptName);
			return true;
		}

	}

	public void loadScriptFile() {
		boolean updated = false;
		Date now = new Date();
		ScriptRunBlock scriptRunBlock = null;

		synchronized (this.scriptRunBlockList) {
			try {
				SAXBuilder builder = null;

				builder = new SAXBuilder();
				Document doc = builder.build(statusFileName);
				Element theConfig = doc.getRootElement();

				List scriptsList = theConfig.getChildren();
				
				// Parse each script from the status file and ensure it is still on the system
				Iterator eachScript = scriptsList.iterator();
				while (eachScript.hasNext()) {
					Element scriptElement = (Element) eachScript.next();
					String name = scriptElement.getAttributeValue("NAME");
					String enabled = scriptElement.getAttributeValue("ENABLED");
					if (enabled == null)
						enabled = "";
					String status = scriptElement.getAttributeValue("STATUS");
					if (status == null)
						status = "";
					if (scriptRunBlockList.containsKey(name)) {
						Object item = scriptRunBlockList.get(name);
						 scriptRunBlock = (ScriptRunBlock)item;
					} else {
						if (!this.runningScripts.containsKey(name)) {
							// If not on the file system, and not running. Delete it from memory.
							eachScript.remove();
							updated = true;
							continue;
						}
					}
					scriptRunBlock.setStatusString(status);
					scriptRunBlock.setLastUpdated(now);

					if (enabled.equals("disabled"))
						scriptRunBlock.setEnabled(false);
					else
						scriptRunBlock.setEnabled(true);
					this.scriptRunBlockList.put(name, scriptRunBlock);
				}
				Iterator eachScriptBlock = scriptRunBlockList.values()
						.iterator();
				while (eachScriptBlock.hasNext()) {
					Object item = eachScriptBlock.next();
					scriptRunBlock = (ScriptRunBlock) item;
					if (scriptRunBlock.getLastUpdated().before(now)) {
						// Script on the file system but not yet in the status file.
						updated = true;
					}
				}
			} catch (IOException e) {
				logger.log(Level.FINE,
						"System failed reading script status file "
								+ statusFileName + " " + e.getMessage());
				updated = true;
			} catch (JDOMException e) {
				logger.log(Level.WARNING, "Cannot read script status file "
						+ statusFileName + " " + e.getMessage());
			}
			

		}
		if (updated) {
			saveScriptFile();
		}
	}

	public void saveScriptFile() {
		synchronized (scriptRunBlockList) {
			try {
				Element scriptStatusElm = new Element("SCRIPT_STATUS");
				Iterator eachScript = this.scriptRunBlockList.values()
						.iterator();
				while (eachScript.hasNext()) {
					ScriptRunBlock scriptRunBlock = (ScriptRunBlock) eachScript
							.next();

					Element scriptElement = new Element("SCRIPT");
					scriptElement
							.setAttribute("NAME", scriptRunBlock.getName());
					if (scriptRunBlock.isEnabled())
						scriptElement.setAttribute("ENABLED", "enabled");
					else
						scriptElement.setAttribute("ENABLED", "disabled");
					scriptElement.setAttribute("STATUS", scriptRunBlock
							.getStatusString());
					scriptStatusElm.addContent(scriptElement);
				}
				XMLOutputter xmlOut = new XMLOutputter(Format.getPrettyFormat());
				File outputFile = new File(statusFileName);
				if (!outputFile.exists() || outputFile.canWrite()) {
					FileWriter out = new FileWriter(outputFile);
					xmlOut.output(scriptStatusElm, out);
					out.flush();
					out.close();
					logger.log(Level.FINE, "Script status write succeeded.");
				} else {
					logger.log(Level.WARNING,
							"Cannot write script status file.");
				}
			} catch (IOException e) {
				logger.log(Level.WARNING,
						"System failed writing script status file "
								+ statusFileName + " " + e.getMessage());
			}
		}
	}



	public boolean setStatus(String name, String status) {
		if (name != null && status != null && !name.equals("")) {
			synchronized (this.scriptRunBlockList) {
				ScriptRunBlock scriptRunBlock = (ScriptRunBlock) scriptRunBlockList
						.get(name);
				if (scriptRunBlock != null) {
					scriptRunBlock.setStatusString(status);
					scriptRunBlockList.put(name, scriptRunBlock);
				} else {
					logger.log(Level.WARNING,
							"A script status update was received for a script that does not exist "
									+ name);
					return false;
				}
			}
			saveScriptFile();
			return true;
		} else {
			return false;
		}
	}

	protected boolean setScriptEnable(String scriptName, User user,
			boolean enabled) {
		if (scriptName == null && !scriptName.equals("")) {
			logger.log(Level.WARNING,
					"Enable/Disable script was called with no script name");
			return false;
		}
		RunScript theScript;
		logger.log(Level.FINE, "Disable script " + scriptName);
		synchronized (runningScripts) {
			theScript = (RunScript) runningScripts.get(scriptName);
			if (theScript != null) {
				theScript.setEnable(enabled);
			}
		}
		synchronized (this.scriptRunBlockList) {
			ScriptRunBlock scriptRunBlock = (ScriptRunBlock) scriptRunBlockList
					.get(scriptName);
			if (scriptRunBlock != null) {
				scriptRunBlock.setEnabled(enabled);
				scriptRunBlockList.put(scriptName, scriptRunBlock);
			} else {
				logger
						.log(
								Level.WARNING,
								"A script enable/disable request was received for a script that does not exist "
										+ scriptName);
				return false;
			}
		}
		this.saveScriptFile();

		return true;
	}

	public boolean disableScript(String scriptName, User user) {

		return setScriptEnable(scriptName, user, false);
	}

	public boolean enableScript(String scriptName, User user) {

		return setScriptEnable(scriptName, user, true);
	}

	public void abort(String scriptName) {
		synchronized (abortingScript) {
			abortingScript.put(abortingScript, new Integer(1));
		}
	}

	public boolean isScriptStillRunning(String scriptName) {
		synchronized (abortingScript) {
			if (!abortingScript.containsKey(scriptName))
				return true;

			Integer val = (Integer) abortingScript.get(scriptName);
			if (val.intValue() == 1)
				return false;
			else
				return true;
		}
	}

	/*   public boolean complete(String scriptName, User user) {
	 RunScript theScript;
	 logger.log (Level.FINE,"Running script "+ scriptName + " to completion");
	 synchronized (runningScripts) {
	 theScript = (RunScript)runningScripts.get(scriptName);
	 }
	 if (theScript != null) {
	 theScript.setContinueToEnd(true);
	 }
	 return true;
	 } */

	/**
	 * Returns the script list as an XML element,or a specific script.
	 * @param scriptName Empty string for all scripts or the name of a script
	 * @return
	 */
	public Element get(String scriptName) {
		Element top = new Element("SCRIPT");

		synchronized (scripts) {
			if (scriptName.equals("")) {
				Iterator scriptNames = scripts.keySet().iterator();
				while (scriptNames.hasNext()) {
					Element scriptDef = buildListElement((String) scriptNames
							.next());
					try {
						if (scriptDef != null)
							top.addContent(scriptDef);
					} catch (NoSuchMethodError ex) {
						logger.log(Level.SEVERE, "Error calling jdom library "
								+ ex.getMessage());
					}
				}
			} else {
				Element scriptDef = buildListElement(scriptName);
				if (scriptDef != null)
					top.addContent(scriptDef);

			}
		}
		return top;
	}

	public Element buildListElement(String scriptName) {
		String myTimer;
		Object scriptObject = scripts.get(scriptName);
		List script = (List) scriptObject;
		if (script == null)
			return null;
		ScriptRunBlock scriptRunBlock = null;
		synchronized (scriptRunBlockList){
			scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get(scriptName);
		}
		Element scriptDef = new Element("CONTROL");
		scriptDef.setAttribute("KEY", "SCRIPT");
		scriptDef.setAttribute("COMMAND", "getList");
		scriptDef.setAttribute("EXTRA", scriptName);
		
		if (scriptRunBlock == null) {
			scriptRunBlock = new ScriptRunBlock();
			scriptRunBlock.setName(scriptName);
		}


		if (scriptRunBlock.isEnabled()){
			scriptDef.setAttribute("ENABLED", "enabled");
		} else {
			scriptDef.setAttribute("ENABLED", "disabled");			
		}

		scriptDef.setAttribute("STATUS", scriptRunBlock.getStatusString());
		if (scriptRunBlock.getStatusString().toUpperCase().indexOf("HIDDEN") >= 0)
			return null;

		if (scriptRunBlock.isStoppable()) {
			scriptDef.setAttribute("STOPPABLE", "Y");
		} else {
			scriptDef.setAttribute("STOPPABLE", "N");
		}

		if (this.runningScripts.containsKey(scriptName)) {
			scriptDef.setAttribute("RUNNING", "1");
		} else {
			scriptDef.setAttribute("RUNNING", "0");
		}

		return scriptDef;
	}

	public void put(String name, Element scriptElement) {
		LinkedList script = parseElement(scriptElement);
		if (script != null) {
			synchronized (scripts) {
				scripts.put(name, script);
			}
		}
		this.saveScriptFile();
	}

	
	public LinkedList parseElement(Element element) {
		LinkedList newScript = new LinkedList();
		List scriptCommands = element.getChildren();
		Iterator scriptCommandList = scriptCommands.iterator();
		while (scriptCommandList.hasNext()) {
			Element scriptElement = (Element) scriptCommandList.next();
			ClientCommand scriptElementCommand = new ClientCommand();
			scriptElementCommand.setFromElement(scriptElement);
			if (scriptElementCommand != null)
				newScript.add(scriptElementCommand);
		}
		return newScript;
	}

	public void disableAll() {
		RunScript theScript;
		Iterator eachScript = runningScripts.keySet().iterator();
		while (eachScript.hasNext()) {
			String scriptName = (String) eachScript.next();
			logger.log(Level.FINE, "Disable script " + scriptName);
			synchronized (runningScripts) {
				theScript = (RunScript) runningScripts.get(scriptName);
			}
			if (theScript != null) {
				theScript.setEnable(false);
			}
			synchronized (scriptRunBlockList){
				ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get(scriptName);
				if (scriptRunBlock != null) {
					scriptRunBlock.setEnabled(false);
					scriptRunBlockList.put(scriptName,scriptRunBlock);
				}
			}

		}
		this.saveScriptFile();
	}

	public void enableAll() {
		RunScript theScript;
		Iterator eachScript = runningScripts.keySet().iterator();
		while (eachScript.hasNext()) {
			String scriptName = (String) eachScript.next();
			logger.log(Level.FINE, "Enable script " + scriptName);
			synchronized (runningScripts) {
				theScript = (RunScript) runningScripts.get(scriptName);
			}
			if (theScript != null) {
				theScript.setEnable(true);
			}
			synchronized (scriptRunBlockList){
				ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get(scriptName);
				if (scriptRunBlock != null) {
					scriptRunBlock.setEnabled(false);
					scriptRunBlockList.put(scriptName,scriptRunBlock);
				}
			}
		}
		this.saveScriptFile();
	}

	public void removeRunningScript(String scriptName) {
		synchronized (runningScripts) {
			runningScripts.remove(scriptName);
		}
	}


	public boolean isScriptRunning(String scriptName) {
		synchronized (runningScripts) {
			if (runningScripts.containsKey(scriptName)) {
				return true;
			}
			return false;
		}
	}

	public String getStatusFileName() {
		return statusFileName;
	}

	public void setStatusFileName(String statusFileName) {
		this.statusFileName = statusFileName;
	}

}
