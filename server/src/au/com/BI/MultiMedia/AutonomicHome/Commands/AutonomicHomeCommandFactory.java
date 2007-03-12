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
			String[] words = unparsedCommand.split(" ");
			
			if (words[0].equalsIgnoreCase("ReportState")) {
				command = parseReportState(words);
			} else if (words[0].equalsIgnoreCase("Instance")) {
				command = parseInstance(words);
			}
			
			if (command == null) {
				logger.log(Level.INFO, "Command cannot be parsed :" + unparsedCommand);
				return null;
			} else {
				return command;
			}
		} catch (AutonomicHomeCommandNotFoundException e) {
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
	 */
	public AutonomicHomeCommand parseReportState(String[] words) 
		throws AutonomicHomeCommandNotFoundException {
		
		if (words.length != 3) {
			throw new AutonomicHomeCommandNotFoundException("ReportState command identified but did not have enough arguments. 3 expected but " + words.length + " returned.");
		}
		
		ReportState command = new ReportState();
		command.setInstance(words[1]);
		
		String[] value = words[2].split("=");
		
		StateType type = StateType.getByDescription(value[0]);
		
		if (type == null) {
			throw new AutonomicHomeCommandNotFoundException("ReportState command identified but does not have a recognised type: " + value[0]);
		}
		
		command.setType(type);
		command.setValue(value[1]);
		
		return command;
	}
	
	public AutonomicHomeCommand parseInstance(String[] words)
		throws AutonomicHomeCommandNotFoundException {
		
		if (words.length != 2) {
			throw new AutonomicHomeCommandNotFoundException("Instance command identified but did not have enough arguments.  2 expected but " + words.length + " returned.");
		}
		
		SetInstanceReply command = new SetInstanceReply();
		
		// remove any double quotes
		words[1] = words[1].replaceAll("\"", "");
		logger.log(Level.INFO, "Report instance is " + words[1]);
		command.setInstance(words[1]);
		
		return command;
	}
}
