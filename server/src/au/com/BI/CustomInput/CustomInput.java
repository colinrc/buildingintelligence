/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.CustomInput;
import au.com.BI.Command.*;
import java.util.regex.*;
import au.com.BI.Util.*;
import java.util.logging.*;



/**
 * @author Colin Canfield
 *
 **/
public class CustomInput extends BaseDevice implements DeviceType
{
	protected String inKey="";
	protected String extra = null;
	protected Pattern p;
	protected boolean hasPattern = false;
	protected Logger logger;

	public CustomInput (){
	    p = Pattern.compile ("");
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public CustomInput (String name){
		super (name,DeviceType.CUSTOM_INPUT);
		this.name = name;
	}
	
	public boolean keepStateForStartup () {
		return false;
	}
	public final int getDeviceType () {
		return DeviceType.CUSTOM_INPUT;
	}
	
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}
	
	/**
	 * If a key is to be interpretted as a regex pattern; hasPattern must be set true before setKey is called
	 */
	public void setKey (String key) {
	    if (this.hasPattern) {
	    		try {
	    			p = Pattern.compile (key);
	    		} catch (java.util.regex.PatternSyntaxException ex) {
	    			logger.log (Level.WARNING,"Illegal regex specified " + ex.getMessage());
	    		}
	        this.hasPattern = true;
	    } else {
	        this.hasPattern = false;
	    }
	    super.setKey(key);
	}
	
	public Matcher getMatcher (String stringToCompare) {
       return p.matcher (stringToCompare);

	}
	
	public String getInKey (){
		return inKey;
	}
	public void setInKey (String inKey) {
		this.inKey = inKey;
	}

	/**
	 * Returns a display command represented by the custom input object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		CustomInputCommand customInputCommand = new CustomInputCommand ();
		customInputCommand.setDisplayName(this.getOutputKey());
		customInputCommand.setTargetDeviceID(0);
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
     * @return Returns the hasPatten.
     */
    public boolean isHasPattern() {
        return hasPattern;
    }
    /**
     * @param hasPattern The hasPattern to set.
     */
    public void setHasPattern(boolean hasPattern) {
        this.hasPattern = hasPattern;
    }
}
