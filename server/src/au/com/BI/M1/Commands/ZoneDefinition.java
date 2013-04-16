package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ZoneDefinition extends Type {
	
	public static final ZoneDefinition DISABLED = new ZoneDefinition("0","Disabled");
	public static final ZoneDefinition BURGLAR_ENTRY_EXIT_1 = new ZoneDefinition("1","Burglar Entry/Exit 1");
	public static final ZoneDefinition BURGLAR_ENTRY_EXIT_2 = new ZoneDefinition("2","Burglar Entry/Exit 2");
	public static final ZoneDefinition BURGLAR_PERIMETER_INSTANT = new ZoneDefinition("3","Burglar Perimeter Instant");
	public static final ZoneDefinition BURGLAR_INTERIOR = new ZoneDefinition("4","Burglar Interior");
	public static final ZoneDefinition BURGLAR_INTERIOR_FOLLOWER = new ZoneDefinition("5","Burglar Interior Follower");
	public static final ZoneDefinition BURGLAR_INTERIOR_NIGHT = new ZoneDefinition("6","Burglar Interior Night");
	public static final ZoneDefinition BURGLAR_INTERIOR_NIGHT_DELAY = new ZoneDefinition("7","Burglar Interior Night Delay");
	public static final ZoneDefinition BURGLAR_24_HOUR = new ZoneDefinition("8","Burglar 24 Hour");
	public static final ZoneDefinition BURGLAR_BOX_TAMPER = new ZoneDefinition("9","Burglar Box Tamper");
	public static final ZoneDefinition FIRE_ALARM = new ZoneDefinition(":","Fire Alarm");
	public static final ZoneDefinition FIRE_VERIFIED = new ZoneDefinition(";","Fire Verified");
	public static final ZoneDefinition FIRE_SUPERVISORY = new ZoneDefinition("<","Fire Supervisory");
	public static final ZoneDefinition AUX_ALARM_1 = new ZoneDefinition("=","Aux Alarm 1");
	public static final ZoneDefinition AUX_ALARM_2 = new ZoneDefinition(">","Aux Alarm 2");
	public static final ZoneDefinition KEY_FOB = new ZoneDefinition("?","Key Fob");
	public static final ZoneDefinition NON_ALARM = new ZoneDefinition("@","Non Alarm");
	public static final ZoneDefinition CARBON_MONOXIDE = new ZoneDefinition("A","Carbon Monoxide");
	public static final ZoneDefinition EMERGENCY_ALARM = new ZoneDefinition("B","Emergency Alarm");
	public static final ZoneDefinition FREEZE_ALARM = new ZoneDefinition("D","Freeze Alarm");
	public static final ZoneDefinition GAS_ALARM = new ZoneDefinition("E","Gas Alarm");
	public static final ZoneDefinition HEAT_ALARM = new ZoneDefinition("F","Heat Alarm");
	public static final ZoneDefinition MEDICAL_ALARM = new ZoneDefinition("G","Medical Alarm");
	public static final ZoneDefinition POLICE_ALARM = new ZoneDefinition("H","Police Alarm");
	public static final ZoneDefinition POLICE_NO_INDICATION = new ZoneDefinition("I","Police No Indication");
	public static final ZoneDefinition WATER_ALARM = new ZoneDefinition("J","Water Alarm");
	
	private ZoneDefinition(String value, String desc) {
		super(value, desc);

	}

	public static ZoneDefinition getByValue(String value) {
		return((ZoneDefinition)ZoneDefinition.getByValue(ZoneDefinition.class,value));
	}

}
