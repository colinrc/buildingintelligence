package au.com.BI.Camera;


import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

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
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		
		try  {
			String key = element.getAttributeValue("KEY");
		
			String command = element.getAttributeValue("COMMAND");
	
			String zoom = element.getAttributeValue("ZOOM");
			Camera camera = new Camera (display_name,connectionType);
			String fullKey = targetDevice.formatKey (key,camera);
			camera.setKey (fullKey);
			camera.setOutputKey(display_name);
			camera.setCommand(command);
			camera.setGroupName(groupName);
	
	
			targetDevice.addStartupQueryItem(fullKey, camera, type);
			targetDevice.addControlledItem(fullKey, camera, type);
			targetDevice.addControlledItem(display_name, camera, MessageDirection.FROM_FLASH);
			
			try {
				camera.setZoom(zoom);
			} catch (NumberFormatException ex) {
				logger.log(Level.INFO,"Camera zoom capabilities not specified, setting absolute zoom levels will not be possible");
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the camera " + display_name);
		}

	}
}
