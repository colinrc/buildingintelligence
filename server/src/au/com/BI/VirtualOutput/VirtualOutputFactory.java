package au.com.BI.VirtualOutput;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.CustomInput.CustomInputFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class VirtualOutputFactory {
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
	public void addVirtualOutput(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");
			String key = targetDevice.formatKey (tmpKey);
			String outKey = element.getAttributeValue("DISPLAY_NAME");
			String max = element.getAttributeValue("MAX");
			int maxInt;
			try {
				maxInt = Integer.parseInt(max);
			} catch (NumberFormatException ne){
				logger.log (Level.WARNING, "Max level not set to a number for counter " + name);
				maxInt = 100;
			}
			VirtualOutput theOuput = new VirtualOutput(name, connectionType, outKey,maxInt);
			theOuput.setKey (key);
			theOuput.setGroupName (groupName);
			rawHelper.checkForRaw (element,theOuput);
			targetDevice.addControlledItem(key, theOuput, type);
			targetDevice.addStartupQueryItem(key, theOuput, type);
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theOuput, DeviceType.OUTPUT);
				Iterator clientModelList = clientModels.iterator();
				while (clientModelList.hasNext()) {
					DeviceModel clientModel = (DeviceModel) clientModelList.next();
					clientModel.addControlledItem(outKey, theOuput, type);
				}
			}
			
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the virtual output device " + name);
		}
	}


}
