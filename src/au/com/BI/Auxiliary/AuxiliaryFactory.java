package au.com.BI.Auxiliary;


import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class AuxiliaryFactory extends DeviceFactory {
	Logger logger;
	
	private AuxiliaryFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static AuxiliaryFactory _singleton = null;
	
	public static AuxiliaryFactory getInstance() {
		if (_singleton == null) {
			_singleton = new AuxiliaryFactory();
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
	public void addAuxiliary(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		logger.log(Level.INFO, "added aux device" + display_name);
		Auxiliary auxiliary = new Auxiliary (display_name,connectionType);

		key = targetDevice.formatKey(key,auxiliary);
		this.parseExtraAttributes(display_name , targetDevice, auxiliary,  element);
			
		auxiliary.setKey (key);
		auxiliary.setOutputKey(display_name);
		auxiliary.setCommand(command);
		auxiliary.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, auxiliary, type);
		targetDevice.addControlledItem(key, auxiliary, type);
		targetDevice.addControlledItem(display_name, auxiliary, MessageDirection.FROM_FLASH);
	}
}
