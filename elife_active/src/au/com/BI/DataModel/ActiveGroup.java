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
public class ActiveGroup extends BIObject {
	private String name;
	private String displayIcons;
	private Vector controls;
	/**
	 * @param icons
	 * @param keys
	 */
	public ActiveGroup(Vector icons, Vector keys) {
		super(icons, keys);
		controls = new Vector();
		// TODO Auto-generated constructor stub
	}
	public void setXML(Element inNode) {
		if (inNode.getName().equals("group")) {
			int attCount = inNode.getAttributeCount();
			for (int index = 0; index < attCount; index++) {
				if (inNode.getAttributeName(index).equals("name")) {
					name = inNode.getAttributeValue(index);
				}
				if (inNode.getAttributeName(index).equals("icons")) {
					displayIcons = inNode.getAttributeValue(index);
					addIcon(displayIcons.substring(0, displayIcons.indexOf(",")));
					addIcon(displayIcons.substring(displayIcons.indexOf(",") + 1));
				}
			}
			int childCount = inNode.getChildCount();
			for (int index = 0; index < childCount; index++) {
				if (inNode.getType(index) != Node.ELEMENT) {
					continue;
				}
				Element currentNode = (Element) inNode.getElement(index);
				if (currentNode.getName().equals("control")) {
					ActiveControl newControl = new ActiveControl(icons, keys);
					newControl.setXML(currentNode);
					controls.add(newControl);
				}
			}
		} else {
			System.err.println(
				"Error parsing client XML file. Expected \"group\" found \""
					+ inNode.getName()
					+ "\"");
			System.exit(1);
		}
	}
	public String getIcons() {
		return displayIcons;
	}
	public String getName() {
		return name;
	}
	public Vector getControls() {
		return controls;
	}
}
