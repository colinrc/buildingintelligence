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
import au.com.BI.XML.SettingsLoader;
import au.com.BI.DataModel.eLifeActiveLoader;
/**
 * @author David Gavin
 *
 */
public class Loader {
	public static ServerHandler serverHandler = null;
	public static MainWindow myMain;
	public static SettingsLoader setLoad = null;
	public static eLifeActiveLoader client = null;
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
		client = new eLifeActiveLoader(eLifeSettings);
		Vector tempKeys = new Vector();
		tempKeys.add(new Key("LIGHT1"));
		tempKeys.add(new Key("LIGHT2"));
		tempKeys.add(new Key("LIGHT3"));
		tempKeys.add(new Key("LIGHT4"));
		tempKeys.add(new Key("LIGHT5"));
		tempKeys.add(new Key("LIGHT6"));
		tempKeys.add(new Key("LIGHT7"));
		tempKeys.add(new Key("LIGHT8"));
		tempKeys.add(new Key("LIGHT9"));
		tempKeys.add(new Key("LIGHT10"));
		tempKeys.add(new Key("LIGHT11"));
		tempKeys.add(new Key("LIGHT12"));
		tempKeys.add(new Key("LIGHT13"));
		tempKeys.add(new Key("LIGHT14"));
		tempKeys.add(new Key("LIGHT15"));
		tempKeys.add(new Key("LIGHT16"));
		tempKeys.add(new Key("LIGHT17"));
		tempKeys.add(new Key("LIGHT18"));
		tempKeys.add(new Key("LIGHT19"));
		tempKeys.add(new Key("LIGHT20"));
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
		tempImages.add("lib/icons/aircon-off");
		tempImages.add("lib/icons/aircon");
		tempImages.add("lib/icons/blinds-closed");
		tempImages.add("lib/icons/blinds-open");
		tempImages.add("lib/icons/door-closed");
		tempImages.add("lib/icons/door-open");
		tempImages.add("lib/icons/fan-off");
		tempImages.add("lib/icons/fan");
		tempImages.add("lib/icons/heater-off");
		tempImages.add("lib/icons/heater");
		tempImages.add("lib/icons/led-off");
		tempImages.add("lib/icons/led-green");
		tempImages.add("lib/icons/power-red");
		tempImages.add("lib/icons/power-green");
		tempImages.add("lib/icons/sprinkler-off");
		tempImages.add("lib/icons/sprinkler");
		tempImages.add("lib/icons/sprinkler2-off");
		tempImages.add("lib/icons/sprinkler2");
		tempImages.add("lib/icons/volume-down");
		tempImages.add("lib/icons/volume-up");
		serverHandler = new ServerHandler(eLifeSettings, tempKeys);
		myMain = new MainWindow(serverHandler, tempImages, client);
		serverHandler.connect();
		myMain.setVisible(true);
	}
}