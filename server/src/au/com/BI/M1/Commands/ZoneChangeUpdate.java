package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ZoneChangeUpdate extends M1Command {
	
	private ZoneStatus zoneStatus;
	private String zone;
	private String outputState;
	
	public ZoneChangeUpdate() {
		super();
		this.setCommand("ZC");

	}

	public ZoneChangeUpdate(String sum, String use) {
		super(sum, use);

		this.setCommand("ZC");
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

	public String getOutputState() {
		return outputState;
	}

	public void setOutputState(String outputState) {
		this.outputState = outputState;
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("ZC"+Utility.padString(this.getZone(),3)+this.getZoneStatus().getValue()+"00");
		return returnString;
	}
	

}
