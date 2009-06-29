package au.com.BI.Heater;


import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class HeaterFactory extends DeviceFactory {
	Logger logger;
	
	private HeaterFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static HeaterFactory _singleton = null;
	
	public static HeaterFactory getInstance() {
		if (_singleton == null) {
			_singleton = new HeaterFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Parses a pump device
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addHeater(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		Heater heater = new Heater (display_name,connectionType);

		key = targetDevice.formatKey(key,heater);
			
		heater.setKey (key);
		heater.setOutputKey(display_name);
		this.parseExtraAttributes(display_name , targetDevice, heater,  element);
		heater.setCommand(command);
		heater.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, heater, type);
		targetDevice.addControlledItem(key, heater, type);
		targetDevice.addControlledItem(display_name, heater, MessageDirection.FROM_FLASH);
	}
}
