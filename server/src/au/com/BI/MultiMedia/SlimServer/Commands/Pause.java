package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Pause extends SlimServerCommand {
	private String playerId;
	Logger logger;
	
	public Pause() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		// todo - can toggle or except 1 or 0
	}

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	@Override
	public String buildCommandString() {
		String commandString = "";
		
		try {
			commandString += URLEncoder.encode(playerId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		commandString += " pause";
		
		return commandString;
	}
}
