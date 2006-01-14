package au.com.BI.Dynalite;

import java.util.logging.Level;
import java.util.logging.Logger;

public class FadeRate {
	byte highByte = 0;
	byte lowByte = 0;
	boolean rateSec = true;
	int rate = 2;
	Logger logger = null;
	byte linearInstr = 0;
	byte linearFadeRate = 0;
	
	public FadeRate (String rateStr,DynaliteOutput dynaliteOutput){
		logger = Logger.getLogger(this.getClass().getPackage().getName());

		if (rateStr.endsWith("m") || rateStr.endsWith("M")) {
			linearInstr = 0x73; // minute resolution
			try {
				rate = Integer.parseInt(rateStr.substring(0,rateStr.length()-1));
				rateSec = false;
			} catch (Exception ex) {
				logger.log( Level.WARNING,"Rate is not correctly formatted");
				dynaliteOutput.ex = ex;
				dynaliteOutput.isError = true;

			}			
		} else {
			linearInstr = 0x72; // second resolution
			try {
				if (rateStr.equals(""))
					rate = 2;
				else
					rate = Integer.parseInt(rateStr);
			} catch (Exception ex) {
				logger.log( Level.WARNING,"Rate is not correctly formatted");
				dynaliteOutput.ex = ex;
				dynaliteOutput.isError = true;

			}
		}
		
		linearFadeRate = (byte)rate;
		int  rateClassic = 0;
		if (rateSec) {
			rateClassic = (int)(rate / .02);
		} else {
			rateClassic = (int) (rate * 60 / .02);
		}
		lowByte = (byte)(rateClassic % 256);
		highByte = (byte)(rateClassic /  256);
	}

}
