/*
 * Created on Jul 12, 2004
 *
 */
package au.com.BI.Util;
import java.util.*;

import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Device.UnknownFieldException;


/**
 * @author Colin Canfield
 *
 **/
public class BaseDevice {
	protected String name ="";
	protected String outputKey ="";
	protected int deviceType;
	protected String command="";
	protected String key="";
	protected String groupName;
	protected Map rawCodes;
	protected Map <String, String>extraAttributes;

	public BaseDevice () {
		extraAttributes = new HashMap<String,String>();

	}

	public BaseDevice (String name, int deviceType){
		this.name = name;
		this.deviceType = deviceType;
		this.command = "";
		this.outputKey = "";
	}

	public BaseDevice (String name, int deviceType,String outputKey){
		this.name = name;
		this.deviceType = deviceType;
		this.command = "";
		this.outputKey = outputKey;
	}

	public  int getDeviceType () {
		return deviceType;
	}

	public final String getName () {
		return name;
	}

	public String getCommand () {
		return command;
	}
	/**
	 * @return Returns the outputKey.
	 */
	public final String getOutputKey()
	{
		return outputKey;
	}

	/**
	 * @param outputKey The outputKey to set.
	 */
	public final void setOutputKey(String outputKey)
	{
		this.outputKey = outputKey;
	}


	/**
	 * @param command The command to set.
	 */
	public final void setCommand(String command)
	{
		this.command = command;
	}


	/**
	 * @param deviceType The deviceType to set.
	 */
	public final void setDeviceType(int deviceType)
	{
		this.deviceType = deviceType;
	}

	/**
	 * @param name The name to set.
	 */
	public final void setName(String name)
	{
		this.name = name;
	}

	/**
	 * @return Returns the key.
	 */
	public String getKey() {
		return key;
	}
	/**
	 * @param key The key to set.
	 */
	public void setKey(String key) {
		this.key = key;
	}
	/**
	 * @return Returns the rawCodes.
	 */
	public final Map getRawCodes() {
		return rawCodes;
	}
	/**
	 * @param rawCodes The rawCodes to set.
	 */
	public final void setRawCodes(Map rawCodes) {
		this.rawCodes = rawCodes;
	}
	/**
	 * Builds a display command
	 * @return The command
	 * @see Command
	 */
	/**
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		Command command = new Command ();
		command.setDisplayName(getOutputKey());
		return command;
	}

	/**
	 * @return Returns the groupName.
	 */
	public String getGroupName() {
		return groupName;
	}
	/**
	 * @param groupName The groupName to set.
	 */
	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	public void setAttributeValue (String name, String value) {
		extraAttributes.put (name,value);
	}
	
	public String getAttributeValue (String name) throws UnknownFieldException {
		if (extraAttributes.containsKey(name)){
			return extraAttributes.get (name);
		} else {
			throw new UnknownFieldException ("Unknown field requested " + name);
		}
	}
	
	public void clearAttributeValues (){
		extraAttributes.clear();
	}
	
}
