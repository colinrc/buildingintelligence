/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Flash;
import org.jdom.Element;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Messaging.*;
import au.com.BI.User.*;

/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class ClientCommand extends Command implements CommandInterface {

	/**
	public static final int RawXML = 1;
	public static final int GUIControlActivate = 3;
	public static final int LightInstantOn = 10;
	public static final int LightInstantOff = 11;
	**/
    public int messageType = CommandInterface.Control;
	public long	originatingID;
	protected String title;
	protected String icon;
	protected String autoclose;
	protected String hideclose;
	protected String content;
	protected Element element;
	protected Element messageFromFlash;
	protected String target = AddressBook.ALL;
	protected String targetUser = "";
	protected boolean broadcast = true;
	
	public ClientCommand ()
	{
	    super();
		originatingID = 0 ;
		messageFromFlash = null;
	}

	public ClientCommand (String key,String commandCode,User user)
	{
		super (key,commandCode, user);
		originatingID = 0 ;
		messageFromFlash = null;
	}
	

	public ClientCommand (String key,String commandCode, User user,String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
		originatingID = 0 ;
		messageFromFlash = null;
	}
	public ClientCommand (String key,String commandCode, User user,String extraInfo, String extra2, String extra3, String extra4, String extra5)
	{
		super (key, commandCode,user,extraInfo);
		super.setExtra2Info(extra2);
		super.setExtra3Info(extra3);
		super.setExtra4Info(extra4);
		super.setExtra5Info(extra5);
		originatingID = 0 ;
		messageFromFlash = null;
	}

	public boolean isUserControllerCommand() {
		return true;
	}

	public final String getCommandCode () {
	    if (messageType == CommandInterface.Control)
	        return commandCode;
	    else 
	        return "";
	}
	
	/**
	 * @return Returns the originatingID.
	 */
	public long getOriginatingID() {
		return originatingID;
	}
	/**
	 * @param originatingID The originatingID to set.
	 */
	public void setOriginatingID(long originatingID) {
		this.originatingID = originatingID;
	}
	
	public boolean isClient() {
		return true;
	}
	
	/**
	 * Used to populate a command from an XML element.
	 * @param element
	 */
	public void setFromElement (Element element){
	    String messageType = element.getName();
	    boolean found = false;
	    
	    if (messageType.equals ("CONTROL")) {
	    		super.setFromElement(element);
		    this.setTarget(element.getAttributeValue("TARGET"));
		    this.setTargetUser(element.getAttributeValue("TARGET_USER"));
	        this.setMessageType (CommandInterface.Control);
		    found = true;
	    }
	    if (messageType.equals ("MESSAGE")) {
	        this.setTitle(element.getAttributeValue("TITLE"));
	        this.setIcon(element.getAttributeValue("ICON"));
	        this.setContent(element.getAttributeValue("CONTENT"));
	        this.setAutoclose(element.getAttributeValue("AUTOCLOSE"));
	        this.setHideclose(element.getAttributeValue("HIDECLOSE"));
	        this.setTarget(element.getAttributeValue("TARGET"));
	        this.setTargetUser(element.getAttributeValue("TARGET_USER"));
	        this.setMessageType (CommandInterface.Message);
		    found = true;
	    }
	    if (messageType.equals ("VIDEO")) {
	        this.setKey(element.getAttributeValue("KEY"));
	        this.setCommand(element.getAttributeValue("COMMAND"));
	        this.setExtraInfo(element.getAttributeValue("EXTRA"));
		    this.setTarget(element.getAttributeValue("TARGET"));
		    this.setTargetUser(element.getAttributeValue("TARGET_USER"));
	        this.setMessageType (CommandInterface.Video);
		    found = true;
	    }
	    if (messageType.equals ("MACROS")) {
	        this.setMessageType (CommandInterface.RawElement);
		    this.setTarget(element.getAttributeValue("TARGET"));
		    this.setTargetUser(element.getAttributeValue("TARGET_USER"));
	        this.element = element;
		    found = true;
	    }
	    if (messageType.equals ("SCRIPT")) {
	        this.setMessageType (CommandInterface.RawElement);
		    this.setTarget(element.getAttributeValue("TARGET"));
		    this.setTargetUser(element.getAttributeValue("TARGET_USER"));
	        this.element = element;
		    found = true;
	    }
	    if (messageType.equals ("events")) {
	        this.setMessageType (CommandInterface.RawElement);
		    this.setTarget(element.getAttributeValue("TARGET"));
		    this.setTargetUser(element.getAttributeValue("TARGET_USER"));
	        this.element = element;	        
		    found = true;
	    }
	    if (!found) {
	        this.setMessageType (CommandInterface.RawElement);
		    this.setTarget(element.getAttributeValue("TARGET"));
		    this.setTargetUser(element.getAttributeValue("TARGET_USER"));
	        this.element = element;
		    found = true;
	    }
	}
    /**
     * @return Returns the messageType.
     */
    public int getMessageType() {
        return messageType;
    }
    /**
     * @param messageType The messageType to set.
     */
    public void setMessageType(int messageType) {
        this.messageType = messageType;
    }
    /**
     * @return Returns the autoclose.
     */
    public String getAutoclose() {
        return autoclose;
    }
    /**
     * @param autoclose The autoclose to set.
     */
    public void setAutoclose(String autoclose) {
    		if (autoclose != null)
    			this.autoclose = autoclose;
    		else
    			this.autoclose = "";
    }
    /**
     * @return Returns the icon.
     */
    public String getIcon() {
        return icon;
    }
    /**
     * @param icon The icon to set.
     */
    public void setIcon(String icon) {
    		if (icon != null)
    			this.icon = icon;
    		else
    			icon = "";
    }
    /**
     * @return Returns the title.
     */
    public String getTitle() {
        return title;
    }
    /**
     * @param title The title to set.
     */
    public void setTitle(String title) {
    		if (title != null)
    			this.title = title;
    		else
    			this.title = "";
    }
    
	public Element getXMLCommand () {
	    Element element = null;
	    if (this.messageType == CommandInterface.Control) {
	    		element = super.getXMLCommand();
	    }
	    if (this.messageType == CommandInterface.Message) {
			element = new Element ("MESSAGE");
	
			element.setAttribute ("TITLE", title);
			element.setAttribute ("CONTENT", content);
			element.setAttribute ("ICON", icon);
			element.setAttribute ("AUTOCLOSE", autoclose);
			element.setAttribute ("HIDECLOSE", hideclose);
	    }
	    if (this.messageType == CommandInterface.RawElement) {
	        element = this.element;
	    }
	    if (element != null) {
			element.setAttribute ("TARGET",target);
			element.setAttribute ("TARGET_USER",targetUser);
	    }
		
		return element;
	}
    /**
     * @return Returns the hideclose.
     */
    public String getHideclose() {
        return hideclose;
    }
    /**
     * @param hideclose The hideclose to set.
     */
    public void setHideclose(String hideclose) {
        this.hideclose = hideclose;
    }
    /**
     * @return Returns the content.
     */
    public String getContent() {
        return content;
    }
    /**
     * @param content The content to set.
     */
    public void setContent(String content) {
    		if (content != null)
    			this.content = content;
    		else
    			this.content = "";
    }
    /**
     * @return Returns the messageFromFlash.
     */
    public Element getMessageFromFlash() {
        return messageFromFlash;
    }
    /**
     * @param messageFromFlash The messageFromFlash to set.
     */
    public void setMessageFromFlash(Element messageFromFlash) {
        this.messageFromFlash = messageFromFlash;
    }

	public String getTarget() {
		return target;
	}

	public void setTarget(String target) {
		if (target != null && !target.equals ("") )
			this.target = target;
		else
			this.target = AddressBook.ALL;
	}

	public String getTargetUser() {
		return targetUser;
	}

	public void setTargetUser(String targetUser) {
		if (targetUser != null)
			this.targetUser = targetUser;
		else
			this.targetUser = "";
	}

	public boolean isBroadcast() {
		return broadcast;
	}

	public void setBroadcast(boolean broadcast) {
		this.broadcast = broadcast;
	}
}
