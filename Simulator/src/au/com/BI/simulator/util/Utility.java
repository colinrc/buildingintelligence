package au.com.BI.simulator.util;


public class Utility {
	public static String parseString (String str){
		String result = "";
		int totalLength = str.length();
		for (int i = 0; i < totalLength; i ++){
			if (str.charAt(i) == '#'){
				i ++;
				try {
					if (str.charAt(i) == '#') {
						result += '#'; 
					} else {
						try {
							int a = Integer.parseInt(str.substring(i,i+2),16);
							result += (char)a;

						} catch (NumberFormatException ex) {};
						i++;
					}
				} catch (IndexOutOfBoundsException ex) {
					result += '#';
				}
			} else {
				result += str.charAt(i);
			}
		}
		return result;
	}
	
	public static String parseBytesForPrint (byte str[]) {
	   String toWrite = "";
	   for (int i = 0; i < str.length; i ++ ){
		   int eachOne = str[i];
		   if ( eachOne < 32 || eachOne > 126   ){
			   String hexVers = Integer.toHexString(eachOne);
			   if (hexVers.length() == 1) hexVers = "0" + hexVers;
			   toWrite += "#" + hexVers;
		   } else {
			   toWrite += (char)eachOne;
		   }
	   }
	   return toWrite;
	}
	
	public static String allBytesToHex (byte str[]) {
		   String toWrite = "";
		   for (int i = 0; i < str.length; i ++ ){
			   byte eachOne = str[i];
			   String hexVers = Integer.toHexString(eachOne);
			   if (hexVers.length() > 2) hexVers = hexVers.substring(hexVers.length()-2);
			   if (hexVers.length() == 1) hexVers = "0" + hexVers;
			   toWrite += "#" + hexVers;
		   }
		   return toWrite;
		}
	
	public static String padStringTohex (int inp){
		return padString (Integer.toHexString(inp));
	}
	
	
	public static String padString (String inp, int numDigits){
		String result = "";
		if (inp == null || inp.equals("")){
			result =  "00000000000000000000".substring(20-numDigits);
			return result;
		}
		
		if (inp.length() < numDigits){
			result =  ("00000000000000000000".substring(20-(numDigits-inp.length()))) + inp.toUpperCase();
			return result;
		}
		
		if (inp.length() > numDigits) {
			result = (inp.substring(inp.length() - numDigits)).toUpperCase();
			return result;
		}
		
		return inp.toUpperCase();
	}
	
	public static String padString (String inp){
		if (inp == null || inp.equals("")){
			return "00";
		}
		
		if (inp.length() == 1){
			return ("0" + inp).toUpperCase();
		}
		
		if (inp.length() > 2) {
			return (inp.substring(inp.length() - 2)).toUpperCase();
		}
		
		return inp.toUpperCase();
	}
}
