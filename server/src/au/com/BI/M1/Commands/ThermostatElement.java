package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ThermostatElement extends Type {

	public static final ThermostatElement MODE = new ThermostatElement("0","MODE");
	public static final ThermostatElement HOLD = new ThermostatElement("1","HOLD");
	public static final ThermostatElement FAN = new ThermostatElement("2","FAN");
	public static final ThermostatElement COOLSETPOINT = new ThermostatElement("4","COOLSETPOINT");
	public static final ThermostatElement HEATSETPOINT = new ThermostatElement("5","HEATSETPOINT");
	
	private ThermostatElement(String value, String desc) {
		super(value, desc);
	}
	
	public static ThermostatElement getByValue(String value) {
		return((ThermostatElement)ThermostatElement.getByValue(ThermostatElement.class,value));
	}
	
	public static ThermostatElement getByDescription(String description) {
		return((ThermostatElement)ThermostatElement.getByDescription(ThermostatElement.class, description));
	}
}
