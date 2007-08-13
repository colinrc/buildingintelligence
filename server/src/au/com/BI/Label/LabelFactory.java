package au.com.BI.Label;


import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class LabelFactory  extends DeviceFactory {
	Logger logger;
	
	private LabelFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static LabelFactory _singleton = null;
	
	public static LabelFactory getInstance() {
		if (_singleton == null) {
			_singleton = new LabelFactory();
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
	public void addLabel(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		String defaultLabel  = element.getAttributeValue("DEFAULT_LABEL_KEY");
		String relay  = element.getAttributeValue("RELAY");
		
		String cbusApplication = "";
		if (targetDevice.getName().equals("CBUS")){
			cbusApplication = element.getAttributeValue("CBUS_APPLICATION");
		}
		String generateDimmerVals  = element.getAttributeValue("GENERATE_DIMMER_VALS");
		
		Label label = new Label (display_name,connectionType);

		key = targetDevice.formatKey(key,label);
		if (generateDimmerVals != null && generateDimmerVals.equals("N")){
			label.setGenerateDimmerVals (false);
		}
		if (relay != null && relay.equals("Y")) label.relay = true;
		label.setKey (key);
		label.setDefaultLabel (defaultLabel);
		label.setApplicationCode(cbusApplication);
		label.setOutputKey(display_name);
		label.setCommand(command);
		label.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, label, type);
		targetDevice.addControlledItem(key, label, type);
		targetDevice.addControlledItem(display_name, label, MessageDirection.FROM_FLASH);
	}
}
