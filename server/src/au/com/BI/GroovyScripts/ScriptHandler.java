package au.com.BI.GroovyScripts;

import groovy.util.GroovyScriptEngine;

import java.io.*;
import java.util.*;

import org.jdom.*;
import org.jdom.output.Format;
import org.jdom.input.*;
import org.jdom.output.XMLOutputter;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Flash.*;
import au.com.BI.User.*;

import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.*;

public class ScriptHandler {

	protected String fileName;
	protected ConcurrentHashMap <String, Integer>abortingScript;

	protected Logger logger;
	protected Cache cache;
	
	//  protected List commandList;
	protected ConcurrentHashMap <String, RunScript>runningScripts;
	protected ConcurrentHashMap <String, ScriptRunBlock>scriptRunBlockList;
	protected GroovyScriptEngine gse = null;
	protected Timer timerMinute, timerHour, timerDay;

	protected TimedScript timedScriptMinute, timedScriptHour, timedScriptDay;

	protected Model scriptModel;

	protected String statusFileName;

	public static final int maxRepeats = 4;

	protected List <String>timerListMinute, timerListHour, timerListDay;

	public static final int MINUTE_INTERVAL = 60000;

	public static final int HOUR_INTERVAL = 3600000;

	public static final int DAY_INTERVAL = 86400000;


