package au.com.BI.MultiMedia.AutonomicHome.Device;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class WindowsMediaExtenderFactory {
	Logger logger;
	
	private WindowsMediaExtenderFactory() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	private static WindowsMediaExtenderFactory _singleton = null;
	
	public static WindowsMediaExtenderFactory getInstance() {
		if (_singleton == null) {
			_singleton = new WindowsMediaExtenderFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Add a media extender.
	 * @param targetDevice
	 * @param clientModels
	 * @param element
	 * @param type
	 * @param connectionType
	 * @param groupName
	 * @param rawHelper
	 */
	public void addMediaExtender(DeviceModel targetDevice,
			List clientModels,
			Element element,
			MessageDirection type,
			int connectionType,
			String groupName,
			RawHelper rawHelper) {
		
		String name = element.getAttributeValue("NAME");
		String key = element.getAttributeValue("KEY");
		String displayName = element.getAttributeValue("DISPLAY_NAME");
		
		WindowsMediaExtender extender = new WindowsMediaExtender();
		extender.setKey(key);
		extender.setName(name);
		extender.setOutputKey(displayName);

		targetDevice.addControlledItem(key, extender, type);
	}
}
