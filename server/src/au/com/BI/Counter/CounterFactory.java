package au.com.BI.Counter;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class CounterFactory {
	Logger logger;
	
	public CounterFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	/**
	 * Parses the various  elements and adds them
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addCounter(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		String key = element.getAttributeValue("KEY");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		String max = element.getAttributeValue("MAX");
		int maxInt;
		try {
			maxInt = Integer.parseInt(max);
		} catch (NumberFormatException ne){
			logger.log (Level.WARNING, "Max level not set to a number for counter " + name);
			maxInt = 100;
		}
		Counter theInput = new Counter(name,	connectionType, outKey, maxInt);
		theInput.setKey (key);
		theInput.setGroupName (groupName);
		rawHelper.checkForRaw ( element,theInput);
		targetDevice.addControlledItem(key, theInput, type);
		targetDevice.addStartupQueryItem(key, theInput, type);
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
