/*
 * Created on Jun 10, 2004
 *
 */
package au.com.BI.Kramer;

import java.util.logging.Level;
import java.util.logging.Logger;


public class KramerHelper {
	protected Logger logger;

	public KramerHelper () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	

	protected byte[] buildSwitchCommand (int command,  String zone,String src,String machineNumber) {
		try {
			byte outputArr[] = new byte [4];
			byte outputZone = Byte.parseByte(zone);
			byte machineCode = 1;
			if (src == null) {
				logger.log (Level.WARNING, "SRC selection entry for Kramer is unknown ");
				return null;
			}
			if (machineNumber != null &&  !machineNumber.equals("")) {
				machineCode = Byte.parseByte(machineNumber);
			}
			byte machineInputSrc = 0;
			if (!src.equals("")) {
				machineInputSrc = Byte.parseByte(src);
			}
			outputArr[0] = (byte) (command&63);
			outputArr[1] = (byte) (machineInputSrc|128);
			outputArr[2] = (byte) (outputZone|128);
			outputArr[3] = (byte) (machineCode|128);

			return outputArr;
		} catch (NumberFormatException er) {
			logger.log (Level.WARNING, "Zone or machine entry for Kramer is malformed " + zone + " : machine : " + machineNumber);
			return null;
		}
	}
	
	protected byte[] buildKramerCommand (int command,  String zone,int param,String machineNumber) {
		try {
			byte outputZone = Byte.parseByte(zone);
			return buildKramerCommand (command,outputZone,param,machineNumber);
		} catch (NumberFormatException er) {
			logger.log (Level.SEVERE, "Zone entry for Kramer is malformed " + zone);
			return null;
		}
	}

	protected byte[] buildKramerCommand (int command,  int param1,int param2,String machineNumber) {
		try {
			byte outputArr[] = new byte [4];

			byte machineCode = 1;
			if (!machineNumber.equals("")) {
				machineCode = Byte.parseByte(machineNumber);
			}
			outputArr[0] = (byte) (command&63);
			outputArr[1] = (byte) (param1|128);
			outputArr[2] = (byte) (param2|128);
			outputArr[3] = (byte) (machineCode|128);

			return outputArr;
		} catch (NumberFormatException er) {
			logger.log (Level.SEVERE, "Machine entry for Kramer is malformed machine : " + machineNumber);
			return null;
		}
	}
	
	/*
	 * 
	 protected byte[] buildKramerCommand (int command, int param, String zone,String machineNumber, int secondCommand, int secondParam) {
		try {
			byte outputArr[] = new byte [4];
			byte outputZone = Byte.parseByte(zone);
			byte machineCode = 0;
			if (!machineNumber.equals("")) {
				machineCode = Byte.parseByte(machineNumber);
			}
			outputArr[0] = (byte) (command&127);
			outputArr[1] = (byte) (outputZone|128);
			outputArr[2] = (byte) (param|128);
			outputArr[3] = (byte) (machineCode|128);

			return outputArr;
		} catch (NumberFormatException er) {
			logger.log (Level.SEVERE, "Zone or machine entry for Kramer is malformed " + zone + " : machine : " + machineNumber);
			return null;
		}
	}
	 */
}
