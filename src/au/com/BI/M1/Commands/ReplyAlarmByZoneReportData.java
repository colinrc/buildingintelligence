package au.com.BI.M1.Commands;

public class ReplyAlarmByZoneReportData extends M1Command {
	
	private ZoneDefinition[] zoneDefinition;

	public ReplyAlarmByZoneReportData() {
		super();
		this.setCommand("AZ");

	}

	public ReplyAlarmByZoneReportData(String sum, String use) {
		super(sum, use);
		this.setCommand("AZ");

	}

	public ZoneDefinition[] getZoneDefinition() {
		return zoneDefinition;
	}

	public void setZoneDefinition(ZoneDefinition[] zoneDefinition) {
		this.zoneDefinition = zoneDefinition;
	}

}
