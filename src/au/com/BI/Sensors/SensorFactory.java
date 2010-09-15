package au.com.BI.Sensors;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class SensorFactory  extends DeviceFactory {
	Logger logger;
	
	private SensorFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}
	
	private static SensorFactory _singleton = null;
	public static SensorFactory getInstance() {
		if (_singleton == null) {
			_singleton = new SensorFactory();
		}
		return (_singleton);
	}
	// physical sensors, such as temperature
	public void addSensor(DeviceModel targetDevice, List <DeviceModel>clientModels,
		Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");


			String channel = "";
			String units = "";
			String group = element.getAttributeValue("GROUP");
			String outKey = element.getAttributeValue("DISPLAY_NAME");

			SensorFascade theSensor = new SensorFascade(name, channel, units, group, connectionType, outKey,name);
			String key = targetDevice.formatKey (tmpKey,theSensor);
			this.parseExtraAttributes(outKey , targetDevice, theSensor,  element);
			theSensor.setKey(key);
			theSensor.setGroupName(groupName);
			
			units = element.getAttributeValue("UNITS");
			if (units != null)
				theSensor.setUnits(units);

			String scale = element.getAttributeValue("SCALE");
			if (scale != null)
			{
				try {
					double dscale = Double.parseDouble(scale);
					theSensor.setScale(dscale);
				} 
				catch(NumberFormatException ex) {}
			}

			String offset = element.getAttributeValue("OFFSET");
			if (offset != null)
			{
				try {
					double doffset = Double.parseDouble(offset);
					theSensor.setOffset(doffset);
				} 
				catch(NumberFormatException ex) {}
			}


			if (connectionType == DeviceType.SENSOR) {
				theSensor.setMax("255");
				channel = element.getAttributeValue("CHANNEL");
				theSensor.setChannel(channel);
				group = element.getAttributeValue("GROUP");
				theSensor.setGroup(group);
			}
			if (connectionType == DeviceType.THERMOSTAT_CBUS) {
				String applicationCode = element.getAttributeValue("CBUS_APPLICATION");
				String relay = element.getAttributeValue("RELAY");
				String max = element.getAttributeValue("MAX");
				String zones = element.getAttributeValue("ZONES");
		
				if (applicationCode != null) {
					theSensor.setApplicationCode(applicationCode);
				}
				else { // want to default application to aircon app group
					theSensor.setApplicationCode("AC");
				}
				if (max != null) {
					theSensor.setMax(max);
				}
				if (relay != null) {
					theSensor.setRelay(relay);
				}
				if (zones != null) {
					theSensor.setZones(zones);
				}
			}

			targetDevice.addControlledItem(key, theSensor, type);
			targetDevice.addStartupQueryItem(key, theSensor, type);
	
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theSensor, MessageDirection.FROM_FLASH);
				for (DeviceModel clientModel: clientModels){
					clientModel.addControlledItem(outKey, theSensor, type);
				}
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the sensor device " + name);
		}
	}

}
