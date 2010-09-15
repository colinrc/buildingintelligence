/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Sensors;
import java.text.DecimalFormat;

import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;


/**
 * @author Colin Canfield
 *
 **/
public class Sensor extends BaseDevice implements DeviceType
{
	
	private String channel = "";
	private String group = "";
	protected int max;
	protected int zones;
	protected String applicationCode = "38";
	
	protected String units = "";
	protected double scale = 1.0;
	protected double offset = 0.0;
	
	protected boolean relay = false;
	protected String level;

	public Sensor (String name, String channel, String units, int deviceType){
		this.name = name;
		this.deviceType = deviceType;
		this.command = "";
		this.outputKey = "";
		this.channel = channel;
		this.units = units;
	}
	
	public Sensor (String name, String channel, String units, int deviceType, String group) {
		this.name = name;
		this.deviceType = deviceType;
		this.command = "";
		this.outputKey = "";
		this.channel = channel;
		this.units = units;
		this.group = group;
	}

	/**
	 * Returns a display command represented by the sensor object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		SensorCommand sensorCommand = new SensorCommand ();
		sensorCommand.setDisplayName(getOutputKey());
		return sensorCommand;
	}

	/**
	 * @return Returns the max.
	 */
	public int getMax() {
		return max;
	}
	/**
	 * @param max The max to set.
	 */
	public void setMax(int max) {
		this.max = max;
	}

	/**
	 * @return Returns the zone.
	 */
	public int getZones() {
		return zones;
	}
	/**
	 * @param max The max to set.
	 */
	public void setZones(int zones) {
		this.zones = zones;
	}

	/**
	 * @return Returns the channel.
	 */
	public String getChannel() {
		return channel;
	}
	/**
	 * @param channel The channel to set.
	 */
	public void setChannel(String channel) {
		this.channel = channel;
	}
	/**
	 * @return Returns the applicationCode.
	 */
	public String getApplicationCode() {
		return applicationCode;
	}
	/**
	 * @param applicationCode The applicationCode to set.
	 */
	public void setApplicationCode(String applicationCode) {
		this.applicationCode = applicationCode;
	}
	/**
	 * @return Returns the units.
	 */
	public String getUnits() {
		return units;
	}
	/**
	 * @param units The units to set.
	 */
	public void setUnits(String units) {
		this.units = units;
	}
	/**
	 * get the unit value offset
	 * @return double offset value to apply
	 */
	public double getOffset() {
		return offset;
	}
	/**
	 * Set the unit offset value
	 * @param offset the value to set the offset
	 */
	public void setOffset(double offset) {
		this.offset = offset;
	}
	/**
	 * get the unit scale value
	 * @return double scale value to apply
	 */
	public double getScale() {
		return scale;
	}
	/**
	 * Set the scale value
	 * @param scale the scale value to set
	 */
	public void setScale(double scale) {
		this.scale = scale;
	}
	
	public String getGroup() {
		return group;
	}

	public void setGroup(String group) {
		this.group = group;
	}

	public String getLevel() {
		return level;
	}

	public void setLevel(String level) {
		this.level = level;
	}
	public String getFormattedLevel() {
		String retVal = "";
		try {
			double level = Integer.parseInt(this.level);
			level = level*scale + offset;
			DecimalFormat onePlace = new DecimalFormat("0.0");
			retVal = onePlace.format(level) + " " + units;
		}
		catch (NumberFormatException ex) {}
		return retVal;
	}
	public double getAdjustedLevel() {
		double retVal = 0.0;
		try {
			retVal = Integer.parseInt(this.level);
			retVal = retVal*scale + offset;
		}
		catch (NumberFormatException ex) {}
		return retVal;
	}
	public void setRelay(boolean relay) {
		this.relay = relay;
	}
	
	public boolean isRelay() {
		return relay;
	}
	
	public boolean keepStateForStartup() {
		return false;
	}
}
