package au.com.BI.Raw;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class RawFactory {
	Logger logger;
	
	public RawFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
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
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		ToggleSwitch theInput = new ToggleSwitch(name,
				connectionType, outKey);
		theInput.setGroupName(groupName);
		rawHelper.checkForRaw ( element,theInput);
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theInput, DeviceType.OUTPUT);
			Iterator clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel clientModel = (DeviceModel) clientModelList.next();
				clientModel.addControlledItem(outKey, theInput, type);
			}
		}

	}
}
