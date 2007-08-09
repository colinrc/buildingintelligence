/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Device;
import java.util.*;
import au.com.BI.Command.*;

/**
 * @author Colin Canfield
 * * All end controlled device must implement this interface (eg. sprinkler, light)
 **/
public interface DeviceType
{
	public enum FieldTypes {Unknown,String, Integer};
	
	public static final int NA = -1;
	public static final int UKNOWN_EVENT = -1;

	public static final int COMFORT_LIGHT_SWITCH_X10 = 1;
	public static final int TOGGLE_OUTPUT = 2;
	public static final int TOGGLE_OUTPUT_MONITOR = 5;
	public static final int LIGHT_CBUS = 6;
	public static final int COMFORT_LIGHT_X10 = 7;
	public static final int COMFORT_LIGHT_X10_UNITCODE = 8;
	public static final int TOGGLE_INPUT = 10;
	public static final int RAW_OUTPUT = 11;
	public static final int TV = 12;
	public static final int AUDIO = 13;
	public static final int LIGHT_ICON = 14;  
	public static final int PIR_ICON = 15;  
	public static final int GENERAL_SWITCH_ICON = 16;  
	public static final int LIGHT_CONTROL = 17;  
	public static final int ALERT = 18;
	public static final int DOORBELL = 19;
	public static final int RAW_INTERFACE = 20;
	public static final int CUSTOM_INPUT = 21;
	public static final int ALARM = 22;
	public static final int COUNTER = 23;
	public static final int KEY_DIRECT_TO_COMMS = 24;
	public static final int ANALOGUE = 25;
	public static final int IR = 26;
	public static final int VIRTUAL_OUTPUT = 27;
	public static final int PULSE_OUTPUT = 28;
	public static final int SCRIPT = 29;
	public static final int ADMIN = 30;
	public static final int SENSOR = 31;
	public static final int CAMERA = 32;
	public static final int AV = 33;
	
	public static final int KRAMER_SWITCH = 34;
	public static final int KRAMER_AUDIO_PARAM = 35;
	public static final int KRAMER_AUDIO = 36;
	public static final int KRAMER_PRESET = 37;
	
	public static final int LIGHT_DYNALITE = 40;
	public static final int CONTACT_CLOSURE = 41;
	public static final int TEMPERATURE = 42;

	public static final int LIGHT_DYNALITE_AREA = 43;
	
	public static final int NUVO_SWITCH = 44;
	public static final int SIGN_VIDEO_SWITCH = 45;
	public static final int GROOVY_SCRIPT = 46;
	public static final int LIGHT = 47;
	public static final int SMS = 48;
	public static final int CUSTOM_CONNECT = 49;
	
	public static final int LABEL = 50;
	
	public static final int THERMOSTAT = 51;
	
	public static final int WINDOWS_MEDIA_CENTRE = 52;
	public static final int WINDOWS_MEDIA_EXTENDER = 53;
	
	public static final int SQUEEZE_BOX = 54;
	
	public static final int PUMP = 55;
	
	public static final int UNIT = 56;
	
	// Likely number of raw commands for device line. More is allowed.
	public static final int PROBABLE_NUMBER_RAW = 10;

	public static final int NOT_CONTROLLED = 0;
	
	/**
	 * The command is the original raw form sent to the device
	 * @return The raw command
	 */
	public String getCommand ();
	
	/**
	 * Device types map the sort of hardware in use
	 * @return The hardware type
	 */
	public int getDeviceType ();
	
	/**
	 * The Name used to refer to the device instance in the configuration
	 * @return The name
	 */
	public String getName ();

	/**
	 * The original key from the config file is sometimes useful to know.
	 * @param originalKey
	 */
	public void setKey (String originalKey);
	public String getKey ();
	

	/**
	 * @return Returns the rawCodes.
	 */
	public Map getRawCodes();
		/**
		 * @param rawCodes The rawCodes to set.
		 */
	public void setRawCodes(Map rawCodes);
	
	/**
	 * Returns true if this device type cannot be actively queried for state. 
	 * Hence the system must keep it.
	 * @return true / false
	 */
	public boolean keepStateForStartup ();
	
	/**
	 * @return Returns the groupName.
	 */
	public String getGroupName(); 

	    /**
	 * @param groupName The groupName to set.
	 */
	public void setGroupName(String groupName);
	
	/**
	 * Returns an XML flash message representing the contents of the device
	 * @return
	 */
	public CommandInterface buildDisplayCommand();
	
	public String getOutputKey();

}
	
