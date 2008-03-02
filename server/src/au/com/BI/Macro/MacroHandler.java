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
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;

import java.util.Collections;
import au.com.BI.User.*;
import java.util.logging.*;

import org.jdom.input.*;
import org.jdom.output.XMLOutputter;

/**
 * @author colin
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class MacroHandler {
	/**
	 * 
	 */
	protected String fileName = "";
        private String integratorFileName = "";
	protected Map <String,List<ClientCommand>>macros = null;
        protected Map <String,List<ClientCommand>>integratorMacros = null;
	protected Map <String,String>macros_status = null;
	protected Logger logger;
	protected CommandQueue commandList = null;
	protected Map <String,RunMacro>runningMacros = null;
	protected Map<String,String> macros_type = null;
	protected Vector <String>macroNames = null;
        protected Vector <String>integratorMacroNames = null;
        protected Cache cache = null;
                
	public MacroHandler() {
		super();
		macroNames = new Vector<String>(DeviceModel.NUMBER_MACROS);
        integratorMacroNames = new Vector<String>(DeviceModel.NUMBER_MACROS);
                
		macros = Collections.synchronizedMap(new HashMap<String,List<ClientCommand>>(DeviceModel.NUMBER_MACROS));
		integratorMacros = Collections.synchronizedMap(new HashMap<String,List<ClientCommand>>(DeviceModel.NUMBER_MACROS));

		macros_status =  Collections.synchronizedMap(new HashMap<String,String>(DeviceModel.NUMBER_MACROS));
		macros_type = Collections.synchronizedMap(new HashMap<String,String>(DeviceModel.NUMBER_MACROS));
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		runningMacros = Collections.synchronizedMap(new HashMap<String,RunMacro>(DeviceModel.NUMBER_MACROS));
	}
	

	public void clearAll (boolean integrator) {

            if (!integrator){
                this.abortAll();
                synchronized (macroNames) {
                        macroNames.clear();
                }
                synchronized (macros) {
                        macros.clear();
                }
                synchronized (macros_status) {
                        macros_status.clear();
                }
                synchronized (runningMacros) {
                        runningMacros.clear();
                }
            } else {
                synchronized (integratorMacroNames) {
                        integratorMacroNames.clear();
                }
                synchronized (integratorMacros) {
                        integratorMacros.clear();
                }
            }
	}
	
	public String buildFullName(String macroName, String targetDisplayName) {
		if (targetDisplayName.equals("")){
			return macroName;
		} else {
			return macroName + ":" + targetDisplayName;
		}
	}

	public boolean run(String macroName, User user,CommandInterface origCommand) {
		List <ClientCommand>macro;
		boolean doNotRun = false;
		
		String realName[] = macroName.split(":");
                
		synchronized (macros) {
			macro = (List<ClientCommand>)macros.get(realName[0]);
		}
                if (macro == null){
        		synchronized (integratorMacros) {
                            macro = integratorMacros.get(realName[0]);
                    }
                    
                }
		if (macro == null) {
			logger.log (Level.WARNING,"Specified macro not found : " + macroName);
			return false;
		}
		else {

			RunMacro newMacro = new RunMacro (macro, user, macroName,origCommand);
			newMacro.setCache(cache);
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

	public void setCommandList (CommandQueue commandList){
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

	public boolean isRunning (String macroName) {
		if (runningMacros.containsKey(macroName)){
			return false;
		} else  {
			return true;
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
	public Element get (String macroName, boolean integrator, boolean fullContents) {
		Element top = new Element ("MACROS");
		boolean complete = false;
		
		if (macroName.equals ("")) {
		    top.setAttribute ("COMPLETE","Y");
		    complete = true;
		} else {
		    top.setAttribute ("COMPLETE","N");	
		    complete = false;
		}
		
                Vector <String> localMacroNames = null;
                if (integrator){
                    localMacroNames = this.integratorMacroNames;
                } else {
                    localMacroNames = this.macroNames;
                }

		if (complete) {
		    synchronized (localMacroNames) {

			for (String eachMacroName: localMacroNames) {
			    Element macroDef = null;
			    macroDef =  buildListElement (eachMacroName,integrator,fullContents);
			    try { 
				if (macroDef != null) top.addContent(macroDef);
			    } catch (NoSuchMethodError ex) {
				logger.log (Level.SEVERE,"Error calling jdom library " + ex.getMessage());
			    }
			}

		    }
		} else {
			Element macroDef =  buildListElement (macroName,integrator,fullContents);
			try { 
			    if (macroDef != null) top.addContent(macroDef);
			} catch (NoSuchMethodError ex) {
			    logger.log (Level.SEVERE,"Error calling jdom library " + ex.getMessage());
			}
		    
		}
		return top;
	}

	/**
	 * Returns the macro  as an XML element.
	 * @param macroName The macro name
	 * @return
	 */
	public Element getContents (String macroName, boolean integrator) {
            Element top = new Element ("MACRO_CONTENTS");

            Map <String,List<ClientCommand>>localMacros;
            if (integrator){
                localMacros = integratorMacros;
            } else {
                localMacros = macros;
            }

            synchronized (localMacros) {
                if (!macroName.equals ("")) {
                    Element macroDef =  buildListElement (macroName,integrator,true);
                    try { 
                        if (macroDef != null) top.addContent(macroDef);
                    } catch (NoSuchMethodError ex) {
                        logger.log (Level.SEVERE,"Error calling jdom library " + ex.getMessage());
                    }
                }
            }
            return top;
	}

	/**
	 * Returns the macro list as an XML element,or a specific macro.
	 * @param macroName Empty string for all macros or the name of a macro
	 * @return
	 */
	public boolean delete (String macroName, User user,boolean integrator) {
	
            if (integrator){
                
		synchronized (integratorMacros) {
                    integratorMacros.remove(macroName);
		}
                synchronized (integratorMacroNames){
                    integratorMacroNames.remove(macroName);
                }
            } else {
                synchronized (macros) {
			macros.remove(macroName);
		}
                synchronized (macroNames){
                    macroNames.remove(macroName);
                }
            }
            return this.saveMacroFile(integrator);
	}
	
	public Element buildListElement (String macroName,boolean integrator,boolean includeContents) {
		List <ClientCommand>macro;

                if (integrator){
                    macro = integratorMacros.get(macroName);
                } else {
                    macro = macros.get(macroName);                    
                }
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
		if (!integrator && status.indexOf("isHidden") >= 0) return null;
		macroDef.setAttribute("STATUS",status);
                
                if (this.runningMacros.containsKey(macroName)) {
                        macroDef.setAttribute("RUNNING","1");		    
                } else {
                        macroDef.setAttribute("RUNNING","0");		    		    
                }                    

                if (includeContents){
                    for (ClientCommand macroElement: macro){
                            Element macroXML = macroElement.getXMLCommand();
                            macroDef.addContent(macroXML);
                    }
                }
		return macroDef;
	}
	
	public void put (String name, Element macroElement,boolean integrator) {
            List <ClientCommand>macro = parseElement (macroElement,name);
            if (macro != null) {
                if (integrator){
                    synchronized (integratorMacros) {
                            integratorMacros.put (name,macro);
                    }
                    if (!integratorMacroNames.contains(name)) {
                        integratorMacroNames.add(name);
                    }
                } else {
                    synchronized (macros) {
                            macros.put (name,macro);
                    }
                    if (!macroNames.contains(name)) {
                        macroNames.add(name);
                    }
                }

                synchronized (macros_type) {
                        macros_type.put (name,macroElement.getAttributeValue("TYPE"));
                }
                synchronized (macros_status) {
                        macros_status.put (name,macroElement.getAttributeValue("STATUS"));
                }

            }
            this.saveMacroFile(integrator);  
	}
	
	public List <ClientCommand> parseElement (Element element, String macroName) {
		LinkedList <ClientCommand> newMacro = new LinkedList <ClientCommand>();
		List <Element>macroCommands = (List<Element>)element.getChildren();
		if (macroCommands.isEmpty()) {
			if (macros.containsKey(macroName)) {
				return macros.get(macroName);
			}
			if (integratorMacros.containsKey(macroName)) {
				return integratorMacros.get(macroName);
			}
		} 
		for (Element macroElement:macroCommands){
			ClientCommand macroElementCommand = new ClientCommand ();
			macroElementCommand.setFromElement(macroElement);
			if (macroElementCommand != null)newMacro.add(macroElementCommand);
		}
		return newMacro;
	}

	
	public void setFileName (String fileName){
		this.fileName = "datafiles" + File.separator + fileName;
	}

	
	public boolean readMacroFile(boolean integrator)  {
            String localFileName = "";
            this.clearAll(integrator);
            if (!integrator) {

                localFileName = fileName;
            }else {
                localFileName = integratorFileName;
            }
            SAXBuilder builder = null;
            Element macrosElement;

            builder = new SAXBuilder();
            Document doc;

            try {
                doc = builder.build(localFileName+".xml");
                macrosElement = doc.getRootElement();
                List <Element>macroList = macrosElement.getChildren();

                for (Element macro:macroList){
                        String macroName = macro.getAttributeValue("EXTRA");
                        if (macroName == null) macroName = "";
                        List <ClientCommand>macroCommands = parseElement (macro,macroName);
                        String macroType = macro.getAttributeValue("TYPE");
                        if (macroType == null)macroType = "";
                        String status = macro.getAttributeValue("STATUS");
                        if (status == null) status = "";
                        if (integrator){
                            integratorMacros.put(macroName, macroCommands);
                            integratorMacroNames.add(macroName);
                        } else {
                            macros.put(macroName, macroCommands);
                            macroNames.add(macroName);
                        }
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
		logger.log (Level.FINE,"Successfully read macro file " + localFileName+".xml");
		return true;
	}

 
	boolean saveMacroList (Element theList, boolean integrator) {
            String localFileName;
            List eachName = theList.getChildren();
            Iterator nameIter = eachName.iterator();
            
            if (integrator) {
                localFileName = integratorFileName;

                synchronized (integratorMacroNames){
                    integratorMacroNames.clear();
                    while (nameIter.hasNext()){
                        integratorMacroNames.add((String)nameIter.next());
                    }
                }
                
            } else {
                localFileName = fileName;
                synchronized (macroNames){
                    macroNames.clear();
                    while (nameIter.hasNext()){
                        Element eachNameEl = (Element)nameIter.next();
                        macroNames.add((String)eachNameEl.getAttributeValue("EXTRA"));
                    }
                }
            }
            
            Element newMacroList = this.get("",integrator,true);
            
            try	
            {

                XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
                File outputFile = new File (localFileName+".new");
                FileWriter out = new FileWriter(outputFile);
                xmlOut.output(newMacroList, out) ;
                out.flush();
                out.close();
                logger.log (Level.INFO,"Macro write succeeded.");

                File oldFile = new File (localFileName+".xml");
                File newName = new File (localFileName+".old");

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
	
	private boolean saveMacroFile(boolean integrator) {
		Element theList = this.get("",integrator,true);
		return saveMacroList (theList,integrator);
	}


    public void abortAll() {
	    RunMacro theMacro;
	    for (String macroName: runningMacros.keySet()){
	        logger.log (Level.FINE,"Aborting macro "+ macroName);
		    synchronized (runningMacros) {
		        theMacro = (RunMacro)runningMacros.get(macroName);
		    }
		    if (theMacro != null) {
		        theMacro.setAbort(true);
		    }
	    }
    }

	public CommandQueue getCommandList() {
		return commandList;
	}

    public String getIntegratorFileName() {
        return integratorFileName;
    }

    public void setIntegratorFileName(String integratorFileName) {
        this.integratorFileName = "datafiles" + File.separator + integratorFileName;
    }


	public Cache getCache() {
		return cache;
	}


	public void setCache(Cache cache) {
		this.cache = cache;
	}
}
