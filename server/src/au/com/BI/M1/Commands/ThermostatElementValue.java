package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ThermostatElementValue extends Type {
	
	public static final ThermostatElementValue OFF = new ThermostatElementValue("00","OFF");
	public static final ThermostatElementValue HEAT = new ThermostatElementValue("01","HEAT");
	public static final ThermostatElementValue COOL = new ThermostatElementValue("02","COOL");
	public static final ThermostatElementValue AUTO = new ThermostatElementValue("03","AUTO");
	public static final ThermostatElementValue EMERGENCY_HEAT = new ThermostatElementValue("00","EMERGENCY_HEAT");
	public static final ThermostatElementValue FALSE = new ThermostatElementValue("00","FALSE");
	public static final ThermostatElementValue TRUE = new ThermostatElementValue("01","TRUE");
	public static final ThermostatElementValue FAN_AUTO = new ThermostatElementValue("00","FAN_AUTO");
	public static final ThermostatElementValue FAN_TURNED_ON = new ThermostatElementValue("01","FAN_TURNED_ON");
	
	private ThermostatElementValue(String value, String desc) {
		super(value, desc);
	}
	
	public static ThermostatElementValue getByValue(String value) {
		return((ThermostatElementValue)ThermostatElementValue.getByValue(ThermostatElementValue.class,value));
	}
	
	public static ThermostatElementValue getByDescription(String description) {
		return((ThermostatElementValue)ThermostatElementValue.getByDescription(ThermostatElementValue.class, description));
	}
}
