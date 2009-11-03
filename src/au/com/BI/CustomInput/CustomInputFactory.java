package au.com.BI.CustomInput;

import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class CustomInputFactory  extends DeviceFactory {
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
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		String extra = element.getAttributeValue("EXTRA");
		String isRegEx = element.getAttributeValue("KEY_IS_REGEX");
		CustomInput theInput = new CustomInput ();


		if (isRegEx != null && isRegEx.equals ("Y"))
		    theInput.setHasPattern(true);
		else
		    theInput.setHasPattern(false);

		theInput.setKey (key);
		theInput.setOutputKey(outKey);
		this.parseExtraAttributes(outKey , targetDevice, theInput,  element);
		theInput.setCommand(command);
		theInput.setGroupName (groupName);
		if (extra != null)
		    theInput.setExtra (extra);

		targetDevice.addControlledItem(key, theInput, type);

	}

}
