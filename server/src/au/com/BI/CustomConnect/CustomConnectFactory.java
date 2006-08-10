package au.com.BI.CustomConnect;

import java.util.List;
import java.util.Vector;
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


		
		String overallName = element.getAttributeValue("NAME");
		
		Vector <CustomConnect>deviceList = new Vector<CustomConnect>();
		List <Element> keys = (List<Element>)element.getChildren("KEY");
		for (Element eachKey: keys){
			CustomConnect theConnection = new CustomConnect ();			
			
			String tmpKey = eachKey.getAttributeValue("VALUE");
			String displayName = eachKey.getAttributeValue("DISPLAY_NAME");
			String name = eachKey.getAttributeValue("NAME");
			String key = targetDevice.formatKey (tmpKey,theConnection);
			
			theConnection.setKey (key);
			theConnection.setGroupName(groupName);
			theConnection.setOutputKey(displayName);
			theConnection.setName(name);
			deviceList.add(theConnection);

			if (displayName != null && !displayName.equals("")) {
				targetDevice.addControlledItem(displayName, theConnection, MessageDirection.FROM_FLASH);
				// All commands must come from Flash so only add the device to the Flash processing collection
			}
		}
		
		List <Element> conditions = (List<Element>)element.getChildren("OUTSTRING");
		for (Element eachCondition: conditions){
			String value = eachCondition.getAttributeValue("VALUE");
			String commandCondition = eachCondition.getAttributeValue("IF_COMMAND");
			String extraCondition = eachCondition.getAttributeValue("IF_EXTRA");
			String eachLineName = eachCondition.getAttributeValue("NAME");
			if (value != null  && commandCondition != null || !value.equals ("") && !commandCondition.equals ("") ) {
				for (CustomConnect customConnect:deviceList){
					value = value.replaceAll("%KEY%", customConnect.getKey());
					customConnect.addOutputCondition(commandCondition, extraCondition, value, eachLineName);
					logger.log (Level.FINER, "Adding processing condition " + eachLineName + " for the key " + customConnect.getName() + " in the custom device " + overallName );
				}
			} else {
				logger.log (Level.WARNING,"The custom connection configuration " + overallName + " in the model "+ targetDevice.getName() + " is incorrect, check the OUTSTRING conditions");
			}
		}
		
		List <Element> inConditions = (List<Element>)element.getChildren("INSTRING");
		for (Element eachCondition: inConditions){
			String value = eachCondition.getAttributeValue("VALUE");
			String commandCondition = eachCondition.getAttributeValue("IF_COMMAND");
			String extraCondition = eachCondition.getAttributeValue("IF_EXTRA");
			String eachLineName = eachCondition.getAttributeValue("NAME");
			if (value != null  && commandCondition != null || !value.equals ("") && !commandCondition.equals ("") ) {
				for (CustomConnect customConnect:deviceList){
					value = value.replaceAll("%KEY%", customConnect.getKey());
					customConnect.addOutputCondition(commandCondition, extraCondition, value, eachLineName);
					logger.log (Level.FINER, "Adding processing condition " + eachLineName + " for the key " + customConnect.getName() + " in the custom device " + overallName );
				}
			} else {
				logger.log (Level.WARNING,"The custom connection configuration " + overallName + " in the model "+ targetDevice.getName() + " is incorrect, check the OUTSTRING conditions");
			}
		}
		
	}

}
