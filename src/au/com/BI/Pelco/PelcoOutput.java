package au.com.BI.Pelco;

public class PelcoOutput {

	byte [] outputCodes;
	boolean isError = false;
	byte address = 0;
	
	public PelcoOutput (){
		outputCodes = new byte[7];
	};

	public boolean isError() {
		return isError;
	}

	public void setError(boolean isError) {
		this.isError = isError;
	}

	public byte getAddress() {
		return address;
	}

	public void setAddress(byte address) {
		this.address = address;
	}

	public byte[] getOutputCodes() {
		return outputCodes;
	}
}
