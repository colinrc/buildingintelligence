package au.com.BI.Lights;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class LightFactory extends DeviceFactory {
	Logger logger;
	
	public LightFactory () {

		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	/**
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param targetDevice 
	 * @param clientModels 
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 * @param connectionType 
	 * @param groupName
	 * @param rawHelper 
	 */
	public void addLight(DeviceModel targetDevice, List <DeviceModel>clientModels, Element element, MessageDirection type, int connectionType, String groupName, RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String name = element.getAttributeValue("NAME");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
	
		LightFascade theLight = new LightFascade(name, connectionType, outKey,targetDevice.getName());
		key = targetDevice.formatKey(key,theLight);
		this.parseExtraAttributes(outKey , targetDevice, theLight,  element);
		theLight.setKey(key);
		theLight.setGroupName(groupName);
	
	
		String generateDimmerVals  = element.getAttributeValue("GENERATE_DIMMER_VALS");
		if (generateDimmerVals != null && generateDimmerVals.equals("N")){
			theLight.setGenerateDimmerVals (false);
		}
		
		if (connectionType == DeviceType.LIGHT_CBUS) {
			String applicationCode = element.getAttributeValue("CBUS_APPLICATION");
			String relay = element.getAttributeValue("RELAY");
			String max = element.getAttributeValue("MAX");
	
			if (applicationCode != null) {
				theLight.setApplicationCode(applicationCode);
			}
			if (max != null) {
				theLight.setMax(max);
			}
			if (relay != null) {
				theLight.setRelay(relay);
			}
		}
		if (connectionType == DeviceType.LIGHT_DYNALITE) {
			String areaCode = element.getAttributeValue("AREA");
			String relay = element.getAttributeValue("RELAY");
			String bla = element.getAttributeValue("BLA");
			int channel = 0;

			if (areaCode != null) {
				theLight.setAreaCode(areaCode);
			}
			if (bla != null) {
				theLight.setBLA(bla);
			}
			if (relay != null) {
				theLight.setRelay(relay);
			}
			try {
				channel = Integer.parseInt(key,16);
			}
			catch (Exception ex){
				logger.log (Level.WARNING,"Dynalight entry was not configured correctly in the configuration file " + 
						((DeviceType)theLight).getName());
			}
		}
		if (connectionType == DeviceType.COMFORT_LIGHT_X10 || connectionType == DeviceType.COMFORT_LIGHT_X10_UNITCODE) {
			String X10HouseCode = element.getAttributeValue("X10HOUSE_CODE");
			theLight.setX10HouseCode(X10HouseCode);
		}
		targetDevice.addControlledItem(key, theLight, type);
		targetDevice.addStartupQueryItem(key, theLight, type);
	
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theLight, MessageDirection.FROM_FLASH);
			Iterator<DeviceModel> clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel clientModel = (DeviceModel) clientModelList.next();
				clientModel.addControlledItem(outKey, theLight, type);
			}
		}
	}

	/**
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param targetDevice 
	 * @param clientModels 
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 * @param connectionType 
	 * @param groupName 
	 * @param rawHelper 
	 */
	public void addLightArea(DeviceModel targetDevice, List <DeviceModel>clientModels, Element element, MessageDirection type, int connectionType, String groupName, RawHelper rawHelper) {
		String key = element.getAttributeValue("KEY");
		String name = element.getAttributeValue("NAME");
		String outKey = element.getAttributeValue("DISPLAY_NAME");
	
		LightFascade theLight = new LightFascade(name, connectionType, outKey,targetDevice.getName());
		theLight.setKey(key);
		theLight.setGroupName(groupName);

		if (connectionType == DeviceType.LIGHT_DYNALITE_AREA) {
			theLight.setAreaCode(key);
			theLight.setAreaDevice(true);
		}

		targetDevice.addControlledItem(key, theLight, type);
		targetDevice.addStartupQueryItem(key, theLight, type);
		this.parseExtraAttributes(outKey , targetDevice, theLight,  element);
	
		if (outKey != null && !outKey.equals("")) {
			targetDevice.addControlledItem(outKey, theLight, MessageDirection.FROM_FLASH);
			Iterator<DeviceModel> clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel clientModel = (DeviceModel) clientModelList.next();
				clientModel.addControlledItem(outKey, theLight, type);
			}
		}
	}
}
