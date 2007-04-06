package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Util.StringUtils;

public class SlimServerCommandFactory {

	private static SlimServerCommandFactory _singleton;
	private Logger logger;
	
	private SlimServerCommandFactory() {
		logger = Logger.getLogger(SlimServerCommandFactory.class.getPackage().getName());
	}
	
	public static SlimServerCommandFactory getInstance() {
		if (_singleton == null) {
			_singleton = new SlimServerCommandFactory();
		}
		return (_singleton);
	}
	
	public SlimServerCommand getCommand(String unparsedCommand) {
		SlimServerCommand command = null;
		
		try {
			unparsedCommand = unparsedCommand.trim();
			
			String[] words = unparsedCommand.split(" ");
			
			if (!StringUtils.isNullOrEmpty(words[0])) {
				if (words[0].equals("albums")) {
					command = parseBrowseAlbumsReply(words);
				}
			}
			
			if (command == null) {
				logger.log(Level.INFO, "Command cannot be parsed :" + unparsedCommand);
				return null;
			} else {
				return command;
			}
		} catch (SlimServerCommandException e) {
			logger.log(Level.WARNING, "Command not found : " + e.getMessage());
			return null;
		}
	}
	
	public SlimServerCommand parseBrowseAlbumsReply(String[] words)
		throws SlimServerCommandException {
		BrowseAlbumsReply command = new BrowseAlbumsReply();
		int positionOfColon = 0;
		String tag = "";
		String value = "";

		// first should be the start
		try {
			Integer.parseInt(words[1]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		int expectedCount = 0;
		// second should be the how many is returned
		try {
			expectedCount = Integer.parseInt(words[2]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		Album album = null;
		for (int i=3; i< words.length; i++) {
			String word = words[i];
			try {
				word = URLDecoder.decode(word,"UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new SlimServerCommandException("Cannot use UTF-8 encoding", e);
			}
			
			positionOfColon = word.indexOf(":");
			tag = word.substring(0,positionOfColon);
			value = word.substring(positionOfColon+1);
			
			if (tag.equals("id")) {
				if (album != null) {
					command.getAlbums().add(album);
				}
				album = new Album();
				album.setId(value);
			} else if (tag.equals("album")) {
				if (album == null) {
					throw new SlimServerCommandException("Expected id tag first but got " + tag + " instead");
				}
				album.setAlbum(value);
			} else if (tag.equals("compilation")) {
				// todo: do something with the compilation flag
				if (value.equals("0")) {
					command.setCompilation(false);
				} else if (value.equals("1")) {
					command.setCompilation(true);
				} else {
					throw new SlimServerCommandException("Tried to set compilation flag but could not parse " + value + " to a boolean.");
				}
			} else if (tag.equals("count")) {
				try {
					command.setCount(Integer.parseInt(value));
				} catch (NumberFormatException e) {
					throw new SlimServerCommandException("Tried to set the total count of albums but could not parse " + value + " to an integer.");
				}
			}
		}
		
		if (album != null) {
			command.getAlbums().add(album);
		}
		
		return command;
	}
}
