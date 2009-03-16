/*
 * Created on Apr 25, 2004
 */
package au.com.BI.Tutondo;

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
	protected String volume = "";
	protected boolean isDirty;
	protected boolean isSrcDirty;
	protected boolean isVolumeDirty;

	public StateOfZone() {
		super();
		isDirty = false;
		isSrcDirty = false;
		isVolumeDirty = false;
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
		if (!mute.equals(this.mute)) {
			this.setIsDirty(true);
			this.mute = mute;
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
		if (!power.equals(this.power)) {
			this.setIsDirty(true);
			this.power = power;
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
		if (!src.equals(this.src)) {
			this.setSrcDirty(true);
			this.src = src;
		}
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
		if (!srcCode.equals(this.srcCode)) {
			this.setSrcDirty(true);
			this.srcCode = srcCode;
		}
	}
	/**
	 * @return Returns the isDirty.
	 */
	public boolean getIsDirty() {
		return isDirty;
	}
	/**
	 * @param isDirty The isDirty to set.
	 */
	public void setIsDirty(boolean isDirty) {
		this.isDirty = isDirty;
	}	
	/**
	 * @return Returns the isSrcDirty.
	 */
	public boolean isSrcDirty() {
		return isSrcDirty;
	}
	/**
	 * @param isSrcDirty The isSrcDirty to set.
	 */
	public void setSrcDirty(boolean isSrcDirty) {
		this.isSrcDirty = isSrcDirty;
	}

	public String getVolume() {
		return volume;
	}

	public void setVolume (int volume) {
		setVolume (String.valueOf(volume));
	}
	
	public void setVolume(String volume) {

		if (!volume.equals (this.volume)) {
			this.setVolumeDirty(true);
			this.volume = volume;
		}
	}

	public boolean isVolumeDirty() {
		return isVolumeDirty;
	}

	public void setVolumeDirty(boolean isVolumeDirty) {
		this.isVolumeDirty = isVolumeDirty;
	}
}
