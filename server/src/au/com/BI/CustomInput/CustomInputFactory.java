package au.com.BI.CustomInput;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class CustomInputFactory {
	Logger logger;
	
	public CustomInputFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
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
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
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
		theInput.setCommand(command);
		theInput.setGroupName (groupName);
		if (extra != null)
		    theInput.setExtra (extra);

		targetDevice.addControlledItem(key, theInput, type);
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theInput, DeviceType.OUTPUT);
		}
	}

}
