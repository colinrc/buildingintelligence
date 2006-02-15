package au.com.BI.M1.Commands;

import au.com.BI.Command.Command;

public class M1Command extends Command {
	private String futureUse;
	private String checkSum;
	
	public M1Command () {
		futureUse = "";
		checkSum = "";
	}

	public M1Command(String sum, String use) {
		super();
		// TODO Auto-generated constructor stub
		checkSum = sum;
		futureUse = use;
	}

	public String getFutureUse() {
		return futureUse;
	}

	public void setFutureUse(String futureUse) {
		this.futureUse = futureUse;
	}

	public String getCheckSum() {
		return checkSum;
	}

	public void setCheckSum(String checkSum) {
		this.checkSum = checkSum;
	}
	
	public String toString() {
		return ("commandMessage=" + this.getCommandCode() + ";outputNumber=" + this.getKey() + ";futureUse=" + futureUse + ";checkSum=" + checkSum);
	}
	
}
