package au.com.BI.SignVideo;

public class State {
	int src = 0;
	
	public State() {
		
	}
	
	public boolean testSrc(int testVal) {
		if (testVal == src)
			return true;
		else
			return false;
	}

	public int getSrc() {
		return src;
	}

	public void setSrc(int src) {
		this.src = src;
	}	

}
