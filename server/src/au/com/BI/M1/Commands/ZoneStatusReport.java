package au.com.BI.M1.Commands;

public class ZoneStatusReport extends M1Command {
	
	private ZoneStatus[] zoneStatus;

	public ZoneStatusReport() {
		super();
		// TODO Auto-generated constructor stub
	}

	public ZoneStatusReport(String sum, String use) {
		super(sum, use);
		// TODO Auto-generated constructor stub
	}

	public ZoneStatus[] getZoneStatus() {
		return zoneStatus;
	}

	public void setZoneStatus(ZoneStatus[] zoneStatus) {
		this.zoneStatus = zoneStatus;
	}

}
