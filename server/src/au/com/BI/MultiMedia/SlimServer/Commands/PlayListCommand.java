package au.com.BI.MultiMedia.SlimServer.Commands;

import au.com.BI.Util.Type;

public class PlayListCommand extends Type {
	
	public static final PlayListCommand LOAD = new PlayListCommand("load", "LOAD");
	public static final PlayListCommand ADD = new PlayListCommand("add","ADD");
	public static final PlayListCommand INSERT = new PlayListCommand("insert","INSERT");
	public static final PlayListCommand DELETE = new PlayListCommand("delete","DELETE");
	
	private PlayListCommand(String value, String desc) {
		super(value, desc);
	}
	
	public static PlayListCommand getByValue(String value) {
		return((PlayListCommand)PlayListCommand.getByValue(PlayListCommand.class,value));
	}
	
	public static PlayListCommand getByDescription(String description) {
		return((PlayListCommand)PlayListCommand.getByDescription(PlayListCommand.class, description));
	}
}
