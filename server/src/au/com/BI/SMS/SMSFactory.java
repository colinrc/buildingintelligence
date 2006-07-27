package au.com.BI.SMS;


import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class SMSFactory {
	Logger logger;
	
	private SMSFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static SMSFactory _singleton = null;
	
	public static SMSFactory getInstance() {
		if (_singleton == null) {
			_singleton = new SMSFactory();
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
	public void addAudio(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		SMS audio = new SMS (display_name,connectionType);

		key = targetDevice.formatKey(key,audio);
			
		audio.setKey (key);
		audio.setOutputKey(display_name);
		audio.setCommand(command);
		audio.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, audio, type);
		targetDevice.addControlledItem(key, audio, type);
		targetDevice.addControlledItem(display_name, audio, MessageDirection.FROM_FLASH);
	}
}
