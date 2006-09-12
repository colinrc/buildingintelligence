/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Sensors;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;


/**
 * @author Colin Canfield
 *
 **/
public class Sensor extends BaseDevice
{
	
	private String channel = "";
	private String group = "";
	protected int max;
	protected String applicationCode = "38";
	protected String units = "";
	protected String relay = "N";
	protected String temperature;
	
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
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		SensorCommand lightCommand = new SensorCommand ();
		lightCommand.setDisplayName(getOutputKey());
		return lightCommand;
	}
	
	public int getDeviceType () {
		return DeviceType.SENSOR;
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


	public String getRelay() {
		return relay;
	}
	


	public void setRelay(String relay) {
		this.relay = relay;
	}

	public String getGroup() {
		return group;
	}

	public void setGroup(String group) {
		this.group = group;
	}

	public String getTemperature() {
		return temperature;
	}

	public void setTemperature(String temperature) {
		this.temperature = temperature;
	}
	
}
