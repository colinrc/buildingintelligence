/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.Dynalite;

import java.util.logging.Level;
import java.util.logging.Logger;
import au.com.BI.Util.Utility;


/**
 * @author colinc
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class DynaliteHelper {
	private Logger logger;
	
	public DynaliteHelper () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public String buildKey (String areaCode, String channelCodeStr) {
		int channelCode = 0;
		if (channelCodeStr.equals("")) {
			channelCode = 255;
		} else {
			try {
				channelCode = Integer.parseInt (channelCodeStr,16);
			} catch (NumberFormatException ex){}
		}
		//if (channelCode > 0 ) channelCode --;
		if (areaCode.equals("")) areaCode="01";
		String resultKey = Utility.padString(areaCode) + ":" + Utility.padStringTohex(channelCode);
		return resultKey.toUpperCase();
	}
	
	public String buildKey (String areaCode, int channelCode) {
		return buildKey (areaCode,Utility.padStringTohex(channelCode));
	}

	public String buildKey (int areaCode, int channelCode) {
		return buildKey (Utility.padStringTohex(areaCode), Utility.padStringTohex(channelCode));
	}

	public String buildKey (int boxCode, String switchNumber) {
		return buildKey (Utility.padStringTohex(boxCode),Utility.padString(switchNumber));
	}

	public int scaleLevelForFlash(byte level) throws NumberFormatException {
		int trueLevel = (int)level & 0xFF;
		double tempDlevel = 102.0 * (256.0 - (double)trueLevel)/255.0;
		int templevel = (int)Math.round(tempDlevel);
		
		
		//if (templevel == 1) templevel = 0;
		//if (templevel == 49) templevel = 50;
		//if (templevel == 57) templevel = 58;
		if (templevel >= 99) templevel = 100;

		return templevel;
	}

	public int scaleLevelFromFlash(String levelStr) throws NumberFormatException {
		int level = 0;
		byte tempLevel  = Byte.parseByte(levelStr);
		level = 255 - (int)((tempLevel)/102.0 * 255.0);
		
		if (level <= 5) level = 1;
		// if (level == 131) level = 130;
		// if (level == 128) level = 130;

		return level;
	}

	public boolean passChecksum( byte[] buffer) throws ArrayIndexOutOfBoundsException {
		if (buffer[7] == calcChecksum(buffer))
			return true;
		else
			return false;
	}

	protected byte calcChecksum (byte[] toCalc) throws ArrayIndexOutOfBoundsException {
		int total = 0;
		for (int i = 0; i < 6; i++) {
			total += toCalc[i];
		}
	
		total = -total;
		total ++;
		total = total & 255;
		return (byte)total;
	}

	protected void addChecksum (byte[] toCalc) throws ArrayIndexOutOfBoundsException {
		toCalc[7] = calcChecksum (toCalc);
	}
	
	
	public byte findJoin (String joinStr,DynaliteOutput dynaliteOutput) {
		byte join = (byte)0xff;
		try {
			if (!joinStr.equals(""))
				join = (byte)Integer.parseInt(joinStr);
		} catch (Exception ex) {
			logger.log( Level.WARNING,"Join is not correctly formatted");
			dynaliteOutput.ex = ex;
			dynaliteOutput.isError = true;

		}
		return join;
	}
}
