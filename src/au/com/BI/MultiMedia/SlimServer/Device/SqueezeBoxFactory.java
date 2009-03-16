package au.com.BI.MultiMedia.SlimServer.Device;

import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.MultiMedia.AutonomicHome.Device.WindowsMediaExtender;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class SqueezeBoxFactory {

	Logger logger;
	
	private SqueezeBoxFactory() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	private static SqueezeBoxFactory _singleton = null;
	
	public static SqueezeBoxFactory getInstance() {
		if (_singleton == null) {
			_singleton = new SqueezeBoxFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Adds a squeeze box to the target device (Slim Server).
	 * @param targetDevice
	 * @param clientModels
	 * @param element
	 * @param type
	 * @param connectionType
	 * @param groupName
	 * @param rawHelper
	 */
	public void addSqueezeBox(DeviceModel targetDevice,
			List clientModels,
			Element element,
			MessageDirection type,
			int connectionType,
			String groupName,
			RawHelper rawHelper) {
		
		String name = element.getAttributeValue("NAME");
		String key = element.getAttributeValue("KEY");
		String displayName = element.getAttributeValue("DISPLAY_NAME");
		
		SqueezeBox squeezeBox = new SqueezeBox();
		squeezeBox.setKey(key);
		squeezeBox.setName(name);
		squeezeBox.setOutputKey(displayName);
		squeezeBox.setDeviceType(DeviceType.SQUEEZE_BOX);

		targetDevice.addControlledItem(key, squeezeBox, MessageDirection.FROM_HARDWARE);
		targetDevice.addControlledItem(key, squeezeBox, MessageDirection.FROM_FLASH);
	}
}
