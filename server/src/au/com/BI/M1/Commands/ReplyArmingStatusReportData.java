package au.com.BI.M1.Commands;

public class ReplyArmingStatusReportData extends M1Command {
	
	private ArmedStatus[] armedStatus;
	private ArmUpState[] armUpState;
	private AreaAlarmState[] areaAlarmState;

	public ReplyArmingStatusReportData() {
		super();
		// TODO Auto-generated constructor stub
	}

	public ReplyArmingStatusReportData(String sum, String use) {
		super(sum, use);
		// TODO Auto-generated constructor stub
	}

	public AreaAlarmState[] getAreaAlarmState() {
		return areaAlarmState;
	}

	public void setAreaAlarmState(AreaAlarmState[] areaAlarmState) {
		this.areaAlarmState = areaAlarmState;
	}

	public ArmedStatus[] getArmedStatus() {
		return armedStatus;
	}

	public void setArmedStatus(ArmedStatus[] armedStatus) {
		this.armedStatus = armedStatus;
	}

	public ArmUpState[] getArmUpState() {
		return armUpState;
	}

	public void setArmUpState(ArmUpState[] armUpState) {
		this.armUpState = armUpState;
	}
	
	

}
