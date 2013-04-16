package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ThermostatMode extends Type {

	public static final ThermostatMode OFF = new ThermostatMode("0","OFF");
	public static final ThermostatMode HEAT = new ThermostatMode("1","HEAT");
	public static final ThermostatMode COOL = new ThermostatMode("2","COOL");
	public static final ThermostatMode AUTO = new ThermostatMode("3","AUTO");
	public static final ThermostatMode EMERGENCY_HEAT = new ThermostatMode("4","EMERGENCY_HEAT");
	
	private ThermostatMode(String value, String desc) {
		super(value, desc);
	}
	
	public static ThermostatMode getByValue(String value) {
		return((ThermostatMode)ThermostatMode.getByValue(ThermostatMode.class,value));
	}
	
	public static ThermostatMode getByDescription(String description) {
		return((ThermostatMode)ThermostatMode.getByDescription(ThermostatMode.class,description));
	}
}
