/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.ElifeActiveClientModel;
import au.com.BI.Objects.Key;
import au.com.BI.XML.ClientSettings;
/**
 * @author David Gavin
 *
 */
public class Loader {
	public static MainWindow myMain;
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		ClientSettings.getInstance().loadSettings();
		Vector requiredAttributes = new Vector();
		requiredAttributes.add("serverAddress");
		requiredAttributes.add("applicationXML");
		for (int index = 0; index < requiredAttributes.size(); index++) {
			if (ClientSettings
				.getInstance()
				.getSettings()
				.get((String) requiredAttributes.get(index))
				== null) {
				System.err.println(
					"elife.xml must contain attribute '"
						+ (String) requiredAttributes.get(index)
						+ "'");
				System.err.println("Exiting");
				System.exit(1);
			}
		}
		ElifeActiveClientModel.getInstance().loadClient(ClientSettings.getInstance().getSettings());
		Vector tempKeys = new Vector();
		for (int index = 0;
			index < ElifeActiveClientModel.getInstance().getKeys().size();
			index++) {
			tempKeys.add(
				new Key(((String) ElifeActiveClientModel.getInstance().getKeys().get(index))));
		}
		Vector keys = new Vector();
		Vector keyStrings = new Vector();
		Vector tempClientKeys = ElifeActiveClientModel.getInstance().getKeys();
		for (int index = 0; index < tempClientKeys.size(); index++) {
			if (!keyStrings.contains(tempClientKeys.get(index))) {
				keyStrings.add(tempClientKeys.get(index));
			}
		}
		for (int index = 0; index < keyStrings.size(); index++) {
			keys.add(new Key((String) keyStrings.get(index)));
		}
		ServerHandler.getInstance().setKeys(keys);
		Vector tempImages = new Vector();
		/*Core components*/
		tempImages.add("images/base/button-base_01");
		tempImages.add("images/base/button-base_02");
		tempImages.add("images/base/button-base_03");
		tempImages.add("images/base/button-base_04");
		tempImages.add("images/base/button-base_05");
		tempImages.add("images/base/button-base_06");
		tempImages.add("images/base/button-base_07");
		tempImages.add("images/base/button-base_08");
		tempImages.add("images/base/button-base_09");
		tempImages.add("images/highlight/button-highlight_01");
		tempImages.add("images/highlight/button-highlight_02");
		tempImages.add("images/highlight/button-highlight_03");
		tempImages.add("images/highlight/button-highlight_04");
		tempImages.add("images/highlight/button-highlight_06");
		tempImages.add("images/highlight/button-highlight_07");
		tempImages.add("images/highlight/button-highlight_08");
		tempImages.add("images/highlight/button-highlight_09");
		tempImages.add("images/levels/box-empty");
		tempImages.add("images/levels/box-full");
		tempImages.add("images/levels/ramp-0");
		tempImages.add("images/levels/ramp-20");
		tempImages.add("images/levels/ramp-40");
		tempImages.add("images/levels/ramp-60");
		tempImages.add("images/levels/ramp-80");
		tempImages.add("images/levels/ramp-full");
		//		serverHandler = new ServerHandler(eLifeSettings, tempKeys);
		myMain = new MainWindow(tempImages);
		//	serverHandler.connect();
		//	ServerHandler.getInstance().connect(GlobalOverrides.getInstance().getOverRides());
		myMain.setVisible(true);
	}
}