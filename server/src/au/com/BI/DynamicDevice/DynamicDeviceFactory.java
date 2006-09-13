package au.com.BI.DynamicDevice;


import java.util.List;
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
	 * Parses an label device
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addlabel(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		DynamicDevice dynamicDevice = new DynamicDevice (display_name,connectionType);

		key = targetDevice.formatKey(key,dynamicDevice);
			
		dynamicDevice.setKey (key);
		label.setOutputKey(display_name);
		label.setCommand(command);
		label.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, label, type);
		targetDevice.addControlledItem(key, label, type);
		targetDevice.addControlledItem(display_name, label, MessageDirection.FROM_FLASH);
	}
	
	public void addSpec (DeviceModel model, String parsingLabel, Map parameters){
		
	}
}
