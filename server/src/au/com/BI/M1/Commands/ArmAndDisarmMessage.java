package au.com.BI.M1.Commands;


public class ArmAndDisarmMessage extends M1Command {
	
	private String armingLevel;
	private String partition;
	private String userCode;

	public ArmAndDisarmMessage() {
		super();
		this.setCommand("a");

	}
	
	public ArmAndDisarmMessage(String level, String partition, String code) {
		super();

		armingLevel = level;
		this.partition = partition;
		userCode = code;
		this.setCommand("a");
	}

	public String getArmingLevel() {
		return armingLevel;
	}

	public void setArmingLevel(String armingLevel) {
		this.armingLevel = armingLevel;
	}

	public String getPartition() {
		return partition;
	}

	public void setPartition(String partition) {
		this.partition = partition;
	}

	public String getUserCode() {
		return userCode;
	}

	public void setUserCode(String userCode) {
		this.userCode = userCode;
	}
	
	

}
