package au.com.BI.Thermostat;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class ThermostatFactory {

	Logger logger;
	
	private ThermostatFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static ThermostatFactory _singleton = null;
	public static ThermostatFactory getInstance() {
		if (_singleton == null) {
			_singleton = new ThermostatFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Parses a thermostat and adds to the client model.
	 * @param targetDevice - the Thermostat to be added.
	 * @param clientModels
	 * @param element
	 * @param type
	 * @param connectionType
	 * @param groupName
	 * @param rawHelper
	 */
	public void addThermostat(DeviceModel targetDevice, 
			List <DeviceModel>clientModels,
			Element element, 
			MessageDirection type,
			int connectionType,
			String groupName,
			RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");

			String outKey = element.getAttributeValue("DISPLAY_NAME");
			Thermostat theInput = new Thermostat(name,connectionType,outKey);
			String key = targetDevice.formatKey (tmpKey,theInput);
			theInput.setKey (key);
			theInput.setGroupName (groupName);
			
			targetDevice.addControlledItem(key, theInput, type);
			targetDevice.addStartupQueryItem(key, theInput, type);
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theInput, MessageDirection.FROM_FLASH);
				for (DeviceModel clientModel:clientModels){
					clientModel.addControlledItem(outKey, theInput, type);
				}
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the thermostat " + name);
		}

	}
}
