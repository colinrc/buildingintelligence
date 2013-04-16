package au.com.BI.VirtualOutput;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class VirtualOutputFactory  extends DeviceFactory {
	Logger logger;
	
	private VirtualOutputFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static VirtualOutputFactory _singleton = null;
	public static VirtualOutputFactory getInstance() {
		if (_singleton == null) {
			_singleton = new VirtualOutputFactory();
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
	public void addVirtualOutput(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");

			String outKey = element.getAttributeValue("DISPLAY_NAME");
			String max = element.getAttributeValue("MAX");
			int maxInt;
			try {
				maxInt = Integer.parseInt(max);
			} catch (NumberFormatException ne){
				logger.log (Level.WARNING, "Max level not set to a number for counter " + name);
				maxInt = 100;
			}
			VirtualOutput theOutput = new VirtualOutput(name, connectionType, outKey,maxInt);
			String key = targetDevice.formatKey (tmpKey,theOutput);
			theOutput.setKey (key);
			theOutput.setGroupName (groupName);
			this.parseExtraAttributes(outKey , targetDevice, theOutput,  element);
			targetDevice.addControlledItem(key, theOutput, type);
			targetDevice.addStartupQueryItem(key, theOutput, type);
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theOutput, MessageDirection.FROM_FLASH);
				for (DeviceModel clientModel:clientModels){
					clientModel.addControlledItem(outKey, theOutput, type);
				}
			}
			
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the virtual output device " + name);
		}
	}


}
