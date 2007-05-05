package au.com.BI.CustomInput;

import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class CustomInputFactory {
	Logger logger;
	
	private CustomInputFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static CustomInputFactory _singleton = null;
	public static CustomInputFactory getInstance() {
		if (_singleton == null) {
			_singleton = new CustomInputFactory();
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
	public void addCustomInput(DeviceModel targetDevice, List <DeviceModel>clientModels,
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
		CustomInput theInput = new CustomInput ();


		if (isRegEx != null && isRegEx.equals ("Y"))
		    theInput.setHasPattern(true);
		else
		    theInput.setHasPattern(false);

		theInput.setKey (key);
		theInput.setOutputKey(outKey);
		theInput.setCommand(command);
		theInput.setGroupName (groupName);
		if (extra != null)
		    theInput.setExtra (extra);

		targetDevice.addControlledItem(key, theInput, type);

	}

}