	public ScriptHandler(int numberOfScripts,
			Model scriptModel, ConcurrentHashMap <String, ScriptRunBlock>scriptRunBlockList,
			String statusFileName) { 
		super();

		this.statusFileName = statusFileName;

		logger = Logger.getLogger(this.getClass().getPackage().getName());
		runningScripts = new ConcurrentHashMap<String, RunScript>();
		
		abortingScript = new ConcurrentHashMap<String,Integer>();
		this.scriptRunBlockList = scriptRunBlockList;
		// this.setCommandList(commandList);
		this.scriptModel = scriptModel;

		timerListMinute = new ArrayList<String>();
		timerListHour = new ArrayList<String>();
		timerListDay = new ArrayList<String>();
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

	public boolean run(String scriptName, CommandInterface triggeringCommand) {
		ScriptRunBlock scriptRunBlock = (ScriptRunBlock) scriptRunBlockList
				.get(scriptName);
		ScriptParams params = scriptRunBlock.nextRun();
		if (scriptRunBlock != null) {
			return runScript(scriptName,  params.getUser(),scriptModel, triggeringCommand);
		} else {
			return false;
		} 
	}

	public boolean run(String scriptName, String parameter, User user, CommandInterface triggeringCommand) {
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

		return runScript(scriptName, user, scriptModel,  triggeringCommand);

	}

	public boolean runScript(String scriptName, User user, Model scriptModel, CommandInterface triggeringCommand) {

			abortingScript.put(scriptName, 0); // Why ?????? CC
			RunScript newScript = new RunScript(scriptName, user,
					 scriptModel, triggeringCommand, gse);

			runningScripts.put(scriptName, newScript);
			newScript.start();
			logger.log(Level.FINE, "Started script " + scriptName);
			return true;
	}

	public void loadScriptFile() {
		boolean updated = false;
		Date now = new Date();
		ScriptRunBlock scriptRunBlock = null;
		LinkedList <String> toRemove = new LinkedList<String>();

			try {
				SAXBuilder builder = null;

				builder = new SAXBuilder();
				Document doc = builder.build(statusFileName);
				Element theConfig = doc.getRootElement();

				List <Element> scriptsList = (List<Element>)theConfig.getChildren();
				
				// Parse each script from the status file and ensure it is still on the system

				for (Element scriptElement:scriptsList ){
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
							toRemove.add(name);
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
				for (String i: toRemove) {
					scriptRunBlockList.remove(i);
				}

				for (ScriptRunBlock item: scriptRunBlockList.values()){

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
			

		if (updated) {
			saveScriptFile();
		}
	}

	public void saveScriptFile() {
		synchronized (scriptRunBlockList) {
			try {
				Element scriptStatusElm = new Element("SCRIPT_STATUS");
				for (ScriptRunBlock scriptRunBlock : scriptRunBlockList.values()){


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

	public void addTimerControls() {

		if (timerListMinute.isEmpty() == false) {
			timedScriptMinute = new TimedScript(timerListMinute);
			timedScriptMinute.setScriptHandler(this);
			logger.log(Level.FINE, "Launching script Minute Timer:");
			timerMinute = new Timer();
			timerMinute.schedule(timedScriptMinute, MINUTE_INTERVAL,
					MINUTE_INTERVAL);
		} else if (timerListHour.isEmpty() == false) {
			timedScriptHour = new TimedScript(timerListHour);
			timedScriptHour.setScriptHandler(this);
			logger.log(Level.FINE, "Launching script Hour Timer:");
			timerHour = new Timer();
			timerHour.schedule(timedScriptHour, HOUR_INTERVAL, HOUR_INTERVAL);
		} else if (timerListDay.isEmpty() == false) {
			timedScriptDay = new TimedScript(timerListDay);
			timedScriptDay.setScriptHandler(this);
			logger.log(Level.FINE, "Launching script Day Timer:");
			timerDay = new Timer();
			timerDay.schedule(timedScriptDay, DAY_INTERVAL, DAY_INTERVAL);
		}

	}

	public void removeAllTimers() {
		timerMinute.cancel();
		timerHour.cancel();
		timerDay.cancel();
	}

	public String getTimerListType(String script) {
		if (timerListMinute.contains(script) == true) {
			return "minute";
		} else if (timerListHour.contains(script) == true) {
			return "hour";
		} else {
			if (timerListDay.contains(script) == true) {
				return "day";
			}
		}
		return "";
	}

	public void addTimerListMinute(String script) {
		if (timerListMinute.contains(script) == false) {
			timerListMinute.add(script);
		}
	}

	public void addTimerListHour(String script) {
		if (timerListHour.contains(script) == false) {
			timerListHour.add(script);
		}
	}

	public void addTimerListDay(String script) {
		if (timerListDay.contains(script) == false) {
			timerListDay.add(script);
		}
	}

	public void initTimerLists() {
		timerListMinute.clear();
		timerListMinute.clear();
		timerListDay.clear();
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
		abortingScript.put(scriptName, 1);
	}

	public boolean isScriptStillRunning(String scriptName) {
		if (!abortingScript.containsKey(scriptName))
			return true;

		int val = abortingScript.get(scriptName);
		if (val  == 1)
			return false;
		else
			return true;
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

			if (scriptName.equals("")) {
				for (String theName:scriptRunBlockList.keySet()){
					Element scriptDef = buildListElement(theName);
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
		return top;
	}

	public Element buildListElement(String scriptName) {
		String myTimer;
		ScriptRunBlock scriptRunBlock= scriptRunBlockList.get(scriptName);
		if (scriptRunBlock == null)
			return null;

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
		myTimer = getTimerListType(scriptName);
		scriptDef.setAttribute("TIMER", myTimer);

		return scriptDef;
	}

	/*
	public void put(String name, Element scriptElement) {
		LinkedList script = parseElement(scriptElement);
		if (script != null) {
			synchronized (scripts) {
				scripts.put(name, script);
			}
		}
		this.saveScriptFile();
	}
	*/

	
	public LinkedList <ClientCommand>parseElement(Element element) {
		LinkedList <ClientCommand>newScript = new LinkedList<ClientCommand>();

		for (Element scriptElement : (List<Element>)element.getChildren()){
			ClientCommand scriptElementCommand = new ClientCommand();
			scriptElementCommand.setFromElement(scriptElement);
			if (scriptElementCommand != null)
				newScript.add(scriptElementCommand);
		}
		return newScript;
	}

	public void disableAll() {
		RunScript theScript;

		for (String scriptName: runningScripts.keySet()){
			logger.log(Level.FINE, "Disable script " + scriptName);
			theScript = (RunScript) runningScripts.get(scriptName);
			if (theScript != null) {
				theScript.setEnable(false);
			}
				ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get(scriptName);
				if (scriptRunBlock != null) {
					scriptRunBlock.setEnabled(false);
					scriptRunBlockList.put(scriptName,scriptRunBlock);
			}

		}
		this.saveScriptFile();
	}

	public void enableAll() {
		RunScript theScript;
		for (String scriptName: runningScripts.keySet()){
			logger.log(Level.FINE, "Enable script " + scriptName);
			theScript = (RunScript) runningScripts.get(scriptName);
			if (theScript != null) {
				theScript.setEnable(true);
			}

			ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get(scriptName);
			if (scriptRunBlock != null) {
				scriptRunBlock.setEnabled(false);
				scriptRunBlockList.put(scriptName,scriptRunBlock);
			}
		}
		this.saveScriptFile();
	}

	public void removeRunningScript(String scriptName) {
			runningScripts.remove(scriptName);
	}


	public boolean isScriptRunning(String scriptName) {
			if (runningScripts.containsKey(scriptName)) {
				return true;
			}
			return false;
	}

	public String getStatusFileName() {
		return statusFileName;
	}

	public void setStatusFileName(String statusFileName) {
		this.statusFileName = statusFileName;
	}

	public Cache getCache() {
		return cache;
	}

	public void setCache(Cache cache) {
		this.cache = cache;
	}

}
