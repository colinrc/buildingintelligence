package au.com.BI.Util;
import java.util.*;
import java.util.logging.Level;

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
	 * Scales a value from the flash client to an arbitrary number range.
	 * @param input A 0-100 value from the client. 
	 * @param min
	 * @param max
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
				String escapedValue = "";
				int startChar = 4;
				while (startChar < value.length()) {
					String nextVal = value.substring(startChar,startChar + 2);
					try {
						escapedValue = escapedValue + (char)(Integer.valueOf(nextVal,16).intValue());
					} catch (NumberFormatException e) {
						
					}
					startChar += 2;
				}
				return escapedValue;
			}
		}

		String [] bits = value.split ("\\\\");
		if (bits.length > 1 ) {
			String escapedValue = bits[0]; // first is handled specially, it is impossible for it to be an escaped code
			for (int i = 1; i < bits.length; i += 1) {
				if (bits[i].length() > 0) {
					char charToMatch = bits[i].charAt(0);
					if (charToMatch == 'r') {
						escapedValue += "\r";
						if (bits[i].length() > 1) escapedValue += bits[i].substring(1);
					}
					if (charToMatch == 'n') {
						escapedValue += "\n";
						if (bits[i].length() > 1) escapedValue += bits[i].substring(1);
					}
					try {
						if (charToMatch == 'x') {
							String hexCodes = bits[i].substring(1,3);
							byte decoded = Integer.valueOf(hexCodes,16).byteValue();
							escapedValue += (char)decoded;
							if (bits[i].length() > 3) escapedValue += bits[i].substring(3);
						}
					} catch (NumberFormatException err) {
					}
				}
			}
			return escapedValue;
		}
		
		return value;
	}

}
