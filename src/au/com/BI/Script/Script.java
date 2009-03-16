/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Script;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.*;



/**
 * @author Colin Canfield
 * This object is used to represent a particular instance of a script
 **/
public class Script extends BaseDevice implements DeviceType
{
  	protected String inKey="";
	protected String extra = null;
	protected String nameOfScript = "";
	public enum ScriptType {Jython,Groovy};
	protected  ScriptType scriptType =ScriptType. Jython;

	protected Map <String,List<String>> scriptsVersusCommands; // command to trigger, groovy script name
	
	public Script (){
		scriptsVersusCommands = new HashMap<String,List<String>>();
		List<String> allCommands= new LinkedList<String>();
		scriptsVersusCommands.put("*", allCommands);
	}

	public Script (String name){
		super (name,DeviceType.SCRIPT);
		this.name = name;
	}

	public boolean keepStateForStartup () {
		return false;
	}
	public final int getDeviceType () {
		return DeviceType.SCRIPT;
	}


	public String getInKey (){
		return inKey;
	}
	public void setInKey (String inKey) {
		this.inKey = inKey;
	}

	/**
	 * Returns a display command represented by the script object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		ScriptCommand customInputCommand = new ScriptCommand ();
		customInputCommand.setDisplayName(this.getOutputKey());
		return customInputCommand;
	}


    /**
     * @return Returns the nameOfScript.
     */
    public String getNameOfScript() {
        return nameOfScript;
    }
    /**
     * @param nameOfScript The nameOfScript to set.
     */
    public void setNameOfScript(String nameOfScript) {
        this.nameOfScript = nameOfScript;
    }


    
	public ScriptType getScriptType() {
		return scriptType;
	}

	public void setScriptType(ScriptType scriptType) {
		this.scriptType = scriptType;
	}

	public Map<String, List<String>> getScriptsVersusCommands() {
		return scriptsVersusCommands;
	}

	public void setScriptsVersusCommands(
			Map<String, List<String>> scriptsVersusCommands) {
		this.scriptsVersusCommands = scriptsVersusCommands;
	}
	
	public List<String> getScriptListForCommand(String command) {
		if (command.equals ("")) command = "*";

				
		if (scriptsVersusCommands.containsKey(command)){
			return scriptsVersusCommands.get(command);
		} 
		else {		
			return new LinkedList<String>();
		}	
	}
	
	public void addScriptForCommand(String command, String scriptName) {
		if (command.equals ("")) command = "*";
		List <String>scriptNames;
		
		if (scriptsVersusCommands.containsKey(command)){
			scriptNames = scriptsVersusCommands.get(command);
		} 
		else {		
			scriptNames = new LinkedList<String>();
		}
		
		scriptNames.add(scriptName);
		scriptsVersusCommands.put(command, scriptNames);

	}
}
