package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Util.StringUtils;

/**
 * a1%3A79%3Ac5%3A8f%3Ab6%3A2c status - 1 tags:glad subscribe:0
 * @author dcummins
 *
 */
public class PlayerStatus extends SlimServerCommand {
	private String playerId;
	private String start;
	private int itemsPerResponse;
	private LinkedList<SongInfoTag> tags;
	private String charset;
	private String subscribe;
	
	public PlayerStatus() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		start = "-";
		tags = new LinkedList<SongInfoTag>();
		playerId = "";
		itemsPerResponse = 1;
		charset = "";
		subscribe = "0";
		tags.add(SongInfoTag.GENRE);
		tags.add(SongInfoTag.ALBUM);
		tags.add(SongInfoTag.ARTIST);
		tags.add(SongInfoTag.DURATION);
		tags.add(SongInfoTag.ALBUM_ID);
		tags.add(SongInfoTag.TRACK_NUMBER);
		tags.add(SongInfoTag.COVERART);
	}

	public String getCharset() {
		return charset;
	}

	public void setCharset(String charset) {
		this.charset = charset;
	}

	public int getItemsPerResponse() {
		return itemsPerResponse;
	}

	public void setItemsPerResponse(int itemsPerResponse) {
		this.itemsPerResponse = itemsPerResponse;
	}

	public Logger getLogger() {
		return logger;
	}

	public void setLogger(Logger logger) {
		this.logger = logger;
	}

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	public String getStart() {
		return start;
	}

	public void setStart(String start) {
		this.start = start;
	}

	public String getSubscribe() {
		return subscribe;
	}

	public void setSubscribe(String subscribe) {
		this.subscribe = subscribe;
	}

	public LinkedList<SongInfoTag> getTags() {
		return tags;
	}
	public void setTags(LinkedList<SongInfoTag> tags) {
		this.tags = tags;
	}

	@Override
	public String buildCommandString() {
		StringBuilder commandString = new StringBuilder();
		
		if (StringUtils.isNullOrEmpty(playerId)) {
			return "";
		} else {
			try {
				commandString.append(URLEncoder.encode(playerId, "UTF-8"));
			} catch (UnsupportedEncodingException e) {
				logger.log(Level.INFO, "UTF-8 not supported");
			}
		}
		
		commandString.append(" status " + start + " " + itemsPerResponse);
		
		if (tags.size() > 0) {
			commandString.append(" tags:");
			for (SongInfoTag tag: tags) {
				commandString.append(tag.getValue());
			}
		}
		
		if (!StringUtils.isNullOrEmpty(charset)) {
			commandString.append(" charset:" + charset);
		}
		
		if (!StringUtils.isNullOrEmpty(subscribe)) {
			commandString.append(" subscribe:" + subscribe);
		}
		
		return commandString.toString();
	}
	
	
}
