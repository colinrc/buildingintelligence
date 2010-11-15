package au.com.BI.Device;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;
import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class DeviceFactory {
	Logger logger;
	
	protected Map <DeviceModel, Map<String, ExtraAttribute>>extraAttributes;
	
	public DeviceFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
		extraAttributes = new HashMap<DeviceModel, Map<String, ExtraAttribute>>();
	}
	private static DeviceFactory _singleton = null;
	

	
	public static DeviceFactory getInstance() {
		if (_singleton == null) {
			_singleton = new DeviceFactory();

		}
		return (_singleton);
	}
	/**
	 * Parses a general device input
	 *
	 * @param targetDevices
	 *            The list of DeviceModels of this type
	 * @param element
	 *            The element
	 * @param type
	 *            INPUT | OUTPUT | MONITORED
	 */
	public void addDevice(DeviceModel targetDevice, List <DeviceModel>clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper, String deviceName) {
		String name = element.getAttributeValue("NAME");
		
		try  {
			String tmpKey = element.getAttributeValue("KEY");

			String outKey = element.getAttributeValue("DISPLAY_NAME");
			Device theInput = new Device(name,
					connectionType, outKey);
			String key = targetDevice.formatKey (tmpKey,theInput);
			theInput.setKey (key);
			theInput.setGroupName(groupName);
			targetDevice.addControlledItem(key, theInput, type);
			targetDevice.addStartupQueryItem(key, theInput, type);
			this.parseExtraAttributes(outKey , targetDevice, theInput,  element);
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theInput, MessageDirection.FROM_FLASH);

				for (DeviceModel clientModel: clientModels){
					clientModel.addControlledItem(outKey, theInput, type);
				}
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the device input " + name);
		}
	}

	public void clearExtraAttributes (DeviceModel model) {
		extraAttributes.clear();
		
	}
	
	public void addDeviceAttribute (DeviceModel model, String name, boolean mandatory){
		logger.log (Level.FINEST, "Adding extra attribute " +name + " to support model " + model.getName());
		Map <String, ExtraAttribute> nameList = extraAttributes.get (model);
		if (nameList == null){
			nameList = new HashMap <String, ExtraAttribute>();
			extraAttributes.put (model ,nameList);
		}
		if (!nameList.containsKey(name)){
			ExtraAttribute extraAttribute = new ExtraAttribute(name, mandatory);
			nameList.put(name, extraAttribute);
		}
	}


	public void parseExtraAttributes (String key, DeviceModel targetDevice , DeviceType deviceType, Element element) {
			Map <String, ExtraAttribute> attribs = extraAttributes.get(targetDevice);
			if (attribs != null && !attribs.isEmpty())
			{
/*				for(Entry<String, ExtraAttribute> e : extraAttributes.get(targetDevice).entrySet())
				{
					String value = e.getKey();
					ExtraAttribute att = e.getValue();
					here;
				}
*/				
				
				for (String attribName: attribs.keySet()){
					String value = element.getAttributeValue(attribName);
					ExtraAttribute attributeDetails = attribs.get(attribName);
					if (value == null) {
						deviceType.setAttributeValue(attribName,"");
						if (attributeDetails.isMandatory() == true ) {
							logger.log (Level.WARNING, "In device " + key + " the attribute " + attribName+ " expected for " + deviceType.getName() + " in a model " + targetDevice.getName() + " was not present in the configuration file");
						}
					}else {
						deviceType.setAttributeValue(attribName,value);						
					}
				}
			}
	}
}
