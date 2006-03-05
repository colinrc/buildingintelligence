package au.com.BI.Dynalite;


public class DynaliteOutput extends GeneralDynaliteResult{

	byte [] outputCodes;
	boolean isArea;

	public DynaliteOutput (){
		isArea = false;
		outputCodes = new byte[8];
	};

}
