package au.com.BI.Device;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;
import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class DeviceFactory {
	Logger logger;
	
	private DeviceFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	private static DeviceFactory _singleton = null;
	
	public static DeviceFactory getInstance() {
		if (_singleton == null) {
			_singleton = new DeviceFactory();
		}
		return (_singleton);
	}
	/**
	 * Parses a general device input
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addDevice(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper, String deviceName) {
		String name = element.getAttributeValue("NAME");
		
		try  {
			String tmpKey = element.getAttributeValue("KEY");

			String outKey = element.getAttributeValue("DISPLAY_NAME");
			Device theInput = new Device(name,
					connectionType, outKey);
			String key = targetDevice.formatKey (tmpKey,theInput);
			theInput.setKey (key);
			theInput.setGroupName(groupName);
			targetDevice.addControlledItem(key, theInput, type);
			targetDevice.addStartupQueryItem(key, theInput, type);
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theInput, MessageDirection.FROM_FLASH);
				Iterator clientModelList = clientModels.iterator();
				while (clientModelList.hasNext()) {
					DeviceModel clientModel = (DeviceModel) clientModelList.next();
					clientModel.addControlledItem(outKey, theInput, type);
				}
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the device input " + name);
		}
	}


}
