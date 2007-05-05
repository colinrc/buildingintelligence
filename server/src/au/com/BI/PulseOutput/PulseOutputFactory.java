package au.com.BI.PulseOutput;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class PulseOutputFactory {
	Logger logger;
	
	private PulseOutputFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	
	private static PulseOutputFactory _singleton = null;
	public static PulseOutputFactory getInstance() {
		if (_singleton == null) {
			_singleton = new PulseOutputFactory();
		}
		return (_singleton);
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
	public void addPulse(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
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
		targetDevice.addControlledItem(key, theOutput, type);
		targetDevice.addStartupQueryItem(key, theOutput, type);
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theOutput, MessageDirection.FROM_FLASH);
			for (DeviceModel clientModel:clientModels){
				clientModel.addControlledItem(outKey, theOutput, type);
			}
		}
	}
}
