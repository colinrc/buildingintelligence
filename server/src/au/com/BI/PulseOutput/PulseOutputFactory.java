package au.com.BI.PulseOutput;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class PulseOutputFactory {
	Logger logger;
	
	public PulseOutputFactory () {
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
	public void addPulse(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		String key = element.getAttributeValue("KEY");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		String max = element.getAttributeValue("MAX");
		int maxInt;
		try {
			maxInt = Integer.parseInt(max);
		} catch (NumberFormatException ne){
			maxInt = 100;
			logger.log (Level.FINE, "Max level for pulse not specified for device " + name + ". Defaulting to " + maxInt);
		}
		PulseOutput theOutput = new PulseOutput(name,	connectionType, outKey,maxInt);
		theOutput.setKey (key);
		theOutput.setGroupName (groupName);
		rawHelper.checkForRaw (element,theOutput);
		targetDevice.addControlledItem(key, theOutput, type);
		targetDevice.addStartupQueryItem(key, theOutput, type);
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theOutput, DeviceType.OUTPUT);
			Iterator clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel clientModel = (DeviceModel) clientModelList.next();
				clientModel.addControlledItem(outKey, theOutput, type);
			}
		}
	}
}
