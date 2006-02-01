package au.com.BI.Camera;

import au.com.BI.Util.Utility;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.AV.AVFactory;
import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class CameraFactory {
	Logger logger;
	
	private CameraFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	private static CameraFactory _singleton = null;
	public static CameraFactory getInstance() {
		if (_singleton == null) {
			_singleton = new CameraFactory();
		}
		return (_singleton);
	}

	/**
	 * Parses an camera device
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addCamera(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String fullKey = Utility.padString (key,2);
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		String zoom = element.getAttributeValue("ZOOM");
		Camera camera = new Camera (display_name,connectionType);

		camera.setKey (fullKey);
		camera.setOutputKey(display_name);
		camera.setCommand(command);
		camera.setGroupName(groupName);
		try {
			camera.setZoom(zoom);
		} catch (NumberFormatException ex) {
			logger.log(Level.INFO,"Camera zoom capabilities not specified, setting absolute zoom levels will not be possible");
		}

		targetDevice.addStartupQueryItem(fullKey, camera, type);
		targetDevice.addControlledItem(fullKey, camera, type);
		targetDevice.addControlledItem(display_name, camera, DeviceType.OUTPUT);
	}
}
