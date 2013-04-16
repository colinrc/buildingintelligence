package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PlayListIndex extends SlimServerCommand {

	private String playerId;
	private int positiveIndex;
	private int negativeIndex;
	private int index;
	
	public PlayListIndex() {
		positiveIndex = -1;
		negativeIndex = -1;
		index = -1;
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public String getPlayerId() {
		return playerId;
	}
	
	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}
	
	public int getIndex() {
		return index;
	}

	public void setIndex(int index) {
		this.index = index;
	}

	public int getNegativeIndex() {
		return negativeIndex;
	}

	public void setNegativeIndex(int negativeIndex) {
		this.negativeIndex = negativeIndex;
	}

	public int getPositiveIndex() {
		return positiveIndex;
	}

	public void setPositiveIndex(int positiveIndex) {
		this.positiveIndex = positiveIndex;
	}

	@Override
	public String buildCommandString() {
		String commandString = "";
		
		try {
			commandString += URLEncoder.encode(playerId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		commandString += " playlist index ";
		

		if (index != -1) {
			commandString += index;
		} else if (positiveIndex != -1) {
			commandString += "+" + positiveIndex;
		} else if (negativeIndex != -1) {
			commandString += "-" + negativeIndex;
		} else {
			logger.log(Level.WARNING, "No index value provided to playlist index command");
		}
		
		return commandString;
	}
}
