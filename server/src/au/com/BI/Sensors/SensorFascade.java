/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Sensors;
import au.com.BI.Util.*;
import au.com.BI.CBUS.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;

import java.util.*;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 * @see au.com.BI.Util.DeviceType;
 *
*/
public class SensorFascade implements  DeviceType,CBUSDevice {
	protected Sensor sensor;
	protected String deviceName;

	
	public SensorFascade (String name, String channel, String units, int deviceType, String deviceName){
		if (deviceName == null)
			this.deviceName = "";
		else
			this.deviceName = deviceName;
		
		sensor = new Sensor(name,channel, units, deviceType);
		
		if (deviceType == DeviceType.SENSOR ) {
			sensor.setMax (255);
		}
	}

	public int getClientCommand() {
		return DeviceType.NA;
	}
	
	public SensorFascade (String name, String channel, String units, int deviceType, String outputKey, String deviceName){

		this (name, channel, units, deviceType,deviceName);
		sensor.setOutputKey(outputKey);
		if (deviceType == DeviceType.SENSOR ) {
			sensor.setMax (255);
		}
	}
	
	public SensorFascade (String name, String channel, String units, String group, int deviceType, String deviceName){
		if (deviceName == null)
			this.deviceName = "";
		else
			this.deviceName = deviceName;
		
		sensor = new Sensor(name,channel, units, deviceType, group);
		
		if (deviceType == DeviceType.SENSOR ) {
			sensor.setMax (255);
		}
	}

	public SensorFascade (String name, String channel, String units, String group, int deviceType, String outputKey, String deviceName){

		this (name, channel, units, group, deviceType,deviceName);
		sensor.setOutputKey(outputKey);
		if (deviceType == DeviceType.SENSOR ) {
			sensor.setMax (255);
		}
	}
	
	

	public String getRelay() {
		return sensor.getRelay();
	}

	public void setRelay(String relay) {
		sensor.setRelay(relay);
	}

	public boolean isAreaDevice () {
		return false;
	}

	public void setAreaDevice (boolean flag) {
	}

	public boolean supportsLevelMMI() {
		return false;
	}
	
	public boolean keepStateForStartup () {
		return false;
	}
	/**
	 * @return Returns the rawCodes.
	 */
	public final Map getRawCodes() {
		return sensor.getRawCodes();
	}
	/**
	 * @param rawCodes The rawCodes to set.
	 */
	public final void setRawCodes(Map rawCodes) {
		sensor.setRawCodes (rawCodes);
	}	
	public void setKey (String originalKey) {
		sensor.setKey (originalKey);
	}
	public String getKey (){
		return sensor.getKey();
	}


	public int getDeviceType () {
		return sensor.getDeviceType();
	}

	/**
	 * Builds a display command
	 * @return The command
	 * @see SensorCommand
	 */
	public CommandInterface buildDisplayCommand () {
		return sensor.buildDisplayCommand ();
	}
	
	public final String getName () {
		return sensor.getName();
	}
	
	public String getCommand (){
		return sensor.getCommand();
	}
	

	/**
	 * @return Returns the outputKey.
	 */
	public final String getOutputKey()
	{
		return sensor.getOutputKey();
	}

	/**
	 * @param outputKey The outputKey to set.
	 */
	public final void setOutputKey(String outputKey)
	{
		sensor.setOutputKey(outputKey);
	}


	/**
	 * @return Returns the outputKey.
	 */
	public final String getUnits()
	{
		return sensor.getUnits();
	}

	/**
	 * @param outputKey The outputKey to set.
	 */
	public final void setUnits(String units)
	{
		sensor.setOutputKey(units);
	}
	
	/**
	 * @return Returns the outputKey.
	 */
	public final String getChannel()
	{
		return sensor.getChannel();
	}

	/**
	 * @param outputKey The outputKey to set.
	 */
	public final void setChannel(String channel)
	{
		sensor.setChannel(channel);
	}

	/**
	 * @param command The command to set.
	 */
	public final void setCommand(String command)
	{
		sensor.setCommand(command);
	}

	/**
	 * @param deviceType The deviceType to set.
	 */
	public final void setDeviceType(int deviceType)
	{
		this.setDeviceType (deviceType);
	}

	/**
	 * @param name The name to set.
	 */
	public final void setName(String name)
	{
		this.setName(name);
	}

	
	/**
	 * @return Returns the applicationCode.
	 */
	public String getApplicationCode() {
		return "";
	}
	/**
	 * @param applicationCode The applicationCode to set.
	 */
	public void setApplicationCode(String applicationCode) {
	}
	
	/**
	 * @param max The applicationCode to set.
	 */
	public void setMax(String max) {
		int maxLevel = 100;
		if (max != null) {
			try {
				maxLevel = Integer.parseInt(max);
			} catch (NumberFormatException ex) {
				maxLevel = 100;
			}
		}
		sensor.setMax(maxLevel);
	}
	
	public void setMax (int max){
		sensor.setMax(max);
	}
	
	public int getMax () {
		return sensor.getMax();
	}

	public String getMaxStr () {
		return Integer.toString(sensor.getMax());
	}
	
	public void setGroupName (String groupName) {
		sensor.setGroupName(groupName);
	}

	public String getGroupName () {
		return sensor.getGroupName();
	}
	
	public boolean isContinueAfterMatch () {
	    return false;
	}
	
	public void setGroup(String group) {
		sensor.setGroup(group);
	}
	
	public String getGroup() {
		return sensor.getGroup();
	}
	
	public String getTemperature() {
		return sensor.getTemperature();
	}
	
	public void setTemperature(String temperature) {
		sensor.setTemperature(temperature);
	}
}
