package au.com.BI.Script;

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

public class GroovyScriptHandler {

	protected String fileName;
	protected ConcurrentHashMap <String, Integer>abortingScript;

	protected Logger logger;
	protected Cache cache;
	
	//  protected List commandList;
	protected ConcurrentHashMap <String, GroovyScriptRunBlock>scriptRunBlockList;
	protected GroovyScriptEngine gse = null;
	protected Timer timerMinute, timerHour, timerDay;

	protected TimedGroovyScript timedScriptMinute, timedScriptHour, timedScriptDay;
	protected Model scriptModel;
	protected String statusFileName;
	public static final int maxRepeats = 4;
	protected List <String>timerListMinute, timerListHour, timerListDay;
	public static final int MINUTE_INTERVAL = 60000;
	public static final int HOUR_INTERVAL = 3600000;
	public static final int DAY_INTERVAL = 86400000;


	public GroovyScriptHandler(Model scriptModel, ConcurrentHashMap <String, GroovyScriptRunBlock>scriptRunBlockList,
			String statusFileName, GroovyScriptEngine gse) { 
		super();

		this.statusFileName = statusFileName;
		this.gse = gse;

		logger = Logger.getLogger(this.getClass().getPackage().getName());
		
		abortingScript = new ConcurrentHashMap<String,Integer>();
		this.scriptRunBlockList = scriptRunBlockList;
		// this.setCommandList(commandList);
		this.scriptModel = scriptModel;

		timerListMinute = new ArrayList<String>();
		timerListHour = new ArrayList<String>();
		timerListDay = new ArrayList<String>();
	}

	public boolean run(String scriptName, CommandInterface triggeringCommand) {
		GroovyScriptRunBlock scriptRunBlock = (GroovyScriptRunBlock) scriptRunBlockList
				.get(scriptName);
		ScriptParams params = scriptRunBlock.nextRun();

		if (scriptRunBlock != null) {
			return runScript(scriptRunBlock,  scriptModel, params,true);
		} else {
			return false;
		} 
	}

	/**
	 * @param id
	 */
	public void scriptFinished(GroovyScriptRunBlock groovyScriptRunBlock, long id) {
		groovyScriptRunBlock.scriptFinished(id);
		if (groovyScriptRunBlock.moreToRun()){
			runScript (   groovyScriptRunBlock,  scriptModel, groovyScriptRunBlock.nextRun(),  true) ;
		}
	}
	
	public boolean run(String scriptName, String parameter, User user, CommandInterface triggeringCommand) {
		boolean doNotRun = false;

			GroovyScriptRunBlock scriptRunBlock = (GroovyScriptRunBlock) scriptRunBlockList
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

		boolean scriptAlreadyRunning = false;
		boolean noQueue = false; // DEFAULT SHOULD BE FALSE CC
		if (parameter.equals("no_queue"))
			noQueue = true;
		if (scriptRunBlock.isRunning()) {
			scriptAlreadyRunning = true;
		}

		if (scriptAlreadyRunning && noQueue) {
			logger.log(Level.INFO, "User attempted to run " + scriptName
					+ " twice");
			return false;
		}
		GroovyScriptRunBlock groovyScriptRunBlock = (GroovyScriptRunBlock) scriptRunBlockList
		.get(scriptName);
		ScriptParams params = new ScriptParams(parameter, user);
		params.setTriggeringCommand (triggeringCommand);
		if (groovyScriptRunBlock.isRunning()  && !noQueue) {
			groovyScriptRunBlock.addRun(params);

			scriptRunBlockList.put(scriptName, groovyScriptRunBlock);
			logger.log(Level.FINER, "Queued script " + scriptName);
			return true;
			// Do not run at this stage, instead queue to be run after completion
		}

		return runScript(groovyScriptRunBlock, scriptModel,  params,true);

	}

	public boolean runScript(GroovyScriptRunBlock groovyScriptRunBlock,  Model scriptModel, ScriptParams scriptParams, boolean asThread) {
			String scriptName = groovyScriptRunBlock.getName();
			abortingScript.put(scriptName, 0); // Why ?????? CC
			RunGroovyScript newScript = new RunGroovyScript(groovyScriptRunBlock, 
					 scriptModel, scriptParams, gse);

			groovyScriptRunBlock.addRunningInfo(newScript.getId(), newScript);
			if (asThread) {
				newScript.start();				
			} else {
				newScript.run();								
			}
			logger.log(Level.FINE, "Started script " + scriptName);
			return true;
	}
	
	public boolean ownsScript (String scriptName){
		return scriptRunBlockList.containsKey(scriptName);
	}

