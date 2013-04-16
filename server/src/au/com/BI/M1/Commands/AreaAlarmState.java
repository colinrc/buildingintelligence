package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class AreaAlarmState extends Type {

	// Alarms 3-B are full alarm states
	public static final AreaAlarmState NO_ALARM_ACTIVE = new AreaAlarmState("0","No Alarm Active");
	public static final AreaAlarmState ENTRANCE_DELAY_ACTIVE = new AreaAlarmState("1","Entrance Delay is Active");
	public static final AreaAlarmState ALARM_ABORT_DELAY_ACTIVE = new AreaAlarmState("2","Alarm Abort Delay Active");
	public static final AreaAlarmState FIRE_ALARM = new AreaAlarmState("3","Fire Alarm");
	public static final AreaAlarmState MEDICAL_ALARM = new AreaAlarmState("4","Medical Alarm");
	public static final AreaAlarmState POLICE_ALARM = new AreaAlarmState("5","Police Alarm");
	public static final AreaAlarmState BURGLAR_ALARM = new AreaAlarmState("6","Burglar Alarm");
	public static final AreaAlarmState AUX1_ALARM = new AreaAlarmState("7","Aux1Alarm");
	public static final AreaAlarmState AUX2_ALARM = new AreaAlarmState("8","Aux2Alarm");
	public static final AreaAlarmState AUX3_ALARM = new AreaAlarmState("9","Aux3Alarm");
	public static final AreaAlarmState AUX4_ALARM = new AreaAlarmState(":","Aux4Alarm");
	public static final AreaAlarmState CARBON_MONOXIDE_ALARM = new AreaAlarmState(";","Carbon Monoxide Alarm");
	public static final AreaAlarmState EMERGENCY_ALARM = new AreaAlarmState("<","Emergency Alarm");
	public static final AreaAlarmState FREEZE_ALARM = new AreaAlarmState("=","Freeze Alarm");
	public static final AreaAlarmState GAS_ALARM = new AreaAlarmState(">","Gas Alarm");
	public static final AreaAlarmState HEAT_ALARM = new AreaAlarmState("?","Heat Alarm");
	public static final AreaAlarmState WATER_ALARM = new AreaAlarmState("@","Water Alarm");
	public static final AreaAlarmState FIRE_SUPERVISORY_ALARM = new AreaAlarmState("A","Fire Supervisory Alarm");
	public static final AreaAlarmState VERIFY_FIRE_ALARM = new AreaAlarmState("B","Verify Fire Alarm");
	
	private AreaAlarmState(String value, String desc) {
		super(value, desc);

	}

	public static AreaAlarmState getByValue(String value) {
		return((AreaAlarmState)AreaAlarmState.getByValue(AreaAlarmState.class,value));
	}
}
