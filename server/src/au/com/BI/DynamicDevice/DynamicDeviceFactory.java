package au.com.BI.DynamicDevice;


import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class DynamicDeviceFactory {
	Logger logger;
	
	private DynamicDeviceFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static DynamicDeviceFactory _singleton = null;
	
	public static DynamicDeviceFactory getInstance() {
		if (_singleton == null) {
			_singleton = new DynamicDeviceFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Parses a device that has previously been configured with addSpec
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addDynamicDevice(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		logger.log(Level.INFO, "added dymanic device" + display_name);
		DynamicDevice dynamicDevice = new DynamicDevice (display_name,connectionType);

		key = targetDevice.formatKey(key,dynamicDevice);
			
		dynamicDevice.setKey (key);
		dynamicDevice.setOutputKey(display_name);
		dynamicDevice.setCommand(command);
		dynamicDevice.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, dynamicDevice, type);
		targetDevice.addControlledItem(key, dynamicDevice, type);
		targetDevice.addControlledItem(display_name, dynamicDevice, MessageDirection.FROM_FLASH);
	}
	
	public void addDeviceSpec (DeviceModel model, String xmlName, Map <String,DynamicDeviceField>parameters){
		
	}
}
