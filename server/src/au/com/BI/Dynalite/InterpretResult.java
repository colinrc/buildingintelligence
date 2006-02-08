package au.com.BI.Dynalite;
import java.util.LinkedList;
import java.util.List;

public class InterpretResult {
	List decoded;
	List nextAction;
	boolean error;
	String errorMessage;
	String fullKey;
	
	boolean rescanLevels = false;
	boolean rescanSingleChannel = false;
	byte rescanArea = 0;
	byte rescanChannel = 0;
	
	public InterpretResult () {
		 decoded = new LinkedList ();
		 nextAction = new LinkedList ();
	}

	public String getFullKey() {
		return fullKey;
	}

	public void setFullKey(String fullKey) {
		this.fullKey = fullKey;
	}

	public boolean isRescanLevels() {
		return rescanLevels;
	}

	public void setRescanLevels(boolean rescanLevels) {
		this.rescanLevels = rescanLevels;
	}

	public byte getRescanArea() {
		return rescanArea;
	}

	public void setRescanArea(byte rescanArea) {
		this.rescanArea = rescanArea;
	}

	public boolean isRescanSingleChannel() {
		return rescanSingleChannel;
	}

	public void setRescanSingleChannel(boolean rescanSingleChannel) {
		this.rescanSingleChannel = rescanSingleChannel;
	}

	public byte getRescanChannel() {
		return rescanChannel;
	}

	public void setRescanChannel(byte rescanChannel) {
		this.rescanChannel = rescanChannel;
	}

}
