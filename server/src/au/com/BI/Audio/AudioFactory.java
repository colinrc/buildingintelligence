package au.com.BI.Audio;


import java.util.List;
import java.util.logging.*;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class AudioFactory extends DeviceFactory {
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
	public void addAudio(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String command = element.getAttributeValue("COMMAND");
		String display_name = element.getAttributeValue("DISPLAY_NAME");
		logger.log(Level.INFO, "added audio device" + display_name);
		Audio audio = new Audio (display_name,connectionType);

		key = targetDevice.formatKey(key,audio);
		this.parseExtraAttributes(display_name , targetDevice, audio,  element);
			
		audio.setKey (key);
		audio.setOutputKey(display_name);
		audio.setCommand(command);
		audio.setGroupName(groupName);
		targetDevice.addStartupQueryItem(key, audio, type);
		targetDevice.addControlledItem(key, audio, type);
		targetDevice.addControlledItem(display_name, audio, MessageDirection.FROM_FLASH);
	}
}
