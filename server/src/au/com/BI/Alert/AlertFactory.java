package au.com.BI.Alert;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class AlertFactory {
	Logger logger;
	
	private AlertFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	private static AlertFactory _singleton = null;
	
	public static AlertFactory getInstance() {
		if (_singleton == null) {
			_singleton = new AlertFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Parses the various alert elements and adds them
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addAlert(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("DISPLAY_NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");

			String active = element.getAttributeValue("ACTIVE");
			String outKey = element.getAttributeValue("DISPLAY_NAME");
			String alarmType = element.getAttributeValue("ALERT_TYPE");
			String message = element.getAttributeValue("MESSAGE");
	
			Alert theInput = null;
			theInput = new Alert(name, connectionType, outKey, alarmType, message,active);
			String key = targetDevice.formatKey (tmpKey,theInput);
			theInput.setKey (key);
			theInput.setGroupName (groupName);
			targetDevice.addControlledItem(key, theInput, type);
			targetDevice.addStartupQueryItem(key, theInput, type);
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theInput, MessageDirection.FROM_FLASH);
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the alert " + name);
		}
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
	public void addAlarm(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		
		String name = element.getAttributeValue("NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");

	
			Alarm theOutput = new Alarm(name, connectionType, outKey);
			String key = targetDevice.formatKey (tmpKey,theOutput);
			theOutput.setKey (key);
			theOutput.setGroupName (groupName);
			targetDevice.addControlledItem(key, theOutput, type);
			targetDevice.addStartupQueryItem(key, theOutput, type);
					
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theOutput, MessageDirection.FROM_FLASH);
				for (DeviceModel clientModel :clientModels){
					clientModel.addControlledItem(outKey, theOutput, type);
				}
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the alarm " + name);
		}
	}

}
