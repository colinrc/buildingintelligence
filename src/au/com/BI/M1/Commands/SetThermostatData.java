package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class SetThermostatData extends M1Command {
	private String thermostat;
	private String value;
	private ThermostatElement element;

	public SetThermostatData() {
		super();
		this.setCommand("ts");

	}

	public SetThermostatData(String sum, String use) {
		super(sum, use);
		this.setCommand("ts");

	}
	
	public ThermostatElement getElement() {
		return element;
	}

	public void setElement(ThermostatElement element) {
		this.element = element;
	}

	public String getThermostat() {
		return thermostat;
	}

	public void setThermostat(String thermostat) {
		this.thermostat = thermostat;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("ts" +
				Utility.padString(thermostat,2) +
				Utility.padString(value,2) +
				Utility.padString(element.getValue(),1) +
				"00");
		return returnString;
	}
}
