/*
 * Created on 28/06/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.DataModel;
import java.util.Vector;

import org.kxml2.kdom.Element;
/**
 * @author David
 *
 *
 *
 */
public class ActiveControl extends BIObject {
	private String icons;
	private String name;
	private String key;
	private String type;
	private String icon;
	private String extras;
	private String extra;
	private String extra2;
	private String extra3;
	private String extra4;
	private String extra5;
	private String command;
	private String interactive;
	/**
	 * @param icons
	 * @param keys
	 */
	public ActiveControl(Vector icons, Vector keys) {
		super(icons, keys);
		// TODO Auto-generated constructor stub
	}
	public void setXML(Element inNode) {
		if (inNode.getName().equals("control")) {
			int attCount = inNode.getAttributeCount();
			for (int index = 0; index < attCount; index++) {
				if (inNode.getAttributeName(index).equals("name")) {
					name = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("key")) {
					key = inNode.getAttributeValue(index);
					addKey(key);
				} else if (inNode.getAttributeName(index).equals("type")) {
					type = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("icons")) {
					icons = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("icon")) {
					icon = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("extras")) {
					extras = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("extra")) {
					extra = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("extra2")) {
					extra2 = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("extra3")) {
					extra3 = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("extra4")) {
					extra4 = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("extra5")) {
					extra5 = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("command")) {
					command = inNode.getAttributeValue(index);
				} else if (inNode.getAttributeName(index).equals("interactive")) {
					interactive = inNode.getAttributeValue(index);
				}
			}
		} else {
			System.err.println(
				"Error parsing client XML file. Expected \"control\" found \""
					+ inNode.getName()
					+ "\"");
			System.exit(1);
		}
	}
	public String getType() {
		return type;
	}
	public String getName() {
		return name;
	}
	public String getKey() {
		return key;
	}
	public String getIcons() {
		return icons;
	}
	public String getIcon() {
		return icon;
	}
	public String getExtras() {
		return extras;
	}
	public String getExtra() {
		return extra;
	}
	public String getExtra2() {
		return extra2;
	}
	public String getExtra3() {
		return extra3;
	}
	public String getExtra4() {
		return extra4;
	}
	public String getExtra5() {
		return extra5;
	}
	public String getCommand() {
		return command;
	}
	public String getInteractive() {
		return interactive;
	}
}