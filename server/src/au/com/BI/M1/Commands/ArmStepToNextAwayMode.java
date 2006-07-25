package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ArmStepToNextAwayMode extends ArmAndDisarmMessage {

	public ArmStepToNextAwayMode() {
		super();
		// TODO Auto-generated constructor stub
	}

	public ArmStepToNextAwayMode(String level, String partition, String code) {
		super(level, partition, code);
		// TODO Auto-generated constructor stub
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("a7"+this.getPartition()+Utility.padString(this.getUserCode(),6)+"00");
		return returnString;
	}

}
