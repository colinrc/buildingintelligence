package au.com.BI.IR;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Device.DeviceFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

public class IRFactory  extends DeviceFactory {
	Logger logger;
	
	private IRFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static IRFactory _singleton = null;
	public static IRFactory getInstance() {
		if (_singleton == null) {
			_singleton = new IRFactory();
		}
		return (_singleton);
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
	public void addIR(DeviceModel targetDevice, List clientModels,
			Element element, MessageDirection type, int connectionType,String groupName,RawHelper rawHelper) {
		
		if (targetDevice.getName().equals("GC100")) {
			String name = element.getAttributeValue("NAME");
			
			try  {
				String tmpKey = element.getAttributeValue("KEY");
				String outKey = element.getAttributeValue("AV_NAME");
				IR theOutput = new IR(name, connectionType, outKey);
				String key = targetDevice.formatKey (tmpKey,theOutput);
				theOutput.setKey (key);
				theOutput.setGroupName (groupName);
		
				if (outKey != null && !outKey.equals("")) {
					targetDevice.addControlledItem("AV." + outKey, theOutput, MessageDirection.FROM_FLASH);
					Iterator clientModelList = clientModels.iterator();
					while (clientModelList.hasNext()) {
						DeviceModel clientModel = (DeviceModel) clientModelList.next();
						clientModel.addControlledItem("AV." + outKey, theOutput, type);
					}
				}
			} catch (NumberFormatException ex ){
				logger.log (Level.INFO,"An illegal key was specified for the IR device " + name);
			}
		}
		
		if (targetDevice.getName().equals("DYNALITE")) {

			String name = element.getAttributeValue("NAME");
			
			try  {
				String tmpKey = element.getAttributeValue("KEY");
				String outKey = element.getAttributeValue("DISPLAY_NAME");
				String boxStr = element.getAttributeValue("BOX");
				IR theIRSensor = new IR(name, connectionType, outKey);
				String key = targetDevice.formatKey (tmpKey,theIRSensor);
				theIRSensor.setKey (key);
				theIRSensor.setGroupName (groupName);
				int box = 0;
				try {
					box = Integer.parseInt(boxStr,16);
					theIRSensor.setBox(box);
				}
				catch (Exception ex){
					logger.log (Level.WARNING,"Dynalite IR entry was not specified correctly in the configuration file " + name); 		
				}
			} catch (NumberFormatException ex ){
				logger.log (Level.INFO,"An illegal key was specified for the IR device " + name);
			}
		}
	}

}
