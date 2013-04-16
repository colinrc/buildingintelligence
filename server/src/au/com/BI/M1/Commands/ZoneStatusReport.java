package au.com.BI.M1.Commands;

public class ZoneStatusReport extends M1Command {
	
	private ZoneStatus[] zoneStatus;

	public ZoneStatusReport() {
		super();
		this.setCommand("ZS");

	}

	public ZoneStatusReport(String sum, String use) {
		super(sum, use);
		this.setCommand("ZS");

	}

	public ZoneStatus[] getZoneStatus() {
		return zoneStatus;
	}

	public void setZoneStatus(ZoneStatus[] zoneStatus) {
		this.zoneStatus = zoneStatus;
	}

}
