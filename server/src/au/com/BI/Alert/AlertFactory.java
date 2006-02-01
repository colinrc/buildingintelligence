package au.com.BI.Alert;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

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
	public void addAlert(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("DISPLAY_NAME");
		String active = element.getAttributeValue("ACTIVE");
		String key = element.getAttributeValue("KEY");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		String alarmType = element.getAttributeValue("ALERT_TYPE");
		String message = element.getAttributeValue("MESSAGE");

		Alert theInput = null;
		theInput = new Alert(name, connectionType, outKey, alarmType, message,active);

		theInput.setKey (key);
		theInput.setGroupName (groupName);
		rawHelper.checkForRaw ( element,theInput);
		targetDevice.addControlledItem(key, theInput, type);
		targetDevice.addStartupQueryItem(key, theInput, type);
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theInput, DeviceType.OUTPUT);
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
	public void addAlarm(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		String key = element.getAttributeValue("KEY");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		Alarm theOutput = new Alarm(name, connectionType, outKey);
		theOutput.setKey (key);
		theOutput.setGroupName (groupName);
		rawHelper.checkForRaw ( element,theOutput);

		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theOutput, DeviceType.OUTPUT);
			Iterator clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel clientModel = (DeviceModel) clientModelList.next();
				clientModel.addControlledItem(outKey, theOutput, type);
			}
		}
	}

}
