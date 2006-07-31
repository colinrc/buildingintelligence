package au.com.BI.Raw;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class RawFactory {
	Logger logger;
	
	private RawFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	
	private static RawFactory _singleton = null;
	public static RawFactory getInstance() {
		if (_singleton == null) {
			_singleton = new RawFactory();
		}
		return (_singleton);
	}

	/**
	 * Parses the various appropriate elements and adds them
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addRaw(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		targetDevice.setHasRawCodes(true);
		String name = element.getAttributeValue("NAME");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		ToggleSwitch theInput = new ToggleSwitch(name,
				connectionType, outKey);
		theInput.setGroupName(groupName);
		rawHelper.checkForRaw ( element,theInput);
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theInput, MessageDirection.FROM_FLASH);
			Iterator clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel clientModel = (DeviceModel) clientModelList.next();
				clientModel.addControlledItem(outKey, theInput, type);
			}
		}

	}
}
