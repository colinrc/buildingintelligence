package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ReplyZoneAnalogVoltageData extends M1Command {
	
	private String zone;
	private String voltageData;
	private String rawVoltageData;
	private double d_voltageData = 0.0;
	
	public ReplyZoneAnalogVoltageData() {
		super();
		this.setCommand("ZV");
		// TODO Auto-generated constructor stub
	}

	public ReplyZoneAnalogVoltageData(String sum, String use) {
		super(sum, use);
		this.setCommand("ZV");
		// TODO Auto-generated constructor stub
	}
	
	public String getZone() {
		return zone;
	}

	public void setZone(String zone) {
		this.zone = zone;
	}
	
	public String getVoltageData() {
		return voltageData;
	}
	
	/**
	 * Set the voltage data. This will also set the voltageData as a double and the raw data (which is 
	 * multiplied by a factor of 10.0).
	 * @param voltageData
	 */
	public void setVoltageData(String voltageData) {
		this.voltageData = voltageData;
		d_voltageData = Double.parseDouble(rawVoltageData);
		rawVoltageData = Double.toString(d_voltageData * 10.0);
	}

	/**
	 * The raw voltage data comes in as a String. It is represented as XXX. The adjusted voltage data is 
	 * XX.X so the raw will have to be divided by 10.0 to shift the decimal place one spot to the left.
	 * This method will also adjust the String representation of the adjusted voltageData and the double
	 * representation of the data.
	 * @param rawVoltageData
	 */
	public void setRawVoltageData(String rawVoltageData) {
		this.rawVoltageData = rawVoltageData;
		d_voltageData = Double.parseDouble(rawVoltageData) / 10.0;
		this.voltageData = Double.toString(d_voltageData);
	}
	
	public String getRawVoltageData() {
		return rawVoltageData;
	}
	
	public double getVoltageDataAsDouble() {
		return d_voltageData;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("ZV" + Utility.padString(zone) + rawVoltageData + "00");
		return returnString;
	}

}
