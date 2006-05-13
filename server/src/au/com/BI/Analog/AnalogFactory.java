package au.com.BI.Analog;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Alert.AlertFactory;
import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class AnalogFactory {
	Logger logger;
	
	private AnalogFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	private static AnalogFactory _singleton = null;
	
	public static AnalogFactory getInstance() {
		if (_singleton == null) {
			_singleton = new AnalogFactory();
		}
		return (_singleton);
	}
	/**
	 * Parses an analouge input
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addAnalog(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		
		try  {
			String tmpKey = element.getAttributeValue("KEY");
			String key = targetDevice.formatKey (tmpKey);

			String outKey = element.getAttributeValue("DISPLAY_NAME");
			Analog theInput = new Analog(name,
					connectionType, outKey);
			theInput.setKey (key);
			theInput.setGroupName(groupName);
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
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the analog input " + name);
		}
	}


}
