package au.com.BI.Audio;


import java.util.List;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class AudioFactory {
	Logger logger;
	
	private AudioFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static AudioFactory _singleton = null;
	
	public static AudioFactory getInstance() {
		if (_singleton == null) {
			_singleton = new AudioFactory();
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
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		Audio audio = new Audio (display_name,connectionType);

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
