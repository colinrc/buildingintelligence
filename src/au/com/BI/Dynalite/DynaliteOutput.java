package au.com.BI.Dynalite;


public class DynaliteOutput extends GeneralDynaliteResult{

	byte [] outputCodes;
	boolean isArea;

	public DynaliteOutput (){
		isArea = false;
		outputCodes = new byte[8];
	};

	public byte[] getOutputCodes() {
		return outputCodes;
	}

	public void setOutputCodes(byte[] outputCodes) {
		this.outputCodes = outputCodes;
	}

	public boolean isArea() {
		return isArea;
	}

	public void setArea(boolean isArea) {
		this.isArea = isArea;
	}
}
