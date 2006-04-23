/*
 * Created on Jun 10, 2004
 *
 */
package au.com.BI.Nuvo;

import java.util.logging.Level;
import java.util.logging.Logger;


public class NuvoHelper {
	protected Logger logger;

	public NuvoHelper () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	

	protected String buildSwitchCommand (int command,  String zone,String src,String machineNumber) {
		try {
			String outputArr ="";
			byte outputZone = Byte.parseByte(zone);
			byte machineCode = 1;
			if (src == null) {
				logger.log (Level.WARNING, "SRC selection entry for Nuvo is unknown ");
				return null;
			}
			if (machineNumber != null &&  !machineNumber.equals("")) {
				machineCode = Byte.parseByte(machineNumber);
			}
			byte machineInputSrc = 0;
			if (!src.equals("")) {
				machineInputSrc = Byte.parseByte(src);
			}

			return outputArr;
		} catch (NumberFormatException er) {
			logger.log (Level.WARNING, "Zone or machine entry for Nuvo is malformed " + zone + " : machine : " + machineNumber);
			return null;
		}
	}
	

	

}
