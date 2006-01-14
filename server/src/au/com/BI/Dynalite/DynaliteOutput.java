package au.com.BI.Dynalite;

public class DynaliteOutput {

	byte [] outputCodes;
	boolean isArea;
	boolean isError = false;
	Exception ex = null;
	boolean rescanLevels = false;
	int rescanArea = 0;

	public int getRescanArea() {
		return rescanArea;
	}

	public void setRescanArea(int rescanArea) {
		this.rescanArea = rescanArea;
	}

	public boolean isRescanLevels() {
		return rescanLevels;
	}

	public void setRescanLevels(boolean rescanLevels) {
		this.rescanLevels = rescanLevels;
	}

	public DynaliteOutput (){
		isArea = false;
		outputCodes = new byte[8];
	};

}
