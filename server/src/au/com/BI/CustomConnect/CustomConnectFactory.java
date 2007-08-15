package au.com.BI.CustomConnect;

import java.util.List;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class CustomConnectFactory  extends DeviceFactory {
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
			this.parseExtraAttributes(displayName , targetDevice, theConnection,  element);
			theConnection.setGroupName(groupName);
			theConnection.setOutputKey(displayName);
			theConnection.setName(name);
			deviceList.add(theConnection);

			if (displayName != null && !displayName.equals("")) {
				targetDevice.addControlledItem(displayName, theConnection, MessageDirection.FROM_FLASH);
				targetDevice.addControlledItem(key, theConnection, MessageDirection.FROM_HARDWARE);				
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
		
		CustomConnectInput customConnectInput = new CustomConnectInput();
		List <Element> inConditions = (List<Element>)element.getChildren("INSTRING");
		for (Element eachCondition: inConditions){
			String toMatch = eachCondition.getAttributeValue("TO_MATCH");
			String key = eachCondition.getAttributeValue("KEY");
			String command = eachCondition.getAttributeValue("COMMAND");
			String eachLineName = eachCondition.getAttributeValue("NAME");
			String extra = eachCondition.getAttributeValue("EXTRA");
			String extra2 = eachCondition.getAttributeValue("EXTRA2");
			String extra3 = eachCondition.getAttributeValue("EXTRA3");
			String extra4 = eachCondition.getAttributeValue("EXTRA4");
			String extra5 = eachCondition.getAttributeValue("EXTRA5");
			CustomConnectInputDetails customConnectInputDetails = new CustomConnectInputDetails();
			customConnectInputDetails.setExtra5(extra5);
			customConnectInputDetails.setExtra4(extra4);
			customConnectInputDetails.setExtra3(extra3);
			customConnectInputDetails.setExtra2(extra2);
			customConnectInputDetails.setName(eachLineName);
			customConnectInputDetails.setExtra(extra);
			customConnectInputDetails.setKey(key);
			customConnectInputDetails.setToMatch(toMatch);
			customConnectInputDetails.setCommand(command);
			customConnectInput.addCustomConnectInputDetails(customConnectInputDetails);
		}
		customConnectInput.setCustomConnectList(deviceList);
		targetDevice.addCustomConnectInput (customConnectInput);
		
	}

}
