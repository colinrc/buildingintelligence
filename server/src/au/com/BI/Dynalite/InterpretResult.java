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
	int rescanArea = 0;
	
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

	public int getRescanArea() {
		return rescanArea;
	}

	public void setRescanArea(int rescanArea) {
		this.rescanArea = rescanArea;
	}

}
