package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class Group extends Type {
	
	public static final Group TEMPERATURE_PROBE = new Group("0","Temperature Probe");
	public static final Group KEYPAD = new Group("1","Keypad");
	public static final Group THERMOSTATS = new Group("2","Thermostats");
	
	private Group(String value, String desc) {
		super(value, desc);
	}
	
	public static Group getByValue(String value) {
		return((Group)Group.getByValue(Group.class,value));
	}

}
