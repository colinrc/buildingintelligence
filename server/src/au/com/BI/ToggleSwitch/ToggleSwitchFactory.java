package au.com.BI.ToggleSwitch;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.RawHelper;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

public class ToggleSwitchFactory {
	Logger logger;
	
	private ToggleSwitchFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
	}

	private static ToggleSwitchFactory _singleton = null;
	public static ToggleSwitchFactory getInstance() {
		if (_singleton == null) {
			_singleton = new ToggleSwitchFactory();
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
	public void addToggle(DeviceModel targetDevice, List clientModels,
			Element element, int type, int connectionType,String groupName,RawHelper rawHelper) {
		String name = element.getAttributeValue("NAME");
		try  {
			String tmpKey = element.getAttributeValue("KEY");
			String key = targetDevice.formatKey (tmpKey);
			String outKey = element.getAttributeValue("DISPLAY_NAME");
			ToggleSwitch theInput = new ToggleSwitch(name,	connectionType, outKey);
			theInput.setKey (key);
			theInput.setGroupName (groupName);
			rawHelper.checkForRaw (element,theInput);
			
			if (targetDevice.getName().equals("DYNALITE")) {
	
				String boxStr = element.getAttributeValue("BOX");
				int box = 0;
				try {
					box = Integer.parseInt(boxStr,16);
					theInput.setBox(box);
				}
				catch (Exception ex){
					logger.log (Level.WARNING,"Dynalight entry was not configured correctly in the configuration file " + name); 
							
				}
			}
			
			if (targetDevice.getName().equals("M1")) {
				String area = element.getAttributeValue("AREA");
				theInput.setArea(area);
			}
			
			targetDevice.addControlledItem(key, theInput, type);
			targetDevice.addStartupQueryItem(key, theInput, type);
			if (outKey != null && !outKey.equals("")) {
				targetDevice.addControlledItem(outKey, theInput, DeviceType.OUTPUT);
				Iterator clientModelList = clientModels.iterator();
				while (clientModelList.hasNext()) {
					DeviceModel clientModel = (DeviceModel) clientModelList.next();
					clientModel.addControlledItem(outKey, theInput, type);
				}
			}
		} catch (NumberFormatException ex ){
			logger.log (Level.INFO,"An illegal key was specified for the toggle device " + name);
		}

	}
}
