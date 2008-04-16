/**
 * 
 */
package au.com.BI.MultiMedia;

import java.util.LinkedList;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.Fields;
import au.com.BI.JRobin.JRobinData;
import au.com.BI.User.User;

/**
 * @author David Cummins
 * 
 */
public class ArtistCommand implements CommandInterface {

	public String key = "";

	protected LinkedList<Artist> artists;

	protected String displayName = "";

	protected int targetDeviceModel = -1;

	protected long targetDeviceID = 0;

	protected long creationDate = 0;

	protected Object rrdValueObject;

	protected JRobinData jRobinData;

	protected boolean adminCommand = false;

	protected Logger logger;

	protected boolean scriptCommand = false;

	public User user;

	public CommandInterface clone() throws CloneNotSupportedException {

		ArtistCommand newCopy;
		try {
			newCopy = this.getClass().newInstance();
			// Command newCopy = new Command ();
			newCopy.setKey(this.getKey());
			newCopy.setCommand(this.getCommandCode());
			newCopy.setUser(this.getUser());
			newCopy.setScriptCommand(this.isScriptCommand());

			newCopy.setDisplayName(this.getDisplayName());
			newCopy.setTargetDeviceID(this.getTargetDeviceID());
			newCopy.setTargetDeviceModel(this.getTargetDeviceModel());
			newCopy.setAlbums((LinkedList<Artist>)artists.clone());
			return newCopy;
		} catch (InstantiationException e) {
			throw new CloneNotSupportedException("Cannot create new instance");
		} catch (IllegalAccessException e) {
			throw new CloneNotSupportedException("Cannot create new instance");
		}

	}

	public boolean equals(Object toTest) {
		if (toTest instanceof au.com.BI.Command.CommandInterface) {
			CommandInterface toTestCommand = (CommandInterface) toTest;
			if (!key.equals(toTestCommand.getKey()))
				return false;
			if (!displayName.equals(toTestCommand.getDisplayName()))
				return false;

			return true;
		} else {
			return super.equals(toTest);
		}
	}

	public void setJRobinData(au.com.BI.JRobin.JRobinData jRobinData) {
		this.jRobinData = jRobinData;
	}

	public JRobinData getJRobinData() {
		return this.jRobinData;
	}

	public ArtistCommand() {
		creationDate = System.currentTimeMillis();
		artists = new LinkedList<Artist>();
	}

	public ArtistCommand(String key, String commandCode, User user) {
		creationDate = System.currentTimeMillis();
		setKey(key);
		setCommand(commandCode);
		setUser(user);
	}

	/**
	 * Returns any of the fields from the command object
	 * 
	 * @return The requested field
	 */
	public String getValue(Fields commandField) {
		/*
		 * switch (commandField){ case COMMAND: return this.getCommandCode();
		 * 
		 * case KEY: return this.getKey();
		 * 
		 * case EXTRA: return this.getExtraInfo();
		 * 
		 * case EXTRA2: return this.getExtra2Info();
		 * 
		 * case EXTRA3: return this.getExtra3Info();
		 * 
		 * case EXTRA4: return this.getExtra4Info();
		 * 
		 * case EXTRA5: return this.getExtra5Info();
		 * 
		 * default: return "Unknown Field Requested"; }
		 */
		return "";
	}

	public boolean isCommsCommand() {
		return false;
	}

	/**
	 * By default client is false. Override if the command is generated by the
	 * AWT client.
	 */
	public boolean isClient() {
		return false;
	}

	/**
	 * Used to populate a command from an XML element.
	 * 
	 * @param element
	 */
	public void setFromElement(Element element) {
		/* this.setKey(element.getAttributeValue("KEY"));
		this.setCommand(element.getAttributeValue("COMMAND"));
		this.setExtraInfo(element.getAttributeValue("EXTRA"));
		this.setExtra2Info(element.getAttributeValue("EXTRA2"));
		this.setExtra3Info(element.getAttributeValue("EXTRA3"));
		this.setExtra4Info(element.getAttributeValue("EXTRA4"));
		this.setExtra5Info(element.getAttributeValue("EXTRA5")); */
	}

	/**
	 * By default client is false. Override if the command is generated by the
	 * flash client.
	 */
	public boolean isUserControllerCommand() {
		return false;
	}

	public final void setKey(String key) {
		if (key == null)
			this.key = "";
		else
			this.key = key;
	}

	public final String getKey() {
		return key;
	}

	public final User getUser() {
		return user;
	}

	public final void setUser(User user) {
		this.user = user;
	}

	public Element getXMLCommand() {
		Element element = new Element("artists");

		LinkedList albumElements = new LinkedList();
		
		for (Artist artist: artists) {
			albumElements.add(artist.getElement());
		}
		
		element.addContent(albumElements);

		return element;
	}

	/**
	 * @return Returns the displayName.
	 */
	public String getDisplayName() {
		return displayName;
	}

	/**
	 * @param displayName
	 *            The displayName to set.
	 */
	public void setDisplayName(String displayName) {
		this.displayName = displayName;
	}

	/**
	 * @param rrdValueObject
	 *            The value to be added to the rrd.
	 */
	public final void setRrdValueObject(Object rrdValueObject) {
		this.rrdValueObject = rrdValueObject;
	}

	/**
	 * @return Returns the rrdValueObject.
	 */
	public final Object getRrdValueObject() {
		return rrdValueObject;
	}

	/**
	 * @return Returns the targetDeviceModel.
	 */
	public int getTargetDeviceModel() {
		return targetDeviceModel;
	}

	/**
	 * @param targetDeviceModel
	 *            The targetDeviceModel to set.
	 */
	public void setTargetDeviceModel(int targetDeviceModel) {
		this.targetDeviceModel = targetDeviceModel;
	}

	public long getTargetDeviceID() {
		return targetDeviceID;
	}

	public void setTargetDeviceID(long ID) {
		this.targetDeviceID = ID;
	}

	public boolean cacheAllCommands() {
		return false;
	}

	public long getCreationDate() {
		return this.creationDate;
	}

	public boolean isAdminCommand() {
		return adminCommand;
	}

	public void setAdminCommand(boolean adminCommand) {
		this.adminCommand = adminCommand;
	}

	public boolean isScriptCommand() {
		return scriptCommand;
	}

	public void setScriptCommand(boolean scriptCommand) {
		this.scriptCommand = scriptCommand;
	}

	public String getCommandCode() {
		return null;
	}

	public String getExtra2Info() {
		return null;
	}

	public String getExtra3Info() {
		return null;
	}

	public String getExtra4Info() {
		return null;
	}

	public String getExtra5Info() {
		return null;
	}

	public String getExtraInfo() {
		return null;
	}

	public void setCommand(String command) {
		
	}

	public void setExtra2Info(String extra) {
		
	}

	public void setExtra3Info(String extra) {
		
	}

	public void setExtra4Info(String extra) {
		
	}

	public void setExtra5Info(String extra) {
		
	}

	public void setExtraInfo(String extra) {
		
	}

	public LinkedList<Artist> getArtists() {
		return artists;
	}

	public void setAlbums(LinkedList<Artist> artists) {
		this.artists = artists;
	}
	
	

}
