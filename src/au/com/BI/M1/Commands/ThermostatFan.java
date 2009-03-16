package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ThermostatFan extends Type {
	
	public static final ThermostatFan FAN_AUTO = new ThermostatFan("0","AUTO");
	public static final ThermostatFan FAN_ON = new ThermostatFan("1","ON");
	
	private ThermostatFan(String value, String desc) {
		super(value, desc);
	}
	
	public static ThermostatFan getByValue(String value) {
		return((ThermostatFan)ThermostatFan.getByValue(ThermostatFan.class,value));
	}
	
	public static ThermostatFan getByDescription(String description) {
		return((ThermostatFan)ThermostatFan.getByDescription(ThermostatFan.class, description));
	}
}
