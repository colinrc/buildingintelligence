package au.com.BI.SignVideo;

public class State {
	String volume = "";
	boolean mute = false;
	int src = 0;
	boolean ext_mute = false;
	boolean group_on = false;
	boolean power = false;
	
	public State() {
		
	}
	
	
	public String getVolume() {
		return volume;
	}
	
	public void setVolume(String volume) {
		this.volume = volume;
	}
	
	
	
	public boolean testExt_mute(String testVal) {
		if (testVal.equals (ext_mute))
			return true;
		else
			return false;
	}
		
		
	public boolean testMute(String testVal) {
		if (testVal.equals (mute))
			return true;
		else
			return false;
	}
	
	public boolean testSrc(int testVal) {
		if (testVal == src)
			return true;
		else
			return false;
	}
		
	public boolean testVolume(String testVal) {
		if (testVal.equals (volume))
			return true;
		else
			return false;
	}

	public boolean isExt_mute() {
		return ext_mute;
	}

	public void setExt_mute(boolean ext_mute) {
		this.ext_mute = ext_mute;
	}

	public boolean isGroup_on() {
		return group_on;
	}

	public void setGroup_on(boolean group_on) {
		this.group_on = group_on;
	}

	public boolean isMute() {
		return mute;
	}

	public void setMute(boolean mute) {
		this.mute = mute;
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
