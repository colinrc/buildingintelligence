package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ArmToStayInstant extends ArmAndDisarmMessage {

	public ArmToStayInstant(String level, String partition, String code) {
		super(level, partition, code);

	}

	public ArmToStayInstant() {
		super();

	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("a3"+this.getPartition()+Utility.padString(this.getUserCode(),6)+"00");
		return returnString;
	}
}
