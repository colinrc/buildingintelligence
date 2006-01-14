/*
 * Created on Jun 10, 2004
 *
 */
package au.com.BI.Tutondo;

import java.util.logging.Level;
import java.util.logging.Logger;


public class TutondoHelper {
	protected char STX = 2;
	protected char ETX = 3;
	protected Logger logger;

	public TutondoHelper () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	
	/**
	 * Convienience interface to the byte parameter function
	 * @param tutondoCommand
	 * @param tutondoParameter
	 * @param key
	 * @return
	 */
	protected byte[] buildTutondoCommand (int tutondoCommand, int tutondoParameter, String zone, boolean protocol) {
		return buildTutondoCommand ((byte)tutondoCommand,  (byte)tutondoParameter,  zone, protocol );
	}

	protected byte[] buildTutondoCommand (byte tutondoCommand, byte tutondoParameter, String zone, boolean protocolB) {
		if (protocolB) {
			return buildTutondoCommandB (tutondoCommand, tutondoParameter, zone);			
		} else {
			return buildTutondoCommandA (tutondoCommand, tutondoParameter, zone);			
		}
	}

	protected byte[] buildTutondoCommandA (byte tutondoCommand, byte tutondoParameter, String zone) {
		try {
			byte output[] = new byte [6];
			byte outputZone = Byte.parseByte(zone);
			if (outputZone == 0) outputZone = 1;
			output[0] = (byte)STX;
			output[1] = (byte) (tutondoCommand+48);
			output[2] = (byte) (outputZone+48);
			output[3] = (byte) (tutondoParameter+48);
			int checksum = tutondoCommand ^ tutondoParameter ^ outputZone;

			if (checksum == STX) {
				checksum = STX ^ 255;
			} 
			if (checksum == ETX) {
				checksum = ETX ^ 255;
			}
			output[4] = (byte)checksum;
			output[5] = (byte)ETX;
			return output;
		} catch (NumberFormatException er) {
			logger.log (Level.SEVERE, "Zone entry for Tutondo is malformed : " + zone);
			return null;
		}
	}
	
	protected byte[] buildTutondoCommandB (byte tutondoCommand, byte tutondoParameter, String zone) {
		String returnCode;
		returnCode = "W"+ Byte.toString(tutondoCommand) + "," + zone + "," + Byte.toString(tutondoParameter)+ "\r\n";
		return returnCode.getBytes();
	}

	/**
	 * @return Returns the sTX.
	 */
	public char getSTX() {
		return STX;
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setSTX(char stx) {
		this.STX = stx;
	}

	/**
	 * @return Returns the eTX.
	 */
	public char getETX() {
		return ETX;
	}
	/**
	 * @param etx The eTX to set.
	 */
	public void setETX(char etx) {
		ETX = etx;
	}
}
