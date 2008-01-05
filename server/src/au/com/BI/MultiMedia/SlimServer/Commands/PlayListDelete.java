package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PlayListDelete extends SlimServerCommand {
	private String playerId;
	private int songIndex;
	private Logger logger;
	
	public PlayListDelete() {
		songIndex = -1;
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	public int getSongIndex() {
		return songIndex;
	}

	public void setSongIndex(int songIndex) {
		this.songIndex = songIndex;
	}
	

	@Override
	public String buildCommandString() {
		String commandString = "";
		
		try {
			commandString += URLEncoder.encode(playerId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		commandString += " playlist delete";
		
		if (songIndex != -1) {
			commandString += " " + songIndex;
		}
		
		return commandString;
	}
}
