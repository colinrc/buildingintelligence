package au.com.BI.SignVideo;

public class State {
	int src = 0;
	boolean power = false;
	
	public State() {
		
	}
	
	public boolean testSrc(int testVal) {
		if (testVal == src)
			return true;
		else
			return false;
	}
		
	public boolean isPower() {
		return power;
	}
	
	public void setPower(boolean power) {
		this.power = power;
	}

	public int getSrc() {
		return src;
	}

	public void setSrc(int src) {
		this.src = src;
	}	

}
