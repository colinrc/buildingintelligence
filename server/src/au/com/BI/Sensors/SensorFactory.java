package au.com.BI.Sensors;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Raw.RawFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class SensorFactory {
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
	public void addSensor(DeviceModel targetDevice, List clientModels,
		Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");
			String key = targetDevice.formatKey (tmpKey);

			String channel = "";
			String units = "";
			String group = element.getAttributeValue("GROUP");;
			String outKey = element.getAttributeValue("DISPLAY_NAME");
			SensorFascade theSensor = new SensorFascade(name, channel, units, group, connectionType, outKey,name);
			theSensor.setKey(key);
			theSensor.setGroupName(groupName);
	
			rawHelper.checkForRaw ( element,theSensor);
	
			if (connectionType == DeviceType.SENSOR) {
				theSensor.setMax("255");
				channel = element.getAttributeValue("CHANNEL");
				units = element.getAttributeValue("UNITS");
				group = element.getAttributeValue("GROUP");
			}
			targetDevice.addControlledItem(key, theSensor, connectionType);
			targetDevice.addStartupQueryItem(key, theSensor, connectionType);
	
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theSensor, DeviceType.OUTPUT);
				Iterator clientModelList = clientModels.iterator();
				while (clientModelList.hasNext()) {
					DeviceModel clientModel = (DeviceModel) clientModelList.next();
					clientModel.addControlledItem(outKey, theSensor, type);
				}
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the sensor device " + name);
		}
	}

}
