package au.com.BI.Command;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Attribute;
import org.jdom.Element;

import au.com.BI.Flash.ClientCommand;
import au.com.BI.Messaging.AddressBook;
import au.com.BI.Messaging.MessageCommand;
import au.com.BI.User.User;

public class ClientCommandFactory {
    protected Logger logger;
    protected AddressBook addressBook;
    protected long ID = 0;
	protected User user;
    
	public ClientCommandFactory() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	/**
	 * Process the XML document sent from the client
	 * 
	 * @param xmlDoc
	 *            A Sax representation of the document
	 */
	public ClientCommand processXML(Element rootElement) {

		String name = ""; // the name of the node
		String key = "";
		boolean commandBuilt = false;
		ClientCommand clientCommand = null;
		
		name = rootElement.getName();
		logger.log(Level.FINER, "ELEMENT " + name);

		if (name.equals("CONTROL")) {
			key = rootElement.getAttributeValue("KEY");
			if (key != null) {

				if (!commandBuilt && key.equals("KEYPAD")) {
					clientCommand = buildKeyPress(key, rootElement);
					commandBuilt = true;
				}
				if (!commandBuilt && key.equals("ID")) {
					String command = rootElement.getAttributeValue("COMMAND");
					String extra = rootElement.getAttributeValue("EXTRA");
					if (command.equals("name")) {
						synchronized (addressBook) {
							addressBook.setName(extra, ID);
						}
					}
					if (command.equals("user")) {
						synchronized (addressBook) {
							addressBook.setUser(extra, ID);
						}
					}
					commandBuilt = true;
				}
				if (!commandBuilt && clientCommand == null) {
					clientCommand = buildCommand(key, rootElement);
					commandBuilt = true;
				}
				if (clientCommand != null) {
					clientCommand.originatingID = ID;
					clientCommand.setMessageFromFlash(rootElement);
					return clientCommand;
				}
			}
		}
		if (name.equals("MESSAGE")) {
			clientCommand.originatingID = ID;
			clientCommand.setMessageFromFlash(rootElement);
			clientCommand.setBroadcast(false);
		}

		if (name.equals("LOGIN")) {
			String userName = (rootElement.getAttribute("USER")).getValue();
			String password = (rootElement.getAttribute("PASSWORD")).getValue();
			User user = new User(userName, password);
			this.setUser(user);
		}
		if (name.equals("MACROS")) {
			clientCommand.setMessageFromFlash(rootElement);
			clientCommand.setKey("MACRO");
			clientCommand.setCommand("saveList");

			clientCommand.originatingID = ID;
			clientCommand.setMessageFromFlash(rootElement);
		}
		return clientCommand;
	}

	public ClientCommand buildKeyPress(String key, Element rootElement) {
		String name = ""; // the name of the node
		String extra = "";

		Attribute extraAttribute = rootElement.getAttribute("EXTRA");
		if (extraAttribute != null)
			extra = extraAttribute.getValue();
		logger.log(Level.FINEST, "key " + extra);
		ClientCommand clientCommand = new ClientCommand("SYSTEM", "Keypress",
				user, extra);
		return clientCommand;

	}

	public ClientCommand buildMessage(Element rootElement) {
		String name = ""; // the name of the node
		ClientCommand newCommand = new ClientCommand();
		newCommand.setKey("MESSAGE");
		newCommand.setDisplayName("MESSAGE");
		newCommand.setMessageType(MessageCommand.Message);

		String title = rootElement.getAttributeValue("TITLE");
		if (title == null)
			title = "";
		newCommand.setTitle(title);

		String hideClose = rootElement.getAttributeValue("HIDECLOSE");
		if (hideClose == null)
			hideClose = "";
		newCommand.setHideclose(hideClose);

		String autoClose = rootElement.getAttributeValue("AUTOCLOSE");
		if (autoClose == null)
			autoClose = "";
		newCommand.setAutoclose(autoClose);

		String icon = rootElement.getAttributeValue("ICON");
		if (icon == null)
			icon = "";
		newCommand.setIcon(icon);

		String content = rootElement.getAttributeValue("CONTENT");
		if (content == null)
			content = "";
		newCommand.setContent(content);

		String target = rootElement.getAttributeValue("TARGET");
		if (target == null)
			target = "";
		newCommand.setTarget(target);

		String targetUser = rootElement.getAttributeValue("TARGET_USER");
		if (targetUser == null)
			targetUser = "";
		newCommand.setTargetUser(targetUser);

		return newCommand;
	}

	public ClientCommand buildCommand(String key, Element rootElement) {
		String name = ""; // the name of the node
		String command = rootElement.getAttributeValue("COMMAND");
		if (command == null)
			command = "";
		String extra = rootElement.getAttributeValue("EXTRA");
		if (extra == null)
			extra = "";
		String extra2 = rootElement.getAttributeValue("EXTRA2");
		if (extra2 == null)
			extra2 = "";
		String extra3 = rootElement.getAttributeValue("EXTRA3");
		if (extra3 == null)
			extra3 = "";
		String extra4 = rootElement.getAttributeValue("EXTRA4");
		if (extra4 == null)
			extra4 = "";
		String extra5 = rootElement.getAttributeValue("EXTRA5");
		if (extra5 == null)
			extra5 = "";
		logger.log(Level.FINER, "DISPLAY_NAME=" + key + " Command=" + command
				+ " extra=" + extra);
		ClientCommand clientCommand = new ClientCommand(key, command, user,
				extra, extra2, extra3, extra4, extra5);
		return clientCommand;
	}
	

	public AddressBook getAddressBook() {
		return addressBook;
	}

	public void setAddressBook(AddressBook addressBook) {
		this.addressBook = addressBook;
	}

	public long getID() {
		return ID;
	}

	public void setID(long sourceID) {
		this.ID = sourceID;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}


}
