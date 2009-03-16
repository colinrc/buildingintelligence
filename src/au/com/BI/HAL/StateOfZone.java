/*
 * Created on Apr 25, 2004
 */
package au.com.BI.HAL;

/**
 * @author colinc
 */
public class StateOfZone {
	/**
	 * This encapsulates all state information of a zone. 
	 * It is used for startup.
	 */
	
	protected String src = "0";
	protected String srcCode = "";
	protected String mute = "";
	protected String power = "";
	protected int volume = VOL_INVALID;
	protected boolean dirty = false;
	protected boolean srcDirty = false;
	protected boolean muteDirty = false;
	protected boolean ignoreNextPower = false;
	protected boolean volumeDirty = false;
	
	
	public static final int VOL_INVALID = -1;
	
	/**
	 * @return Returns the isDirty.
	 */
	public boolean getDirty() {
		return dirty;
	}
	/**
	 * @param isDirty The isDirty to set.
	 */
	public void setDirty(boolean dirty) {
		this.dirty = dirty;
	}
	public StateOfZone() {
		super();
	}
	/**
	 * @return Returns the mute.
	 */
	public String getMute() {
		return mute;
	}
	/**
	 * @param mute The mute to set.
	 */
	public void setMute(String mute) {
		if (!this.mute.equals(mute)) {
			this.mute = mute;
			this.muteDirty = true;
		}
	}
	/**
	 * @return Returns the power.
	 */
	public String getPower() {
		return power;
	}
	/**
	 * @param power The power to set.
	 */
	public void setPower(String power) {
		if (!this.power.equals (power)) {
			this.power = power;
			dirty=true;
		}
	}
	/**
	 * @return Returns the src.
	 */
	public String getSrc() {
		return src;
	}
	/**
	 * @param src The src to set.
	 */
	public void setSrc(String src) {
		this.src = src;
	}
	/**
	 * @return Returns the srcCode.
	 */
	public String getSrcCode() {
		return srcCode;
	}
	/**
	 * @param srcCode The srcCode to set.
	 */
	public void setSrcCode(String srcCode) {
		if (!this.srcCode.equals(srcCode)) {
			this.srcCode = srcCode;
			this.setSrcDirty(true);
		}
	}

	/**
	 * @return Returns the isSrcDirty.
	 */
	public boolean isSrcDirty() {
		return srcDirty;
	}
	/**
	 * @param isSrcDirty The isSrcDirty to set.
	 */
	public void setSrcDirty(boolean srcDirty) {
		this.srcDirty = srcDirty;
	}
	public boolean isIgnoreNextPower() {
		return ignoreNextPower;
	}
	public void setIgnoreNextPower(boolean ignoreNextPower) {
		this.ignoreNextPower = ignoreNextPower;
	}
	/**
	 * @return Returns the volume.
	 */
	public int getVolume() {
		return volume;
	}
	/**
	 * @param power The power to set.
	 */
	public void setVolume(int volume) {
		if (this.volume !=  volume) {
			this.volume = volume;
			if (volume != VOL_INVALID) volumeDirty=true;
		}
	}
	public boolean isVolumeDirty () {
		return volumeDirty;
	}
	public void setVolumeDirty(boolean volumeDirty) {
		this.volumeDirty = volumeDirty;
	}
	public boolean isMuteDirty() {
		return muteDirty;
	}
	public void setMuteDirty(boolean muteDirty) {
		this.muteDirty = muteDirty;
	}
	public boolean isAnyDirty() {
		return muteDirty || volumeDirty || srcDirty || dirty;
	}
	
	/**
	 * @param b
	 */
	public void setAllDirty(boolean b) {
		setVolumeDirty (b);
		setMuteDirty(b);
		setSrcDirty(b);
		setDirty(b);
		
	}
}
