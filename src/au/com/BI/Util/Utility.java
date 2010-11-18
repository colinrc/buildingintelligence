package au.com.BI.Util;


public class Utility {
	public static String parseString (String str){
		StringBuilder result = new StringBuilder();
		int totalLength = str.length();
		for (int i = 0; i < totalLength; i ++){
			if (str.charAt(i) == '#'){
				i ++;
				try {
					if (str.charAt(i) == '#') {
						result.append('#'); 
					} else {
						try {
							
							byte a = Byte.parseByte(str.substring(i,i+2),16);
							result.append((char)a);

						} catch (NumberFormatException ex) {};
						i++;
					}
				} catch (IndexOutOfBoundsException ex) {
					result.append('#');
				}
			} else {
				result.append(str.charAt(i));
			}
		}
		return result.toString();
	}
	
	public static String parseBytesForPrint (byte str[]) {
	   StringBuilder toWrite = new StringBuilder();
	   for (int i = 0; i < str.length; i ++ ){
		   byte eachOne = str[i];
		   if ( eachOne < 32 || eachOne > 126   ){
			   String hexVers = Integer.toHexString(eachOne);
			   if (hexVers.length() == 1) hexVers = "0" + hexVers;
			   toWrite.append("#" + hexVers);
		   } else {
			   toWrite.append((char)eachOne);
		   }
	   }
	   return toWrite.toString();
	}
	
	public static String allBytesToHex (byte str[]) {
		   StringBuilder toWrite = new StringBuilder();
		   for (int i = 0; i < str.length; i ++ ){
			   byte eachOne = str[i];
			   String hexVers = Integer.toHexString(eachOne);
			   if (hexVers.length() > 2) hexVers = hexVers.substring(hexVers.length()-2);
			   if (hexVers.length() == 1) hexVers = "0" + hexVers;
			   toWrite.append("#" + hexVers);
		   }
		   return toWrite.toString();
		}
	
	public static String padStringTohex (int inp){
		return padString (Integer.toHexString(inp));
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
	
	
	/**
	 * Scales a value from the device to a 0 - 100 number for flash. 
	 * If 100  should be considered 0 from the client list the larger value first, otherwise list the minimum first.
	 * @param input A 0-100 value from the client. 
	 * @param first val
	 * @param second val
	 * @return The scaled value
	 * @throws NumberFormatException Thrown when the client value is not a number
	 */
	public static int scaleForFlash (String input, String val1,String val2) throws NumberFormatException {
		int intVal1 = Integer.parseInt(val1);
		int intVal2 = Integer.parseInt(val2);
		if (intVal1 > intVal2){
			return scaleForFlash (input, intVal2, intVal1, true);
		} else {
			return scaleForFlash (input, intVal1, intVal2, false);			
		}

	}	
	
	/**
	 * Scales a value from the device to a 0 - 100 number for flash. 
	 * @param input A 0-100 value from the client. 
	 * @param min
	 * @param max
	 * @param invert whether 0 or 100 should be considered the maximum
	 * @return The scaled value
	 * @throws NumberFormatException Thrown when the client value is not a number
	 */
	public static int scaleForFlash (String input, int min, int max,boolean invert) throws NumberFormatException {
		String result = "0";
		double range = max - min;
		double inputVal = Double.parseDouble(input) - min;

		Double returnVal = Double.valueOf(inputVal / range * 100.0);
		int intVal = returnVal.intValue();
		if (invert){
			intVal = 100 - intVal;
		}
		return intVal;
	}	
	
	/**
	 * Scales a value from from flash to a value for the client. 
	 * If 100  should be considered 0 from the client list the larger value first, otherwise list the minimum first.
	 * @param input A 0-100 value from the client. 
	 * @param first val
	 * @param second val
	 * @return The scaled value
	 * @throws NumberFormatException Thrown when the client value is not a number
	 */
	public static int scaleFromFlash (String input, String val1,String val2) throws NumberFormatException {
		int intVal1 = Integer.parseInt(val1);
		int intVal2 = Integer.parseInt(val2);
		if (intVal1 > intVal2){
			return scaleFromFlash (input, intVal2, intVal1, true);
		} else {
			return scaleFromFlash (input, intVal1, intVal2, false);			
		}

	}	
	
	/**
	 * Scales a value from the flash client to an arbitrary number range.
	 * @param input A 0-100 value from the client. 
	 * @param min
	 * @param max
	 * @return The scaled value
	 * @throws NumberFormatException Thrown when the client value is not a number
	 */
	public static int scaleFromFlash (String input, int min, int max,boolean invert) throws NumberFormatException {
		String result = "000";
		double range = max - min + 1;
		double inputVal = Double.parseDouble(input);
		if (invert){
			inputVal = 100.0 - inputVal;
		}
		Double returnVal = Double.valueOf(inputVal / 101.0 * range);
		int intVal = returnVal.intValue() + min;
		return intVal;
	}
	
	/**
	 * 0 Pads a string.
	 * @param inp The string
	 * @param numDigits Number of digits for the return string
	 * @return
	 */
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

	public static String unEscape (String value) {
		if (value == null) return null;
		
		if (value.length() >=  4){
			if (value.regionMatches(0,"HEX1",0,4)) {
				StringBuilder escapedValue = new StringBuilder();
				int startChar = 4;
				while (startChar < value.length()) {
					String nextVal = value.substring(startChar,startChar + 2);
					try {
						escapedValue.append((char)(Integer.valueOf(nextVal,16).intValue()));
					} catch (NumberFormatException e) {
						
					}
					startChar += 2;
				}
				return escapedValue.toString();
			}
		}

		String [] bits = value.split ("\\\\");
		if (bits.length > 1 ) {
			StringBuffer escapedValue = new StringBuffer(bits[0]); // first is handled specially, it is impossible for it to be an escaped code
			for (int i = 1; i < bits.length; i += 1) {
				if (bits[i].length() > 0) {
					char charToMatch = bits[i].charAt(0);
					if (charToMatch == 'r') {
						escapedValue.append("\r");
						if (bits[i].length() > 1) escapedValue.append(bits[i].substring(1));
					}
					if (charToMatch == 'n') {
						escapedValue.append("\n");
						if (bits[i].length() > 1) escapedValue.append(bits[i].substring(1));
					}
					try {
						if (charToMatch == 'x') {
							String hexCodes = bits[i].substring(1,3);
							byte decoded = Integer.valueOf(hexCodes,16).byteValue();
							escapedValue.append((char)decoded);
							if (bits[i].length() > 3) escapedValue.append(bits[i].substring(3));
						}
					} catch (NumberFormatException err) {
					}
				}
			}
			return escapedValue.toString();
		}
		
		return value;
	}

}
