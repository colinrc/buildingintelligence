package au.com.BI.Unit;


import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class UnitFactory  extends DeviceFactory {
	Logger logger;
	
	private UnitFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static UnitFactory _singleton = null;
	
	public static UnitFactory getInstance() {
		if (_singleton == null) {
			_singleton = new UnitFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Parses an unit device
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addUnit(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		Unit unit = new Unit (display_name,connectionType);

		key = targetDevice.formatKey(key,unit);
			
		unit.setKey (key);
		unit.setOutputKey(display_name);
		this.parseExtraAttributes(display_name , targetDevice, unit,  element);
		unit.setCommand(command);
		unit.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, unit, type);
		targetDevice.addControlledItem(key, unit, type);
		targetDevice.addControlledItem(display_name, unit, MessageDirection.FROM_FLASH);
	}
}
