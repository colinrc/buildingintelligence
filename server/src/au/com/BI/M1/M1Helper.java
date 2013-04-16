package au.com.BI.M1;
import au.com.BI.Util.*;

public class M1Helper {

	
	public String calcM1Checksum (String toCalc) {
		int total = 0;
		for (int i = 0; i < toCalc.length(); i++) {
			total += toCalc.charAt(i);
		}
		byte remainder = (byte)(total % 256);
		byte twosComp = (byte)-remainder;
		
		//byte twosComp = (byte)((byte)total ^ (byte)0xff + (byte)1);
		String hexCheck = Integer.toHexString(twosComp); 
		if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
		if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);
		return hexCheck.toUpperCase();
	}
	
	public boolean passChecksum (String toTest){
		try {
			String checksumVal = toTest.substring(toTest.length()-2);
			byte checksumIntVal = (byte)Integer.parseInt(checksumVal,16);
			int numChars = Integer.parseInt(toTest.substring(0,2),16);
			for (int i = 0; i < numChars ; i ++ ) {
				checksumIntVal += toTest.charAt(i);
			}
			if (checksumIntVal == 0)
				return true;
			else
				return false;
			
		} catch (NumberFormatException ex){
			return false;
		} catch (IndexOutOfBoundsException ex){
			return false;
		}
	}
	
	public String buildCompleteM1String (String dataString){
		int first2 = dataString.length() + 2;
		String ret = Utility.padStringTohex(first2) + dataString;

		 ret += calcM1Checksum (ret);
		return ret;
	}
}
