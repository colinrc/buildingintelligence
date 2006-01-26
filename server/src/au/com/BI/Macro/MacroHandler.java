/*
 * Created on Apr 13, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Macro;
import org.jdom.*;
import org.jdom.output.Format;

import java.io.*;
import java.util.*;

import au.com.BI.Flash.*;
import au.com.BI.Util.*;
import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Command.CommandInterface;
import java.util.Collections;
import au.com.BI.User.*;
import java.util.logging.*;

import org.jdom.input.*;
import org.jdom.output.XMLOutputter;
import org.quartz.*;

/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class MacroHandler {
	/**
	 * 
	 */
	protected String fileName = "";
	protected String calendarFileName = "";
	protected Map macros = null;
	protected Map macros_status = null;
	protected Logger logger;
	protected List commandList = null;
	protected Map runningMacros = null;
	protected EventCalendar eventCalendar = null;
	protected Map macros_type = null;
	protected Map calendar_message_params;
	
	public MacroHandler() {
		super();
		
		macros = Collections.synchronizedMap(new LinkedHashMap(DeviceModel.NUMBER_MACROS));

		macros_status =  Collections.synchronizedMap(new LinkedHashMap(DeviceModel.NUMBER_MACROS));
		macros_type = Collections.synchronizedMap(new LinkedHashMap(DeviceModel.NUMBER_MACROS));
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		runningMacros = Collections.synchronizedMap(new HashMap(DeviceModel.NUMBER_MACROS));
	}
	

	public void clearAll () {
		this.abortAll();
		synchronized (macros) {
			macros.clear();
		}
		synchronized (macros_status) {
			macros_status.clear();
		}
		synchronized (runningMacros) {
			runningMacros.clear();
		}
	}

	public boolean run(String macroName, User user,CommandInterface origCommand) {
		List macro;
		boolean doNotRun = false;
		
		String realName[] = macroName.split(":");
		
		synchronized (macros) {
			macro = (List)macros.get(realName[0]);
		}
		if (macro == null) {
			logger.log (Level.WARNING,"Specified macro not found : " + macroName);
			return false;
		}
		else {
		    synchronized (runningMacros) {
		        if (runningMacros.containsKey(macroName)) 
		            doNotRun = true;
		    }
		    if (doNotRun) {
		        logger.log (Level.FINE,"User attempted to run " + macroName + " twice");
		        return false;
		    } else {
				RunMacro newMacro = new RunMacro (macro, user, macroName,origCommand);
				newMacro.setCommandList(commandList);
				newMacro.setName("Macro:"+ macroName);
				synchronized (runningMacros) {
				    runningMacros.put (macroName,newMacro);
				}
				newMacro.setRunningMacros (runningMacros);
				newMacro.start();
				logger.log (Level.INFO,"Running macro " + macroName);
				return true;
		    }
		}
	}

	public void setCommandList (List commandList){
		this.commandList = commandList;
	}
	
	public boolean abort(String macroName, User user) {
	    RunMacro theMacro;
        logger.log (Level.FINE,"Aborting macro "+ macroName);
	    synchronized (runningMacros) {
	        theMacro = (RunMacro)runningMacros.get(macroName);
	    }
	    if (theMacro != null) {
	        theMacro.setAbort(true);
	        theMacro.interrupt();
	    }
		return true;
	}
	
	public void runStartup () {
		if (this.macros.containsKey("eLife_Startup")) {
			run ("eLife_Startup",null,null);
		}
	}

	public boolean complete(String macroName, User user) {
	    RunMacro theMacro;
        logger.log (Level.FINE,"Running macro "+ macroName + " to completion");
	    synchronized (runningMacros) {
	        theMacro = (RunMacro)runningMacros.get(macroName);
	    }
	    if (theMacro != null) {
	        theMacro.setContinueToEnd(true);
	        theMacro.interrupt();
	    }
		return true;
	}	
	/**
	 * Returns the macro list as an XML element,or a specific macro.
	 * @param macroName Empty string for all macros or the name of a macro
	 * @return
	 */
	public Element get (String macroName, boolean showHidden) {
		Element top = new Element ("MACROS");
		
		synchronized (macros) {
			if (macroName.equals ("")) {
				Iterator macroNames = macros.keySet().iterator();
				while (macroNames.hasNext()) {
					Element macroDef =  buildListElement ((String)macroNames.next(),showHidden);
					try { 
					    if (macroDef != null) top.addContent(macroDef);
					} catch (NoSuchMethodError ex) {
					    logger.log (Level.SEVERE,"Error calling jdom library " + ex.getMessage());
					}
				}
			}
			else {
				Element macroDef = buildListElement (macroName,showHidden);
				if (macroDef != null)
				    top.addContent( macroDef);
				
			}
		}
		return top;
	}

	
	/**
	 * Returns the macro list as an XML element,or a specific macro.
	 * @param macroName Empty string for all macros or the name of a macro
	 * @return
	 */
	public boolean delete (String macroName, User user) {
	
		synchronized (macros) {
			macros.remove(macroName);
		}
		return this.saveMacroFile();
	}
	
	public Element buildListElement (String macroName,boolean showHidden) {
		LinkedList macro = (LinkedList)macros.get(macroName);
		if (macro == null) return null;
		
		Element macroDef = new Element ("CONTROL");
		macroDef.setAttribute("KEY", "MACRO");
		macroDef.setAttribute("COMMAND","getList");
		macroDef.setAttribute("EXTRA",macroName);
		String type = (String)this.macros_type.get(macroName);
		if (type == null ) type = "";
		macroDef.setAttribute("TYPE",type);
		String status = (String)this.macros_status.get(macroName);
		if (status == null ) status = "";
		if (!showHidden && status.indexOf("isHidden") >= 0) return null;
		macroDef.setAttribute("STATUS",status);
		if (this.runningMacros.containsKey(macroName)) {
			macroDef.setAttribute("RUNNING","1");		    
		} else {
			macroDef.setAttribute("RUNNING","0");		    		    
		}

		Iterator eachElementList = macro.iterator();
		while (eachElementList.hasNext()) {
			ClientCommand macroElement = (ClientCommand)eachElementList.next();
			Element macroXML = macroElement.getXMLCommand();
			macroDef.addContent(macroXML);
		}
		return macroDef;
	}
	
	public void put (String name, Element macroElement) {
		LinkedList macro = parseElement (macroElement);
		if (macro != null) {
			synchronized (macros) {
				macros.put (name,macro);
			}
			synchronized (macros_type) {
				macros_type.put (name,macroElement.getAttributeValue("TYPE"));
			}
			synchronized (macros_status) {
				macros_status.put (name,macroElement.getAttributeValue("STATUS"));
			}
		}
		this.saveMacroFile();
	}
	
	public LinkedList parseElement (Element element) {
		LinkedList newMacro = new LinkedList ();
		List macroCommands = element.getChildren();
		Iterator macroCommandList = macroCommands.iterator();
		while (macroCommandList.hasNext()) {
			Element macroElement = (Element)macroCommandList.next();
			ClientCommand macroElementCommand = new ClientCommand ();
			macroElementCommand.setFromElement(macroElement);
			if (macroElementCommand != null)newMacro.add(macroElementCommand);
		}
		return newMacro;
	}

	
	public void setFileName (String fileName){
		this.fileName = "datafiles" + File.separator + fileName;
	}
	
	public void setCalendarFileName (String fileName){
		this.calendarFileName = fileName;
	}

	public boolean readCalendarFile() {
		eventCalendar.setCalendar_message_params(calendar_message_params) ;
		return eventCalendar.readCalendarFile();
	}
	
	public boolean readMacroFile()  {
		this.clearAll();
		SAXBuilder builder = null;
		Element macrosElement;
		
		builder = new SAXBuilder();
		Document doc;
		
		try {
			doc = builder.build(fileName+".xml");
			macrosElement = doc.getRootElement();
			List macroList = macrosElement.getChildren();
			Iterator eachMacro = macroList.iterator();
			while (eachMacro.hasNext()){
				Element macro = (Element)eachMacro.next();
				LinkedList macroCommands = parseElement (macro);
				String macroName = macro.getAttributeValue("EXTRA");
				if (macroName == null) macroName = "";
				String macroType = macro.getAttributeValue("TYPE");
				if (macroType == null)macroType = "";
				String status = macro.getAttributeValue("STATUS");
				if (status == null) status = "";
				macros.put(macroName, macroCommands);
				macros_status.put(macroName, status);
				macros_type.put(macroName, macroType);
			}
			
		} catch (JDOMException e) {
			logger.log(Level.WARNING,"Error in macro file "+ e.getLocalizedMessage());
			return false;
		} catch (IOException e) {
			logger.log(Level.WARNING,"IO error in reading file "+ e.getLocalizedMessage());
			return false;
		}
		logger.log (Level.FINE,"Successfully read macro file " + fileName+".xml");
		return true;
	}

	public boolean saveMacroList (Element theList) {
		try	 {
		    
					XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
					File outputFile = new File (fileName+".new");
					FileWriter out = new FileWriter(outputFile);
					xmlOut.output(theList, out) ;
					out.flush();
					out.close();
					logger.log (Level.INFO,"Macro write succeeded.");
					
					File oldFile = new File (fileName+".xml");
					File newName = new File (fileName+".old");
					
					if (oldFile.exists()) {
					    if (newName.exists() && !newName.delete()) {
						    logger.log (Level.SEVERE, "Could not delete old backup macro file "+oldFile.getName());
						    return false;
					    }
						if (!oldFile.renameTo (newName)) { 
						    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
						    return false;
						}
					}

					if (!outputFile.renameTo(oldFile)) {
					    logger.log (Level.SEVERE, "Could not rename new file "+outputFile.getName()+" to " + oldFile.getName());
					    return false;
					} else {
						return true;
					}
					    
				}
				catch (IOException ex)
				{
					logger.log (Level.FINER, "IO error saving macro file " + ex.getMessage());
					return false;
				}
	}
	
	public boolean saveMacroFile() {
		Element theList = this.get("",true);
		return saveMacroList (theList);
	}

    /**
     * @return Returns the eventCalendar.
     */
    public EventCalendar getEventCalendar() {
        return eventCalendar;
    }
    
	public void startCalendar (User user, List commandQueue) throws SchedulerException {
		eventCalendar = new EventCalendar (this,user);
		eventCalendar.setFileName(this.calendarFileName);
		eventCalendar.setCommandList(commandQueue);
		/* if (!eventCalendar.readCalendarFile() && logger!= null) {
			logger.log (Level.SEVERE,"Could not read calendar file");
		} */
	}
	
    public void abortAll() {
	    RunMacro theMacro;
	    Iterator eachMacro = runningMacros.keySet().iterator();
	    while (eachMacro.hasNext()) {
	        String macroName = (String)eachMacro.next();
	        logger.log (Level.FINE,"Aborting macro "+ macroName);
		    synchronized (runningMacros) {
		        theMacro = (RunMacro)runningMacros.get(macroName);
		    }
		    if (theMacro != null) {
		        theMacro.setAbort(true);
		    }
	    }
    }

    public Map getCalendar_message_params() {
		return calendar_message_params;
	}

	public void setCalendar_message_params(Map calendar_message_params) {
		this.calendar_message_params = calendar_message_params;
	}

	public List getCommandList() {
		return commandList;
	}
}
