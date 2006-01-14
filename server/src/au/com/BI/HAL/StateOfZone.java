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
	protected boolean isDirty = false;
	protected boolean isSrcDirty = false;
	protected boolean ignoreNextPower = false;
	
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
			isDirty=true;
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
			isDirty=true;
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
		return isSrcDirty;
	}
	/**
	 * @param isSrcDirty The isSrcDirty to set.
	 */
	public void setSrcDirty(boolean isSrcDirty) {
		this.isSrcDirty = isSrcDirty;
	}
	public boolean isIgnoreNextPower() {
		return ignoreNextPower;
	}
	public void setIgnoreNextPower(boolean ignoreNextPower) {
		this.ignoreNextPower = ignoreNextPower;
	}
}
