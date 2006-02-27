package au.com.BI.M1.Commands;

public class ReplyWithBypassedZoneState extends M1Command {
	
	private String zone;
	private ZoneBypassState bypassState;

	public ReplyWithBypassedZoneState() {
		super();
		this.setCommand("ZB");
		// TODO Auto-generated constructor stub
	}

	public ReplyWithBypassedZoneState(String sum, String use) {
		super(sum, use);
		this.setCommand("ZB");
		// TODO Auto-generated constructor stub
	}

	public ZoneBypassState getBypassState() {
		return bypassState;
	}

	public void setBypassState(ZoneBypassState bypassState) {
		this.bypassState = bypassState;
	}

	public String getZone() {
		return zone;
	}

	public void setZone(String zone) {
		this.zone = zone;
	}

}
