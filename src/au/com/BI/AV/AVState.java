package au.com.BI.AV;

public class AVState {
	String volume = "0";
	int bass = -1000; // values which will not occur naturally hence will be pushed through when the AVState is first created.
	int treble = -1000;
	int vol = 0;
	boolean mute = false;
	int src = 0;
	boolean power = false;	
	boolean powerNotYetSet = true;
	boolean ext_mute = false;
	boolean group_on = false;
	boolean loudness = false;
	boolean loudNotYetSet = true;
	boolean volNotYetSet = true;
	
	boolean changed = false;
	
	public String getVolume() {
		return volume;
	}
	
	public int getVolumeAsInt() {
		return vol;
	}
	
	public void setVolume(String volume) {
		if (!volume.equals(this.volume)){
			this.volume = volume;
			this.vol = Integer.parseInt(volume);
			this.setChanged(true);
			this.volNotYetSet = false;
		}
	}
	
	public String volumeUp() {
		if (vol < 100) vol += 5;
		if (vol > 100) vol = 100;
		volume =  String.valueOf(vol);
		this.setChanged(true);		
		return volume;
	}

	public String volumeDown() {
		if (vol > 4) vol -= 5;
		if (vol < 0)vol = 0;
		volume =  String.valueOf(vol);
		this.setChanged(true);
		return volume;	
	}

	public boolean testMute(String testVal) {
		if (testVal.equals ("mute"))
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
		if (volNotYetSet) {
			return false;
		} else {
			if (testVal == vol)
				return true;
			else
				return false;
		}
	}
	
	public boolean testVolume(String testVal) {
		if (volNotYetSet) {
			return false;
		} else {
			if (testVal.equals (volume))
				return true;
			else
				return false;
		}
	}

	public boolean isMute() {
		return mute;
	}

	public void setMute(boolean mute) {
		if (mute != this.mute){
			this.mute = mute;
			this.setChanged(true);
		}
	}
	
	public boolean isPower() {
		return power;
	}
	
	public boolean testPower(boolean testVal) {
		if (powerNotYetSet) return false;
		if (testVal != this.power){
			return false;
		} else {
			return true;
		}
	}
	
	public void setPower(boolean power) {
		if (power != this.power){
			this.power = power;
			powerNotYetSet = false;
			this.setChanged(true);
		}
	}

	public int getSrc() {
		return src;
	}

	public void setSrc(int src) {
		if (src != this.src){
			this.src = src;
			this.setChanged(true);
		}
	}	
	
	public boolean testExt_mute(String testVal) {
		if (testVal.equals("ext_mute"))
			return true;
		else
			return false;
	}
		
	public boolean testTreble(int testVal) {
		if (testVal == this.treble)
			return true;
		else
			return false;
	}
		
	public boolean testBass(int testVal) {
		if (testVal == this.bass)
			return true;
		else
			return false;
	}
	
	public boolean isExt_mute() {
		return ext_mute;
	}

	public void setExt_mute(boolean ext_mute) {
		if (ext_mute != this.ext_mute) {
			this.ext_mute = ext_mute;
			this.setChanged(true);
		}
	}

	public boolean isGroup_on(int groupNumber) {
		return group_on;
	}

	public void setGroup_on(boolean group_on,int groupNumber) {
		if (this.group_on != group_on){
			this.group_on = group_on;
			this.setChanged(true);
		}
	}

	public boolean isLoudness() {
		if (loudNotYetSet) return false;
		return loudness;
	}

	public void setLoudness(boolean loudness) {
		loudNotYetSet = false;
		if (loudness != this.loudness){
			this.loudness = loudness;
			this.setChanged(true);
		}
	}
	
	public boolean testLoudness(boolean testVal) {
		if (loudNotYetSet) return false;
		if (testVal != this.loudness){
			return false;
		} else {
			return true;
		}
	}

	public int getBass() {
		return bass;
	}

	public void setBass(int bass) {
		if (bass != this.bass){
			this.bass = bass;
			this.setChanged(true);
		}
	}

	public int getTreble() {
		return treble;
	}

	public void setTreble(int treble) {
		if (treble != this.treble){
			this.treble = treble;
			this.setChanged(true);
		}
	}

	public boolean isChanged() {
		return changed;
	}

	public void setChanged(boolean changed) {
		this.changed = changed;
	}
}
