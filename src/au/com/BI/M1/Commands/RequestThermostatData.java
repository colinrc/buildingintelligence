package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class RequestThermostatData extends M1Command {

	private String thermostat;
	
	public RequestThermostatData() {
		super();
		super.setCommand("tr");

	}


	public RequestThermostatData(String sum, String use) {
		super(sum, use);
		super.setCommand("tr");

	}


	public String getThermostat() {
		return thermostat;
	}


	public void setThermostat(String thermostat) {
		this.thermostat = thermostat;
	}


	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("tr" + Utility.padString(thermostat,2) + "00");
		return returnString;
	}
}
