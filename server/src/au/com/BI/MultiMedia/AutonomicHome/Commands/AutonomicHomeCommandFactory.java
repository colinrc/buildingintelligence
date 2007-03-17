package au.com.BI.MultiMedia.AutonomicHome.Commands;

import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;


public class AutonomicHomeCommandFactory {

	private static AutonomicHomeCommandFactory _singleton = null;
	private Logger logger;
	private HashMap<String,AutonomicHomeCommand> commands;

	private AutonomicHomeCommandFactory() {
		super();
		commands = new HashMap();
		logger = Logger.getLogger(AutonomicHomeCommandFactory.class.getPackage().getName());
	}
	
	public static AutonomicHomeCommandFactory getInstance() {
		if (_singleton == null) {
			_singleton = new AutonomicHomeCommandFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Returns the parsed command.
	 * @param unparsedCommand
	 * @return
	 */
	public AutonomicHomeCommand getCommand(String unparsedCommand) {
		AutonomicHomeCommand command = null;
		
		try {
			unparsedCommand = unparsedCommand.trim();
			String[] words = unparsedCommand.split(" ");
			
			if (words[0].equalsIgnoreCase("ReportState")) {
				command = parseReportState(unparsedCommand);
			} else if (words[0].equalsIgnoreCase("Instance")) {
				command = parseInstance(unparsedCommand);
			} else if (words[0].equalsIgnoreCase("BeginAlbums")) {
				command = parseBeginAlbums(unparsedCommand);
			} else if (words[0].equalsIgnoreCase("Album")) {
				command = parseAlbum(unparsedCommand);
			} else if (words[0].equalsIgnoreCase("EndAlbums")) {
				command = parseEndAlbums(unparsedCommand);
			}
			
			if (command == null) {
				logger.log(Level.INFO, "Command cannot be parsed :" + unparsedCommand);
				return null;
			} else {
				return command;
			}
		} catch (AutonomicHomeCommandException e) {
			logger.log(Level.WARNING, "Command not found : " + e.getMessage());
			return null;
		}
	}
	
	/**
	 * Parses a ReportState message.
	 * A ReportState message will look like:
	 * <code>
	 * ReportState <instance> <type>=<value>
	 * </code>
	 * @param words
	 * @return
	 * @throws AutonomicHomeCommandNotFoundException
	 * @throws AutonomicHomeCommandException 
	 */
	public AutonomicHomeCommand parseReportState(String unparsedCommand) 
		throws AutonomicHomeCommandException {
		
		String[] words = unparsedCommand.split(" ");
		if (words.length != 3) {
			throw new AutonomicHomeCommandException("ReportState command identified but did not have enough arguments. 3 expected but " + words.length + " returned.");
		}
		
		ReportState command = new ReportState();
		command.setInstance(words[1]);
		
		String[] value = words[2].split("=");
		
		StateType type = StateType.getByDescription(value[0]);
		
		if (type == null) {
			throw new AutonomicHomeCommandException("ReportState command identified but does not have a recognised type: " + value[0]);
		}
		
		command.setType(type);
		command.setValue(value[1]);
		
		return command;
	}
	
	/**
	 * Parses a reply of the instance
	 * @param words
	 * @return
	 * @throws AutonomicHomeCommandNotFoundException
	 */
	public AutonomicHomeCommand parseInstance(String unparsedCommand)
		throws AutonomicHomeCommandException {
		
		String[] words = unparsedCommand.split(" ");
		if (words.length != 2) {
			throw new AutonomicHomeCommandException("Instance command identified but did not have enough arguments.  2 expected but " + words.length + " returned.");
		}
		
		SetInstanceReply command = new SetInstanceReply();
		
		// remove any double quotes
		words[1] = words[1].replaceAll("\"", "");
		logger.log(Level.INFO, "Report instance is " + words[1]);
		command.setInstance(words[1]);
		
		return command;
	}
	
	/**
	 * Parses the initial BeginAlbums command
	 * @param words
	 * @return
	 * @throws AutonomicHomeCommandException
	 */
	public AutonomicHomeCommand parseBeginAlbums(String unparsedCommand)
		throws AutonomicHomeCommandException {
		
		String[] words = unparsedCommand.split(" ");
		if (words.length != 2) {
			throw new AutonomicHomeCommandException("BeginAlbum command identified but did not have enough arguments. 2 expected but " + words.length);
		}
		
		BeginAlbumsReply command = new BeginAlbumsReply();
		
		// set the count on the command
		String[] value = words[1].split("=");
		
		int count;
		try {
			count = Integer.parseInt(value[1]);
		} catch (NumberFormatException e) {
			throw new AutonomicHomeCommandException("BeginAlbum command did not have an integer count: " + value[1]);
		}
		
		command.setCount(count);
		
		return command;
	}
	
	/**
	 * 
	 * @param words
	 * @return
	 * @throws AutonomicHomeCommandException
	 */
	public AutonomicHomeCommand parseAlbum(String unparsedCommand)
		throws AutonomicHomeCommandException {
		
		int firstSpace = unparsedCommand.indexOf(" ");
		int secondSpace = unparsedCommand.indexOf(" ", firstSpace+1);
		String guid = unparsedCommand.substring(firstSpace+1,secondSpace);
		String name = unparsedCommand.substring(secondSpace+1);
		name = name.replaceAll("\"", "");
		
		Album command = new Album(guid,name);
		
		return command;
	}
	
	/**
	 * 
	 * @param words
	 * @return
	 * @throws AutonomicHomeCommandException
	 */
	public AutonomicHomeCommand parseEndAlbums(String unparsedCommand)
		throws AutonomicHomeCommandException {
		
		String[] words = unparsedCommand.split(" ");
		if (words.length != 2) {
			throw new AutonomicHomeCommandException("End Albums command identified but did not have enough arguments. 2 expected but " + words.length);
		}
		
		EndAlbumsReply command = new EndAlbumsReply();
		
		return command;
	}
}
