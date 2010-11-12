package au.com.BI.Pump;


import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class PumpFactory extends DeviceFactory {
	Logger logger;
	
	private PumpFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static PumpFactory _singleton = null;
	
	public static PumpFactory getInstance() {
		if (_singleton == null) {
			_singleton = new PumpFactory();
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
	public void addPump(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		logger.log(Level.INFO, "added pump device" + display_name);

		Pump pump = new Pump (display_name,connectionType);

		key = targetDevice.formatKey(key,pump);
			
		pump.setKey (key);
		pump.setOutputKey(display_name);
		this.parseExtraAttributes(display_name , targetDevice, pump,  element);
		pump.setCommand(command);
		pump.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, pump, type);
		targetDevice.addControlledItem(key, pump, type);
		targetDevice.addControlledItem(display_name, pump, MessageDirection.FROM_FLASH);
	}
}
