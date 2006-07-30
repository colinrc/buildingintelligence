package au.com.BI.CustomConect;

import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class CustomConnectFactory {
	Logger logger;
	
	private CustomConnectFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static CustomConnectFactory _singleton = null;
	public static CustomConnectFactory getInstance() {
		if (_singleton == null) {
			_singleton = new CustomConnectFactory();
		}
		return (_singleton);
	}

	/**
	 * Parses the various custom input elements and adds them
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addCustomInput(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		String extra = element.getAttributeValue("EXTRA");
		String extra2 = element.getAttributeValue("EXTRA2");
		String extra3 = element.getAttributeValue("EXTRA3");
		String extra4 = element.getAttributeValue("EXTRA4");
		String extra5 = element.getAttributeValue("EXTRA5");
		String isRegEx = element.getAttributeValue("KEY_IS_REGEX");
		String match = element.getAttributeValue("MATCH");
		CustomConnect theInput = new CustomConnect ();


	theInput.setKey (key);
		theInput.setOutputKey(outKey);
		theInput.setCommand(command);
		theInput.setGroupName (groupName);

		targetDevice.addControlledItem(key, theInput, type);
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theInput, MessageDirection.FROM_FLASH);
		}
	}

}
