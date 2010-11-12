package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Power extends SlimServerCommand {
	
	private String playerId;
	private boolean power;
	private boolean powerQuery;
		
	public Power() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	public boolean isPower() {
		return power;
	}

	public void setPower(boolean power) {
		this.power = power;
	}

	public boolean isPowerQuery() {
		return powerQuery;
	}

	public void setPowerQuery(boolean powerQuery) {
		this.powerQuery = powerQuery;
	}

	@Override
	public String buildCommandString() {
		String commandString = "";
		
		try {
			commandString += URLEncoder.encode(playerId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		commandString += " power ";
		
		if (powerQuery) {
			commandString += "?";
		} else if (power) {
			commandString += "1";
		} else if (!power) {
			commandString += "0";
		}
		
		return commandString;
	}
}


