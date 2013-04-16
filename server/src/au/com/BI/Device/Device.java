/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Device;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import java.util.*;
import java.util.logging.Logger;


/**
 * @author Colin Canfield
 *
 **/
public class Device extends BaseDevice implements DeviceType
{
	protected Map <String,Object>fields = null;
	protected Map <String,FieldDetails>fieldTypes = null;
	protected String deviceName = null;
	protected Logger logger = null;
	
	protected String key;

	public Device (String name, int deviceType, String outputKey){
		super (name,deviceType,outputKey);
		logger = Logger.getLogger(this.getClass().getPackage().getName()+"."+name);
		fields = new HashMap<String,Object>();
		fieldTypes = new HashMap<String,FieldDetails>();
		this.outputKey = outputKey;
	}
	
	public boolean keepStateForStartup () {
		return false;
	}
	
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}
	
	public void addStrValue (String name , String  value,String errorMessage, int minVal, int maxVal) throws UnknownFieldException,FieldValueException {
		if (!fieldTypes.containsKey(name))
			throw new UnknownFieldException ("A value was sent for an unknown field " + name + " for the device " + deviceName);
		fields.put (name,value); 
	}
	
	public void addIntValue (String name , Object value) throws UnknownFieldException,FieldValueException {
		if (!fieldTypes.containsKey(name))
			throw new UnknownFieldException ("A value was sent for an unknown field " + name + " for the device " + deviceName);
		FieldDetails fieldDetails = fieldTypes.get(name);
		int intVal = ((Integer)value).intValue();
		if (intVal < fieldDetails.minVal || intVal > fieldDetails.maxVal){
			throw new FieldValueException  ("A incorrect value was sent to the " + name + " field for the device " + deviceName);			
		}
		fields.put (name,value); 
	}
	
	public boolean validateDevice () {
		for (FieldDetails fieldDetails: fieldTypes.values() ){
				if (!fieldDetails.optional  && !fields.containsKey(fieldDetails.name))
					return false;
		}
		return true;
	}
	
	public Object getValue(String name) throws UnknownFieldException,FieldValueException {
		if (!fieldTypes.containsKey(name))
			throw new UnknownFieldException ("A value was requested for an unknown field " + name + " for the device " + deviceName);

		return fields.get(name); 
	}

	/**
	 * Returns a display command represented by the analogue object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		Command command = new Command ();
		command.setDisplayName(this.getOutputKey());
		return command;
	}

	public String getDeviceName() {
		return deviceName;
	}

	public void setDeviceName(String deviceName) {
		this.deviceName = deviceName;
	}
}


class FieldDetails {
	String name = "";
	int maxVal = 0;
	int minVal = 0;
	boolean optional = false;
};


