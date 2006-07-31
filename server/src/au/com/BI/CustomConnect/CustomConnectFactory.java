package au.com.BI.CustomConnect;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class CustomConnectFactory {
	Logger logger;
	
	private CustomConnectFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static CustomConnectFactory _singleton = null;
	public static CustomConnectFactory getInstance() {
		if (_singleton == null) {
			_singleton = new CustomConnectFactory();
		}
		return (_singleton);
	}


	@SuppressWarnings("unchecked")
	public void addCustomConnect(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		CustomConnect theConnection = new CustomConnect ();
		
		String name = element.getAttributeValue("NAME");
		String key = element.getAttributeValue("KEY");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
		List <Element> conditions = (List<Element>)element.getChildren("OUTSTRING");
		for (Element eachCondition: conditions){
			String value = eachCondition.getAttributeValue("VALUE");
			String commandCondition = eachCondition.getAttributeValue("IF_COMMAND");
			if (value != null  && commandCondition != null || !value.equals ("") && !commandCondition.equals ("") ) {
				theConnection.conditions.put(commandCondition,value);
			} else {
				logger.log (Level.WARNING,"The custom connection configuration " + name + " in the model "+ targetDevice.getName() + " is incorrect, check the OUTSTRING conditions");
			}
		}
		
		
		theConnection.setKey (key);
		theConnection.setOutputKey(outKey);
		theConnection.setGroupName (groupName);
		theConnection.setName(name);

		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theConnection, MessageDirection.FROM_FLASH);
			// All commands must come from Flash so only add the device to the Flash processing collection
		}
	}

}
