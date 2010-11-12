package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Volume extends SlimServerCommand {
	
	private String playerId;
	private float volume;
	private boolean volumeUp;
	private boolean volumeDown;
	private boolean volumeQuery;
		
	public Volume() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	public float getVolume() {
		return volume;
	}

	public void setVolume(float volume) {
		this.volume = volume;
	}

	public boolean isVolumeDown() {
		return volumeDown;
	}

	public void setVolumeDown(boolean volumeDown) {
		this.volumeDown = volumeDown;
	}

	public boolean isVolumeUp() {
		return volumeUp;
	}

	public void setVolumeUp(boolean volumeUp) {
		this.volumeUp = volumeUp;
	}
	
	public boolean isVolumeQuery() {
		return volumeQuery;
	}

	public void setVolumeQuery(boolean volumeQuery) {
		this.volumeQuery = volumeQuery;
	}

	@Override
	public String buildCommandString() {
		String commandString = "";
		
		try {
			commandString += URLEncoder.encode(playerId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		commandString += " mixer volume ";
		
		if (volumeUp) {
			commandString += "+5";
		} else if (volumeDown) {
			commandString += "-5";
		} else if (volumeQuery) {
			commandString += "?";
		} else {
			commandString += volume;
		}
		
		return commandString;
	}
}