	public void loadScriptFile() {
		boolean updated = false;
		Date now = new Date();
		GroovyScriptRunBlock scriptRunBlock = null;
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
						 scriptRunBlock = (GroovyScriptRunBlock)item;
						 scriptRunBlock.clearRunningInfo();
					} else {

						toRemove.add(name);
						updated = true;
						continue;
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

				for (GroovyScriptRunBlock item: scriptRunBlockList.values()){

					if (item.getLastUpdated().before(now)) {
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
			try {
				Element scriptStatusElm = new Element("SCRIPT_STATUS");
				for (GroovyScriptRunBlock scriptRunBlock : scriptRunBlockList.values()){


					Element scriptElement = new Element("SCRIPT");
					scriptElement
							.setAttribute("NAME", scriptRunBlock.getName());
					if (scriptRunBlock.isEnabled())
						scriptElement.setAttribute("ENABLED", "enabled");
					else
						scriptElement.setAttribute("ENABLED", "disabled");
					String statusString = scriptRunBlock.getStatusString();
					if (scriptRunBlock.isHidden()){
						scriptElement.setAttribute("FORCED_HIDDEN", "true");
					} else {
						scriptElement.setAttribute("FORCED_HIDDEN", "false");						
					}
					scriptElement.setAttribute("STATUS", statusString);
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

	
	public boolean setStatus(String name, String status) {
		if (name != null && status != null && !name.equals("")) {
				GroovyScriptRunBlock scriptRunBlock = (GroovyScriptRunBlock) scriptRunBlockList
						.get(name);
				if (scriptRunBlock != null) {
					scriptRunBlock.setStatusString(status);
					scriptRunBlockList.put(name, scriptRunBlock);
				} else {
					return false;
				}
			saveScriptFile();
			return true;
		} else {
			return false;
		}
	}

	protected boolean setScriptEnable(String scriptName, User user,
			boolean enabled)  {
		if (scriptName == null && !scriptName.equals("")) {
			return false;
		}

		GroovyScriptRunBlock scriptRunBlock =scriptRunBlockList.get(scriptName);
		if (scriptRunBlock != null) {
			scriptRunBlock.setEnabled(enabled);
		} else {

			return false;
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


	/**
	 * Returns the script list as an XML element,or a specific script.
	 * @param scriptName Empty string for all scripts or the name of a script
	 * @return
	 */
	public List<Element> get(String scriptName) {
		List <Element>returnList = new LinkedList<Element>();

			if (scriptName.equals("")) {
				for (GroovyScriptRunBlock theScript:scriptRunBlockList.values()){
					if (!theScript.isHidden()){
						Element scriptDef = buildListElement(theScript);
						returnList.add(scriptDef);
					}
				}
			} else {
				GroovyScriptRunBlock scriptRunBlock = scriptRunBlockList.get(scriptName);
				Element scriptDef = buildListElement(scriptRunBlock);
				returnList.add (scriptDef);

			}
		return returnList;
	}

	public Element buildListElement(GroovyScriptRunBlock scriptRunBlock) {
		String myTimer;


		Element scriptDef = new Element("CONTROL");
		scriptDef.setAttribute("KEY", "SCRIPT");
		scriptDef.setAttribute("COMMAND", "getList");
		scriptDef.setAttribute("EXTRA", scriptRunBlock.getName());
		
		if (scriptRunBlock == null) {
			// I don't think this can ever be reached
			logger.info("This line should never be reached, please report to BI");
			scriptRunBlock = new GroovyScriptRunBlock();
			scriptRunBlock.setName("NEW");
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

		if (scriptRunBlock.isRunning()) {
			scriptDef.setAttribute("RUNNING", "1");
		} else {
			scriptDef.setAttribute("RUNNING", "0");
		}

		return scriptDef;
	}



	
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
		RunGroovyScript theScript;

		for (String scriptName: scriptRunBlockList.keySet()){
			logger.log(Level.FINE, "Disable script " + scriptName);

			GroovyScriptRunBlock scriptRunBlock = (GroovyScriptRunBlock)scriptRunBlockList.get(scriptName);
			if (scriptRunBlock != null) {
				scriptRunBlock.setEnabled(false);
				scriptRunBlockList.put(scriptName,scriptRunBlock);
			}

		}
		this.saveScriptFile();
	}

	public void enableAll() {
		RunGroovyScript theScript;
		for (String scriptName: scriptRunBlockList.keySet()){
			logger.log(Level.FINE, "Enable script " + scriptName);

			GroovyScriptRunBlock scriptRunBlock = scriptRunBlockList.get(scriptName);
			if (scriptRunBlock != null) {
				scriptRunBlock.setEnabled(false);
				scriptRunBlockList.put(scriptName,scriptRunBlock);
			}
		}
		this.saveScriptFile();
	}


	public Cache getCache() {
		return cache;
	}

	public void setCache(Cache cache) {
		this.cache = cache;
	}

	/**
	 * @param scriptName
	 * @return
	 */
	public boolean isHidden(String scriptName) {
		GroovyScriptRunBlock groovyScriptRunBlock = scriptRunBlockList.get(scriptName);
		if (groovyScriptRunBlock == null) return false;
		if (groovyScriptRunBlock.isHidden() || groovyScriptRunBlock.getStatusString().contains("hidden")){ 
			return true;
		}
		
		return false;
		
	}

}
