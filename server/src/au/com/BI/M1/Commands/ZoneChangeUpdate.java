package au.com.BI.M1.Commands;

public class ZoneChangeUpdate extends M1Command {
	
	private ZoneStatus zoneStatus;
	private String zone;

	public ZoneChangeUpdate() {
		super();
		this.setKey("ZC");
		// TODO Auto-generated constructor stub
	}

	public ZoneChangeUpdate(String sum, String use) {
		super(sum, use);
		// TODO Auto-generated constructor stub
		this.setKey("ZC");
	}

	public String getZone() {
		return zone;
	}

	public void setZone(String zone) {
		this.zone = zone;
	}

	public ZoneStatus getZoneStatus() {
		return zoneStatus;
	}

	public void setZoneStatus(ZoneStatus zoneStatus) {
		this.zoneStatus = zoneStatus;
	}
}
