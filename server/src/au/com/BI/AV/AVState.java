package au.com.BI.AV;

public class AVState {
	String volume = "0";
	int vol = 0;
	boolean mute = false;
	int src = 0;
	boolean power = false;
	boolean ext_mute = false;
	boolean group_on = false;
	
	public String getVolume() {
		return volume;
	}
	
	public int getVolumeAsInt() {
		return vol;
	}
	
	public void setVolume(String volume) {
		this.volume = volume;
		this.vol = Integer.parseInt(volume);
	}
	
	public String volumeUp() {
		if (vol < 100) vol += 5;
		if (vol > 100) vol = 100;
		volume =  String.valueOf(vol);
		return volume;
	}

	public String volumeDown() {
		if (vol > 4) vol -= 5;
		if (vol < 0)vol = 0;
		volume =  String.valueOf(vol);
		return volume;	
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
		
	public boolean testVolume(int testVal) {
		if (testVal == vol)
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
	
	public boolean testExt_mute(String testVal) {
		if (testVal.equals (ext_mute))
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

	public boolean isGroup_on(int groupNumber) {
		return group_on;
	}

	public void setGroup_on(boolean group_on,int groupNumber) {
		this.group_on = group_on;
	}
}
