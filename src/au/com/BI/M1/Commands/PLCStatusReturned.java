package au.com.BI.M1.Commands;

public class PLCStatusReturned extends M1Command {
	
	private String bank;
	private int[] levels = new int[64];

	public PLCStatusReturned() {
		super();
		this.setCommand("PS");
	}

	public String getBank() {
		return bank;
	}

	public void setBank(String bank) {
		this.bank = bank;
	}

	public int[] getLevels() {
		return levels;
	}

	public void setLevels(int[] levels) {
		this.levels = levels;
	}
	
	
}
