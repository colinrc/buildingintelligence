/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Script;
import au.com.BI.Command.*;
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

	public Script (){
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

	public int getClientCommand ()
	{
		return DeviceType.NA;
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
     * @return Returns the extra.
     */
    public String getExtra() {
        return extra;
    }
    /**
     * @param extra The extra to set.
     */
    public void setExtra(String extra) {
        this.extra = extra;
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
}
