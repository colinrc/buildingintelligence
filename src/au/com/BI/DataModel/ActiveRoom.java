/*
 * Created on 30/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.DataModel;

import java.util.Vector;

import org.kxml2.kdom.Element;
import org.kxml2.kdom.Node;

/**
 * @author David
 *
 * 
 * 
 */
public class ActiveRoom extends BIObject {
	private Vector groups;
	private String name;
	
	/**
	 * @param icons
	 * @param keys
	 */
	public ActiveRoom(Vector icons, Vector keys) {
		super(icons, keys);
		// TODO Auto-generated constructor stub
		groups = new Vector();
		// TODO Auto-generated constructor stub
	}
	public void setXML(Element inNode) {
		if (inNode.getName().equals("room")) {
			int attCount = inNode.getAttributeCount();
			for (int index = 0; index < attCount; index++) {
				if (inNode.getAttributeName(index).equals("name")) {
					name = inNode.getAttributeValue(index);
					break;
				}
			}
			int childCount = inNode.getChildCount();
			for (int index = 0; index < childCount; index++) {
				if (inNode.getType(index) != Node.ELEMENT) {
					continue;
				}
				Element currentNode = (Element) inNode.getElement(index);
				if (currentNode.getName().equals("group")) {
					ActiveGroup newGroup = new ActiveGroup(icons, keys);
					newGroup.setXML(currentNode);
					groups.add(newGroup);
				}
			}
		} else {
			System.err.println(
				"Error parsing client XML file. Expected \"room\" found \""
					+ inNode.getName()
					+ "\"");
			System.exit(1);
		}
	}
	public Vector getGroups() {
		return groups;
	}
	public String getName(){
		return name;
	}
}
