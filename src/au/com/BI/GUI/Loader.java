/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.util.HashMap;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.Key;
import au.com.BI.Util.ImageLoader;
import au.com.BI.XML.ClientLoader;
import au.com.BI.XML.SettingsLoader;
/**
 * @author David Gavin
 *
 */
public class Loader {
	public static ServerHandler serverHandler = null;
	public static MainWindow myMain;
	public static SettingsLoader setLoad = null;
	public static ClientLoader client= null;
	public static ImageLoader imageLoader = null;
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		setLoad = new SettingsLoader();
		HashMap eLifeSettings = new HashMap();
		eLifeSettings = setLoad.loadSettings(eLifeSettings);
		if (eLifeSettings.get("serverAddress") == null) {
			System.err.println("elife.xml must contain attribute 'serverAddress'");
			System.err.println("Exiting");
			System.exit(1);
		}
		if (eLifeSettings.get("applicationXML") == null) {
			System.err.println("elife.xml must contain attribute 'applicationXML'");
			System.err.println("Exiting");
			System.exit(1);
		}
		client = new ClientLoader(eLifeSettings);
		Vector tempKeys = new Vector();
		tempKeys.add(new Key("LIGHT1"));
		tempKeys.add(new Key("LIGHT2"));
		Vector tempImages = new Vector();
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
		tempImages.add("lib/icons/light-bulb-off");
		tempImages.add("lib/icons/light-bulb");
		serverHandler = new ServerHandler(eLifeSettings,tempKeys);
		myMain = new MainWindow(serverHandler,tempImages);
		myMain.setVisible(true);
	}
}