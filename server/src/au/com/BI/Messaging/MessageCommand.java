/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Messaging;
import java.util.LinkedList;
import java.util.List;

import org.jdom.Element;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;

/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class MessageCommand extends Command implements CommandInterface {


    private int messageType = CommandInterface.Message;
	public long	originatingID;
	protected String title = "";
	protected String icon = "";
	protected String autoclose = "";
	protected String hideclose = "";
	protected String content = "";
	protected Element element;
	protected Element messageFromFlash;
	protected String target = AddressBook.ALL;
	protected String targetUser = "";
	protected List <NameIdentifier>nameIdentifier = null;
	
	public MessageCommand ()
	{
	    super();
		originatingID = 0 ;
		messageFromFlash = null;
		nameIdentifier = new LinkedList<NameIdentifier>();
	} 


	public boolean isUserControllerCommand() {
		return false;
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
		return false;
	}
	
	public void addNameIdentifier(String user, String client){
		NameIdentifier name = new NameIdentifier(user,client);
		this.nameIdentifier.add(name);
		
	}
	
    public MessageCommand clone() throws CloneNotSupportedException {
    	
    	MessageCommand newCopy;
			boolean madeCopy = false;
			try {
				newCopy = this.getClass().newInstance();
	    		//Command newCopy = new  Command ();
		    	
				if (this.messageType == CommandInterface.Message){
					madeCopy = true;
					newCopy.setMessageType(CommandInterface.Message);
					newCopy.setDisplayName(displayName);
					newCopy.setTitle(title);
					newCopy.setIcon(icon);
					newCopy.setContent(content);
					newCopy.setAutoclose(autoclose);
					newCopy.setHideclose(hideclose);
					newCopy.setTarget(target);
					newCopy.setTargetUser(targetUser);
					newCopy.setKey(key);
				}
	
				if (this.messageType == CommandInterface.ID){
					madeCopy = true;
	    			MessageCommand newCommand = new MessageCommand();
	    			newCommand.setMessageType(CommandInterface.ID);
					
					for (NameIdentifier j : nameIdentifier ){
						String clientName = j.getClientName();
						String userName = j.getUserName();
						newCopy.addNameIdentifier(userName, clientName);
					}
	    		} 
	  
				if (madeCopy){
					return newCopy;    		
				}else {
					return null;
				}
			} catch (InstantiationException ex){
				throw new CloneNotSupportedException (ex.getMessage());
			} catch (IllegalAccessException e) {
				throw new CloneNotSupportedException (e.getMessage());
			}
    }
    
    public boolean equals(Object toTest) {
    	
    		if (toTest instanceof au.com.BI.Messaging.MessageCommand ){
    			if (this.messageType == CommandInterface.Message){
	    			MessageCommand toTestCommand = (MessageCommand)toTest;
	    				        
	    			if (!key.equals(toTestCommand.getKey())) return false;
		          	if (!displayName.equals(toTestCommand.getDisplayName())) return false;
		          	if (!title.equals(toTestCommand.getTitle())) return false;
		          	if (!icon.equals(toTestCommand.getIcon())) return false;
		          	if (!content.equals(toTestCommand.getContent())) return false;
		          	if (!autoclose.equals(toTestCommand.getAutoclose())) return false;
		          	if (!this.hideclose.equals(toTestCommand.getHideclose())) return false;
		          	if (!this.target.equals(toTestCommand.getTarget())) return false;
		          	if (!this.targetUser.equals(toTestCommand.getTargetUser())) return false;
    			}

    			if (this.messageType == CommandInterface.ID){
    				
    				int i = 0;
    				for (NameIdentifier j : nameIdentifier ){
    					String clientName = j.getClientName();
    					String userName = j.getUserName();
    					NameIdentifier id = nameIdentifier.get(i);
    					if (!(clientName.equals(id.getClientName()) && userName.equals(id.getUserName()) )){
    							return false;
    					}
    					i ++;
    				}
     			}

	         	return true;
    		} 
  
    		else {     		
    			return super.equals (toTest);
    		}
    }
	/**
	 * Used to populate a command from an XML element.
	 * @param element
	 */
	public void setFromElement (Element element){
	    String messageType = element.getName();
	    boolean found = false;
	    

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

	    if (this.messageType == CommandInterface.Message) {
			element = new Element ("MESSAGE");
	
			element.setAttribute ("TITLE", title);
			element.setAttribute ("CONTENT", content);
			element.setAttribute ("ICON", icon);
			element.setAttribute ("AUTOCLOSE", autoclose);
			element.setAttribute ("HIDECLOSE", hideclose);
			element.setAttribute ("TARGET",target);
			element.setAttribute ("TARGET_USER",targetUser);
	    }
	    
	    if (this.messageType == CommandInterface.ID) {
			element = new Element ("CLIENT_IDS");
			for (NameIdentifier i: nameIdentifier){
				Element elm = new Element ("CLIENT_ID");
				elm.setAttribute("KEY", "ID");			
				elm.setAttribute("NAME", i.getClientName());
				elm.setAttribute("USER", i.getUserName());
				element.addContent(elm);
			}
	
	    }
	    
	    if (this.messageType == CommandInterface.RawElement) {
	        element = this.element;
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
		if (target != null && target.equals ("") )
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
}
