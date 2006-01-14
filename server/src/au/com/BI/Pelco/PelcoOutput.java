package au.com.BI.Pelco;

public class PelcoOutput {

	byte [] outputCodes;
	boolean isError = false;
	Exception ex = null;
	byte address = 0;
	
	public PelcoOutput (){
		outputCodes = new byte[7];
	};

}
