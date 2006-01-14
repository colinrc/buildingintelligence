/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Comms;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.User.*;
import au.com.BI.Util.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class CommsCommand extends Command implements CommandInterface{
	protected String actionCode;
	protected int actionType = CommDevice.UnkownCommand;
	protected DeviceType srcCommand;
	protected byte[] commandBytes;
	public boolean sent = false;
	public boolean sentSuccess = false;
	protected boolean keepForHandshake = false;


	// public static int RawText = 1;
	
	public String port;
	
	public CommsCommand ()
	{
	    super();
		commandBytes = null;
		actionCode = "";
	}
	
	public boolean isCommsCommand () {
		return true;
	}

	
	public boolean hasByteArray() {
		if (commandBytes != null)
			return true;
		else 
			return false;
	}
	
	public void setCommandBytes (byte[] commandBytes) {
		this.commandBytes = commandBytes;
	}
	
	public byte[] getCommandBytes() {
		return commandBytes;
	}

	public CommsCommand (String key,String commandCode,User user)
	{
		super (key,commandCode,user);
	}
	

	public CommsCommand (String key,String commandCode, User user,String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}
	
	public void setPort (String port){
		this.port = port;
	}
	
	/**
	 * @return Returns the actionCode.
	 */
	public String getActionCode() {
	    if (actionCode == null)
	        return "";
	    else
	        return actionCode;
	}
	/**
	 * @param actionCode The actionCode to set.
	 */
	public void setActionCode(String actionCode) {
		this.actionCode = actionCode;
	}

	/**
	 * @return Returns the actionType.
	 */
	public int getActionType() {
		return actionType;
	}
	/**
	 * @param actionType The actionType to set.
	 */
	public void setActionType(int actionType) {
		this.actionType = actionType;
	}
	/**
	 * @return Returns the srcCommand.
	 */
	public DeviceType getSrcCommand() {
		return srcCommand;
	}
	/**
	 * @param srcCommand The srcCommand to set.
	 */
	public void setSrcCommand(DeviceType srcCommand) {
		this.srcCommand = srcCommand;
	}
	/**
	 * @return Returns the sent.
	 */
	public boolean isSent() {
		return sent;
	}
	/**
	 * @param sent The sent to set.
	 */
	public void setSent(boolean sent) {
		this.sent = sent;
	}
	/**
	 * @return Returns the sentSuccess.
	 */
	public boolean isSentSuccess() {
		return sentSuccess;
	}
	/**
	 * @param sentSuccess The sentSuccess to set.
	 */
	public void setSentSuccess(boolean sentSuccess) {
		this.sentSuccess = sentSuccess;
	}
    /**
     * @return Returns the keepForHandshake.
     */
    public boolean isKeepForHandshake() {
        return keepForHandshake;
    }
    /**
     * @param keepForHandshake The keepForHandshake to set.
     */
    public void setKeepForHandshake(boolean keepForHandshake) {
        this.keepForHandshake = keepForHandshake;
    }
}
