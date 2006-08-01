package au.com.BI.M1.Commands;

public class ReplyAlarmByZoneReportData extends M1Command {
	
	private ZoneDefinition[] zoneDefinition;

	public ReplyAlarmByZoneReportData() {
		super();
		this.setCommand("AZ");
		// TODO Auto-generated constructor stub
	}

	public ReplyAlarmByZoneReportData(String sum, String use) {
		super(sum, use);
		this.setCommand("AZ");
		// TODO Auto-generated constructor stub
	}

	public ZoneDefinition[] getZoneDefinition() {
		return zoneDefinition;
	}

	public void setZoneDefinition(ZoneDefinition[] zoneDefinition) {
		this.zoneDefinition = zoneDefinition;
	}

}
