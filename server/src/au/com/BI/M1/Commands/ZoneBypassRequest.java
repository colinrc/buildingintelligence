package au.com.BI.M1.Commands;

public class ZoneBypassRequest extends M1Command {
	
	private String zone;
	private boolean bypassAllZones;
	private boolean bypassAllViolatedZones;
	private String area;
	private String pinCode;

	public ZoneBypassRequest() {
		super();
		bypassAllZones = false;
		bypassAllViolatedZones = false;
		this.setCommand("zb");
		// TODO Auto-generated constructor stub
	}

	public ZoneBypassRequest(String sum, String use) {
		super(sum, use);
		this.setCommand("zb");
		bypassAllZones = false;
		bypassAllViolatedZones = false;
		// TODO Auto-generated constructor stub
	}

	public String getArea() {
		return area;
	}

	public void setArea(String area) {
		this.area = area;
	}

	public boolean isBypassAllViolatedZones() {
		return bypassAllViolatedZones;
	}

	public void setBypassAllViolatedZones(boolean bypassAllViolatedZones) {
		this.bypassAllViolatedZones = bypassAllViolatedZones;
	}

	public boolean isBypassAllZones() {
		return bypassAllZones;
	}

	public void setBypassAllZones(boolean bypassAllZones) {
		this.bypassAllZones = bypassAllZones;
	}

	public String getPinCode() {
		return pinCode;
	}

	public void setPinCode(String pinCode) {
		this.pinCode = pinCode;
	}

	public String getZone() {
		return zone;
	}

	public void setZone(String zone) {
		this.zone = zone;
	}
	
	

}
