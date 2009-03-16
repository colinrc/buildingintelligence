/*
 * Created on Apr 25, 2004
 */
package au.com.BI.CBUS;

/**
 * @author colinc
 */
public class StateOfGroup {
	/**
	 * This encapsulates all state information of a light. 
	 * It is used for startup.
	 */
	

	protected int level = 0;
	protected String power = "";
	protected boolean isDirty = false;
	protected int countConflict = 0;
	protected boolean fromMMI = false;
	protected boolean fromClient = false;
	protected boolean fromWall = false;

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
	public StateOfGroup() {
		super();
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
	public void setPower(String power, boolean fromMMI) {
		if (!this.power.equals (power)) {
			if (!(level == 0 && power.equals("off")  && fromMMI)) { 
					isDirty=true;
			}
			this.power = power;
		}
		if (!fromMMI) countConflict = 0;
		this.fromMMI = fromMMI;
	}
	/**
	 * @return Returns the power.
	 */
	public int getLevel() {
		return level;
	}
	/**
	 * @param power The power to set.
	 */
	public void setLevel(int level,boolean fromMMI) {
		if (this.level != level) {
			this.level = level;
			isDirty=true;
		}
		if (!fromMMI) countConflict = 0;
		this.fromMMI = fromMMI;
	}
	
	public int getCountConflict() {
		return countConflict;
	}
	public void setCountConflict(int countConflict) {
		this.countConflict = countConflict;
	}
	public boolean isFromMMI() {
		return fromMMI;
	}
	public void setFromMMI(boolean fromMMI) {
		this.fromMMI = fromMMI;
		if (fromMMI) {
			fromClient = false;
			fromWall =false;
		}
	}
	public boolean isFromClient() {
		return fromClient;
	}
	public void setFromClient(boolean fromClient) {
		this.fromClient = fromClient;
		if (fromClient) {
			fromMMI = false;
			fromWall =false;
			this.countConflict = 0;
		}
	}
	public boolean isFromWall() {
		return fromWall;
	}
	public void setFromWall(boolean fromWall) {
		this.fromWall = fromWall;
		if (fromWall) {
			fromMMI = false;
			fromClient =false;
			this.countConflict = 0;
		}

	}
}
