package au.com.BI.M1.Commands;

public class ArmingStatusRequest extends M1Command {

	public ArmingStatusRequest() {
		super();
		this.setCommand("as");
		// TODO Auto-generated constructor stub
	}

	public ArmingStatusRequest(String sum, String use) {
		super(sum, use);
		this.setCommand("as");
		// TODO Auto-generated constructor stub
	}

}
