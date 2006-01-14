package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ArmUpState extends Type {
	
	public static final ArmUpState NOT_READY_TO_ARM = new ArmUpState("0","Not Ready To Arm");
	public static final ArmUpState READY_TO_ARM = new ArmUpState("1","Ready To Arm");
	public static final ArmUpState READY_TO_ARM_ZONE_VIOLATION = new ArmUpState("2","Ready to Arm, but a zone is violated and can be Force Armed");
	public static final ArmUpState ARMED_WITH_EXIT_TIMER = new ArmUpState("3","Armed with Exit Timer working");
	public static final ArmUpState ARMED_FULLY = new ArmUpState("4","Armed Fully");
	public static final ArmUpState FORCE_ARMED = new ArmUpState("5","Force Armed with a force arm zone violation");
	public static final ArmUpState ARMED_WITH_BYPASS = new ArmUpState("6","Armed with a bypass");
	
	private ArmUpState(String value, String desc) {
		super(value, desc);
		// TODO Auto-generated constructor stub
	}
	
	public static ArmUpState getByValue(String value) {
		return((ArmUpState)ArmUpState.getByValue(ArmUpState.class,value));
	}
}
