package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ReplyThermostatData extends M1Command {
	
	private String thermostat;
	private ThermostatMode mode;
	private boolean hold;
	private String holdString;
	private ThermostatFan fan;
	private String currentTemperature;
	private String heatSetPoint;
	private String coolSetPoint;
	private String currentHumidity;
	
	public ReplyThermostatData() {
		super();
		this.setCommand("TR");
		// TODO Auto-generated constructor stub
	}

	public ReplyThermostatData(String sum, String use) {
		super(sum, use);
		this.setCommand("TR");
		// TODO Auto-generated constructor stub
	}

	public String getCurrentTemperature() {
		return currentTemperature;
	}

	public void setCurrentTemperature(String currentTemperature) {
		this.currentTemperature = currentTemperature;
	}

	public ThermostatFan getFan() {
		return fan;
	}

	public void setFan(ThermostatFan fan) {
		this.fan = fan;
	}

	public boolean isHold() {
		return hold;
	}

	public void setHold(boolean hold) {
		this.hold = hold;
		if (hold) {
			holdString = "1";
		} else {
			holdString = "0";
		}
	}

	public ThermostatMode getMode() {
		return mode;
	}

	public void setMode(ThermostatMode mode) {
		this.mode = mode;
	}

	public String getThermostat() {
		return thermostat;
	}

	public void setThermostat(String thermostat) {
		this.thermostat = thermostat;
	}

	public String getCoolSetPoint() {
		return coolSetPoint;
	}

	public void setCoolSetPoint(String coolSetPoint) {
		this.coolSetPoint = coolSetPoint;
	}

	public String getCurrentHumidity() {
		return currentHumidity;
	}

	public void setCurrentHumidity(String currentHumidity) {
		this.currentHumidity = currentHumidity;
	}

	public String getHeatSetPoint() {
		return heatSetPoint;
	}

	public void setHeatSetPoint(String heatSetPoint) {
		this.heatSetPoint = heatSetPoint;
	}

	public String getHoldString() {
		return holdString;
	}

	public void setHoldString(String hold) {
		this.holdString = hold;
		if (holdString.equals("1")) {
			this.hold = true;
		} else {
			this.hold = false;
		}
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("TR" +
				Utility.padString(thermostat,2) +
				Utility.padString(mode.getValue(),1) +
				holdString + 
				Utility.padString(fan.getValue(),1) +
				Utility.padString(currentTemperature,2) +
				Utility.padString(heatSetPoint,2) +
				Utility.padString(coolSetPoint,2) +
				Utility.padString(currentHumidity,2) +
				"00");
		return returnString;
	}
}
