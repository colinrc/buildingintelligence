package au.com.BI.AV;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class AVFactory {
	Logger logger;
	
	private AVFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	
	private static AVFactory _singleton = null;
	public static AVFactory getInstance() {
		if (_singleton == null) {
			_singleton = new AVFactory();
		}
		return (_singleton);
	}
	/**
	 * Parses an audio device
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addAV(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		AV video = new AV (display_name,connectionType);

		video.setKey (key);
		video.setOutputKey(display_name);
		video.setCommand(command);
		video.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, video, type);
		targetDevice.addControlledItem(key, video, type);
		targetDevice.addControlledItem(display_name, video, DeviceType.OUTPUT);
	}
}
