package au.com.BI.M1.Commands;

public class ZonePartitionRequest extends M1Command {

	public ZonePartitionRequest() {
		super();
		this.setCommand("zp");
		// TODO Auto-generated constructor stub
	}

	public ZonePartitionRequest(String sum, String use) {
		super(sum, use);
		this.setCommand("zp");
		// TODO Auto-generated constructor stub
	}

}
