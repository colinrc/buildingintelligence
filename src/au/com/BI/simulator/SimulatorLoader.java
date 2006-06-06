/*
 * Created on 22/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.util.HashMap;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.Key;
import au.com.BI.DataModel.eLifeActiveLoader;
import au.com.BI.Serial.SerialHandler;
import au.com.BI.Util.ImageLoader;
import au.com.BI.XML.SettingsLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorLoader {
	public static ServerHandler serverHandler = null;
	public static SimulatorWindow myMain;
	public static SettingsLoader setLoad = null;
	public static eLifeActiveLoader client = null;
	public static ImageLoader imageLoader = null;
	public static SerialHandler serialHandle = null;
	/**
	 * 
	 */
	public SimulatorLoader() {
		super();
		// TODO Auto-generated constructor stub
	}
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
		tempImages.add("images/elife_active/home-on");
		tempImages.add("images/elife_active/home-on-yellow");
		tempImages.add("images/elife_active/home-off");
		tempImages.add("images/elife_active/up-on");
		tempImages.add("images/elife_active/up-on-yellow");
		tempImages.add("images/elife_active/up-off");
		tempImages.add("images/elife_active/down-on");
		tempImages.add("images/elife_active/down-on-yellow");
		tempImages.add("images/elife_active/down-off");
		tempImages.add("images/elife_active/ok-on");
		tempImages.add("images/elife_active/ok-on-yellow");
		tempImages.add("images/elife_active/ok-off");
		tempImages.add("images/elife_active/elife-base");
		tempImages.add("images/elife_active/eman-on");
		tempImages.add("images/elife_active/eman-off");
		tempImages.add("images/elife_active/wheel-clicker-on");
		tempImages.add("images/elife_active/wheel-clicker-on-yellow");
		tempImages.add("images/elife_active/wheel-on");
		tempImages.add("images/elife_active/wheel-off");
		Vector tempKeys = new Vector();
		for(int index=0;index<client.getKeys().size();index++){
			tempKeys.add(new Key(((String)client.getKeys().get(index))));
		}
		serverHandler = new ServerHandler(eLifeSettings, tempKeys);
		serialHandle = new SerialHandler(serverHandler);
		myMain = new SimulatorWindow(serverHandler, tempImages, client,serialHandle);
		serverHandler.connect();
		myMain.setVisible(true);
	}
}
