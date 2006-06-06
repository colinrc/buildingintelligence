/*
 * Created on 30/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.DataModel;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Vector;

import org.kxml2.io.KXmlParser;
import org.kxml2.kdom.Document;
import org.kxml2.kdom.Element;
import org.kxml2.kdom.Node;

/**
 * @author David
 *
 * 
 * 
 */
public class eLifeActiveLoader {
	private HashMap globalOverrides;
	private Vector icons;
	private Vector keys;
	private Vector rooms;
	/**
	 * 
	 */
	public eLifeActiveLoader(HashMap inHashMap) {
		File configFile = null;
		globalOverrides = new HashMap();
		rooms = new Vector();
		icons = new Vector();
		keys = new Vector();
		Document doc = new Document();
		try {
			configFile =
				new File(System.getProperty("user.dir"), (String) inHashMap.get("applicationXML"));
			KXmlParser parser = new KXmlParser();
			FileInputStream is = new FileInputStream(configFile);
			parser.setInput(new InputStreamReader(is));
			doc.parse(parser);
			Element docRoot = doc.getRootElement();
			if (docRoot.getName().equals("application")) {
				int childCount = docRoot.getChildCount();
				for (int index = 0; index < childCount; index++) {
					if (docRoot.getType(index) != Node.ELEMENT) {
						continue;
					}
					Element currentNode = (Element) docRoot.getElement(index);
					if (currentNode.getName().equals("room")) {
						ActiveRoom newRoom = new ActiveRoom(icons,keys);
						newRoom.setXML(currentNode);
						rooms.add(newRoom);
					}
				}
			} else {
				System.err.println(
					"Error parsing client XML file. Expected \"application\" found \""
						+ docRoot.getName()
						+ "\"");
				System.exit(1);
			}
		} catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}
	}
	public Vector getIcons() {
		return icons;
	}
	public Vector getKeys() {
		return keys;
	}
	public Vector getRooms() {
		return rooms;
	}
}