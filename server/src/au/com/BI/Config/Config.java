/*
 * Created on Feb 16, 2004
 *
 */
package au.com.BI.Config;
import java.util.*;

import au.com.BI.Flash.ClientCommand;
import au.com.BI.Util.*;
import au.com.BI.Lights.LightFactory;
import au.com.BI.ToggleSwitch.*;
import java.io.*;
import org.jdom.*;
import org.jdom.input.*;
import java.util.logging.*;

import au.com.BI.AV.*;
import au.com.BI.Alert.*;
import au.com.BI.Camera.*;
import au.com.BI.Command.*;
import au.com.BI.CustomInput.*;
import au.com.BI.Audio.*;
import au.com.BI.Analogue.*;
import au.com.BI.GC100.*;
import au.com.BI.Counter.*;
import au.com.BI.VirtualOutput.*;
import au.com.BI.PulseOutput.*;
import au.com.BI.Macro.*;
import au.com.BI.Home.Controls;
import au.com.BI.IR.*;
import au.com.BI.Sensors.*;
import au.com.BI.Raw.RawFactory;

/**
 * @author Colin Canfield
 *
 */

public class Config {
	public Logger logger;
	protected ConfigHelper configHelper;
        protected String scriptDirectory;
        protected Security security;

        protected Controls controls;


		protected HashMap calendar_message_params;
		public JRobinParser jRobinParser = null;
		protected RawHelper rawHelper;
		protected LightFactory lightFactory;		
		protected SensorFactory sensorFactory;		
		protected ToggleSwitchFactory toggleSwitchFactory;		
		protected AVFactory aVFactory;		
		protected AudioFactory audioFactory;		
		protected PulseOutputFactory pulseOutputFactory;		
		protected VirtualOutputFactory virtualOutputFactory;		
		protected CameraFactory cameraFactory;		
		protected CustomInputFactory customInputFactory;		
		protected CounterFactory counterFactory;		
		protected AlertFactory alertFactory;		
		protected RawFactory rawFactory;		
		protected AnalogFactory analogFactory;		
		protected IRFactory iRFactory;		

	public Config() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		configHelper = new ConfigHelper();
		rawHelper = new RawHelper();

		controls = null;
		jRobinParser = new JRobinParser();
		lightFactory = new LightFactory() ;

		this.setSensorFactory ( new SensorFactory()) ;		
		this.setToggleSwitchFactory (new ToggleSwitchFactory()) ;		
		this.setAVFactory(new AVFactory()) ;		
		this.setAudioFactory(new AudioFactory());		
		this.setPulseOutputFactory(new PulseOutputFactory());		
		this.setVirtualOutputFactory (new VirtualOutputFactory ());	
		this.setCameraFactory (new CameraFactory ());		
		this.setCustomInputFactory (new CustomInputFactory ());		
		this.setCounterFactory ( new CounterFactory ());	
		this.setAlertFactory (new AlertFactory ());		
		this.setRawFactory (new RawFactory ());		
		this.setAnalogFactory ( new AnalogFactory ());		
		this.setIRFactory (new IRFactory ());		
		
		calendar_message_params = new HashMap (5);
		calendar_message_params.put ("ICON","");
		calendar_message_params.put ("HIDECLOSE","HIDECLOSE");
		calendar_message_params.put ("AUTOCLOSE","ON");
		calendar_message_params.put ("TARGET","All");
	}

	public void removeModels (List deviceModels) {
		Iterator eachDeviceModel = deviceModels.iterator();
		while (eachDeviceModel.hasNext()) {
			DeviceModel theModel = (DeviceModel)eachDeviceModel.next();
			if (theModel.removeModelOnConfigReload()) {
				eachDeviceModel.remove();
			}
		}

	}


	public void readConfig(List deviceModels, List clientModels,Cache cache,HashMap variableCache, List commandQueue, Map modelRegistry,
			IRCodeDB irCodeDB, String fileName, MacroHandler macroHandler, Bootstrap bootstrap, Controls controls)
			throws ConfigError {
		// Create an instance of the tester and test
		try {
			jRobinParser.clearRRDS();


			removeModels( deviceModels);
			this.controls = controls;
			macroHandler.setCalendar_message_params (this.calendar_message_params);
			controls.clearVariables();
			SAXBuilder builder = null;

			Iterator clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel model = (DeviceModel) clientModelList.next();
				model.clearItems();
			}
			builder = new SAXBuilder();
			Document doc = builder.build(fileName);
			Element theConfig = doc.getRootElement();

			List deviceConfigs = theConfig.getChildren("DEVICE");
			Iterator deviceConfigList = deviceConfigs.iterator();
			while (deviceConfigList.hasNext()) {
				Element config = (Element) deviceConfigList.next();
					DeviceModel newDeviceModel = parseDeviceModel(config, deviceModels, clientModels, modelRegistry);
					if (newDeviceModel != null){
						logger.log (Level.INFO,"Adding device handler for " + newDeviceModel.getName());
						parseCatalogueList (config,newDeviceModel);
						newDeviceModel.setCommandQueue(commandQueue);
						newDeviceModel.setCache (cache);
                                                newDeviceModel.setVariableCache(variableCache);
						newDeviceModel.setMacroHandler(macroHandler);
						newDeviceModel.setModelList(deviceModels);
						newDeviceModel.setBootstrap(bootstrap);
						deviceModels.add(newDeviceModel);
						newDeviceModel.setInstanceID(deviceModels.size()-1);
					}
			}
			List jRobinConfigs = theConfig.getChildren ("JROBIN");
			Iterator eachJRobinConfig = jRobinConfigs.iterator();
			while (eachJRobinConfig.hasNext()) {
				Element jRobinConfig = (Element)eachJRobinConfig.next();
				jRobinParser.parseJRobinConfig (this, jRobinConfig);
			}
			List controlsList = theConfig.getChildren ("CONTROLS");
			Iterator eachControl = controlsList.iterator();
			while (eachControl.hasNext()) {
				Element control = (Element)eachControl.next();
				parseControl (control);
			}
		} catch (JDOMException e) {
			throw new ConfigError(e);
		} catch (IOException e) {
			throw new ConfigError(e);
		}
	}


        public void parseControl (Element controlElement) {
		synchronized (controls) {
			List controlSectionList = controlElement.getChildren("VARIABLES");
			Iterator controlSectionIter = controlSectionList.iterator();
			while (controlSectionIter.hasNext()) {
				Element controlItem = (Element)controlSectionIter.next();
				List variablesBlockList = controlItem.getChildren();
				Iterator eachVariableBlockItemIter = variablesBlockList.iterator();
				while (eachVariableBlockItemIter.hasNext()) {
					Element variableBlockItem = (Element)eachVariableBlockItemIter.next();
					if (variableBlockItem.getName().equals ("VARIABLE")) {
						String active = (String)variableBlockItem.getAttributeValue("ACTIVE");
						if (active == null || !active.equals("N")) {
							String displayName = (String)variableBlockItem.getAttributeValue("DISPLAY_NAME");
							String name = (String)variableBlockItem.getAttributeValue("NAME");
							String initCommand = (String)variableBlockItem.getAttributeValue("INIT_COMMAND");
							String initExtra= (String)variableBlockItem.getAttributeValue("INIT_EXTRA");
							String initExtra2= (String)variableBlockItem.getAttributeValue("INIT_EXTRA2");
							String initExtra3= (String)variableBlockItem.getAttributeValue("INIT_EXTRA3");
							String initExtra4= (String)variableBlockItem.getAttributeValue("INIT_EXTRA4");
							String initExtra5= (String)variableBlockItem.getAttributeValue("INIT_EXTRA5");
							if (displayName != null && !displayName.equals ("") && name != null && !name.equals ("")) {
								ClientCommand newVar = new ClientCommand();
								newVar.setKey(displayName);
								newVar.setDisplayName(displayName);
								newVar.setCommand(initCommand);
								newVar.setExtraInfo(initExtra);
								newVar.setExtra2Info(initExtra2);
								newVar.setExtra3Info(initExtra3);
								newVar.setExtra4Info(initExtra4);
								newVar.setExtra5Info(initExtra5);
								controls.addVariable(displayName,newVar);
							}
						}
					}
				}
			}
			List calendarParameters = controlElement.getChildren("CALENDAR_MESSAGES");
			Iterator calSectionIter = calendarParameters.iterator();
			while (calSectionIter.hasNext()) {
				Element controlItem = (Element)calSectionIter.next();
				List variablesBlockList = controlItem.getChildren();
				Iterator eachVariableBlockItemIter = variablesBlockList.iterator();
				while (eachVariableBlockItemIter.hasNext()) {
					Element variableBlockItem = (Element)eachVariableBlockItemIter.next();
					if (variableBlockItem.getName().equals ("ITEM")) {
						String name = (String)variableBlockItem.getAttributeValue("NAME");
						String value = (String)variableBlockItem.getAttributeValue("VALUE");
						if (name != null && value != null && !name.equals("") && !value.equals ("")) {
							synchronized (calendar_message_params) {
								this.calendar_message_params.put(name,value);
							}
						}
					}
				}
			}

		}
		
		logger.log (Level.FINE,"Configured control section");
	}


	public void parseCatalogueList (Element element, DeviceModel deviceModel) throws JDOMException{
		List rawConfigs = element.getChildren("RAW_DEFS");
		Iterator rawConfigList = rawConfigs.iterator();
		while (rawConfigList.hasNext()) {
			Element config = (Element) rawConfigList.next();
			parseRawDefs(config,deviceModel);
		}
		List catalogueConfigs = element.getChildren("CATALOGUE");
		Iterator catalogueList = catalogueConfigs.iterator();
		while (catalogueList.hasNext()) {
			Element config = (Element) catalogueList.next();
			parseRawDefs(config,deviceModel);
		}

		List comfortUsers = element.getChildren("COMFORT_USERS");
		Iterator comfortUserList = comfortUsers.iterator();
		while (comfortUserList.hasNext()) {
			Element config = (Element) comfortUserList.next();
			parseRawDefDetails("COMFORT_USERS",config,deviceModel);
		}
	}

	public void parseRawDefs(Element deviceConfig, DeviceModel deviceModel) throws JDOMException {
		String name = deviceConfig.getAttributeValue("NAME");
		if (name == null)  {
			logger.log(Level.SEVERE, "No name specifed for raw catalogue");
		}
		parseRawDefDetails (name, deviceConfig, deviceModel);
	}

	public void parseRawDefDetails (String catalogueName, Element deviceConfig, DeviceModel deviceModel) throws JDOMException {
		List rawItemList = deviceConfig.getChildren();
		HashMap rawDefs = new HashMap (400);
		Iterator rawItemListIterator = rawItemList.iterator();
		while (rawItemListIterator.hasNext()){
			Element rawItem = (Element) rawItemListIterator.next();
			String value = Utility.unEscape (rawItem.getAttributeValue("VALUE"));
			rawDefs.put(rawItem.getAttributeValue("CODE"), value);
		}

		deviceModel.setCatalogueDefs (catalogueName,rawDefs);

	}


        public DeviceModel parseDeviceModel(Element deviceConfig,
                                            List deviceModels,
                                            List clientModels,
                                            Map modelRegistry) throws
            JDOMException {
                int intPowerRating = 0;
                String deviceActive = deviceConfig.getAttributeValue("ACTIVE");
                if (deviceActive != null && !deviceActive.equals("Y"))return null;

                String deviceConfigName = deviceConfig.getAttributeValue("DEVICE_TYPE");
                if (deviceConfigName == null) {
                	deviceConfigName = deviceConfig.getAttributeValue("NAME");
                }
                     
                String description = deviceConfig.getAttributeValue(
                    "DESCRIPTION");
                if (description == null) {
                		description = deviceConfig.getAttributeValue("DISPLAY_NAME");
                }
                String username = deviceConfig.getAttributeValue("USER");
                String password = deviceConfig.getAttributeValue("PASSWORD");

                if (username == null) username = "";
                if (password == null) password = "";

                String powerRating = deviceConfig.getAttributeValue("POWER_RATING");
                if (powerRating == null) intPowerRating = 0;

                try {
                        intPowerRating = Integer.parseInt(powerRating);
                }
                catch (NumberFormatException ex) {
                        intPowerRating = 0;
                }

                jRobinParser.addPowerRating(description, intPowerRating);

                DeviceModel deviceModel = null;

                String modelClass = (String) modelRegistry.get(deviceConfigName);
                if (modelClass == null)return null;
                if (modelClass.equals(""))return null;

                try {
                        Class deviceModelClass = java.lang.Class.forName(
                            modelClass);
                        deviceModel = (DeviceModel) deviceModelClass.
                            newInstance();
                }
                catch (ClassNotFoundException e) {
                        logger.log(Level.SEVERE,
                            "Unknown class specified in configuration file " +
                                   e.getMessage());
                        return null;
                }
                catch (IllegalAccessException e) {
                        logger.log(Level.SEVERE,
                            "Unknown class specified in configuration file " +
                                   e.getMessage());
                        return null;
                }
                catch (InstantiationException e) {
                        logger.log(Level.SEVERE,
                            "Class in config is not derived from Device Model " +
                                   modelClass);
                        return null;
                }
                deviceModel.setName(deviceConfigName);
                deviceModel.setDescription(description);

                deviceModel.setParameter("User", username,
                                         DeviceModel.MAIN_DEVICE_GROUP);
                deviceModel.setParameter("Password", password,
                                         DeviceModel.MAIN_DEVICE_GROUP);

                parseConnection(deviceConfig, deviceModel);

                parseDevices(deviceConfig, deviceModel, clientModels,
                             DeviceModel.MAIN_DEVICE_GROUP);
                return deviceModel;
        }


	protected void parseConnection (Element deviceSpec, DeviceModel deviceModel ) {
		String baudRate="";
		String stopBits = "";
		String supportsCD = "Y";
		String dataBits = "";
		String parity = "";
		String flowControl = "";

		List connectionBlocks = deviceSpec.getChildren("CONNECTION");
		if (connectionBlocks.size() == 0) {
			logger.log (Level.WARNING,"No connection block specified for " + deviceModel.getName());
			return;
		}
		Element block = (Element)connectionBlocks.get(0);
		List connectionStrings = block.getChildren();
		Iterator eachConnectionString = connectionStrings.iterator();
		while (eachConnectionString.hasNext()) {
			Element connectLine = (Element) eachConnectionString.next();
			String active = connectLine.getAttributeValue("ACTIVE");
			if (active == null || active.equals("Y")) {
				String deviceConnectionTypeString = connectLine.getName();
				deviceModel.setParameter ("Connection_Type", deviceConnectionTypeString,DeviceModel.MAIN_DEVICE_GROUP);

				String devicePort = connectLine.getAttributeValue("PORT");
				String ipAddress = connectLine.getAttributeValue("IP_ADDRESS");
				deviceModel.setParameter ("IP_Address", ipAddress,DeviceModel.MAIN_DEVICE_GROUP);
				deviceModel.setParameter ("Device_Port", devicePort,DeviceModel.MAIN_DEVICE_GROUP);

				if (deviceConnectionTypeString.equals( ("SERIAL"))){
					 baudRate = connectLine.getAttributeValue("BAUD");
					 dataBits = connectLine.getAttributeValue("DATA_BITS");
					 stopBits = connectLine.getAttributeValue("STOP_BITS");
					 parity = connectLine.getAttributeValue("PARITY");
					 flowControl = connectLine.getAttributeValue("FLOW");
					 supportsCD = connectLine.getAttributeValue("SUPPORTS_CD");
				}
				if (deviceConnectionTypeString.equals( ("SERIAL"))){
					deviceModel.setParameter ("Baud_Rate", baudRate,DeviceModel.MAIN_DEVICE_GROUP);
					deviceModel.setParameter ("Flow_Control", flowControl,DeviceModel.MAIN_DEVICE_GROUP);
					deviceModel.setParameter ("Stop_Bits",stopBits,DeviceModel.MAIN_DEVICE_GROUP);
					deviceModel.setParameter ("Data_Bits",dataBits,DeviceModel.MAIN_DEVICE_GROUP);
					deviceModel.setParameter ("Parity",parity,DeviceModel.MAIN_DEVICE_GROUP);
					deviceModel.setParameter ("Supports_CD",supportsCD,DeviceModel.MAIN_DEVICE_GROUP);
					 if (baudRate == null || dataBits == null || stopBits == null || parity == null){
					 	logger.log(Level.SEVERE,"Serial parameters incorrect for " + deviceModel.getName());
					 	return;
					 }
				}
			}
		}
	}

	protected void parseDevices(Element deviceConfig, DeviceModel deviceModel,
				List clientModels, String groupName) throws JDOMException {
		int type;
		int groupNumber = 1; // used if a name is not specified; group 0 is reserved for overall device confuration

		// An item is the next level
		List itemList = deviceConfig.getChildren();
		Iterator items = itemList.iterator();
		while (items.hasNext()) {
			Element topLevel = (Element) items.next();
			String topLevelName = topLevel.getName();
			boolean foundElement = false;

			if (topLevelName.equals ("PARAMETERS")) {
				readParameters (deviceModel,topLevel,groupName);
				type = DeviceType.NA;
				foundElement = true;
			}
			if (topLevelName.equals ("CATALOGUE") || topLevelName.equals("CONNECTION")) {
				foundElement = true;
			}

			if (!foundElement) {
                                String powerRating;
                                int intPowerRating;
				String deviceSpecName = topLevel.getName();

				String group = topLevel.getAttributeValue("NAME");
				if (group == null) 
					groupName = "Group" + groupNumber;
				else
					groupName = group;

				groupNumber ++;

				List deviceSpecDetailsList = topLevel.getChildren();
				Iterator deviceSpecDetailsIter = deviceSpecDetailsList.iterator();
				while (deviceSpecDetailsIter.hasNext()) {
					Element item = (Element)deviceSpecDetailsIter.next();
					String itemName = item.getName();
					String itemActive = item.getAttributeValue ("ACTIVE");
					if (itemActive != null && itemActive.equals ( "N")) {
						continue;
					}

                    powerRating = item.getAttributeValue("POWER_RATING");
                    if (powerRating != null) {
                    	 try {
                    		Integer intgrPowerRating = new Integer(powerRating);
                            intPowerRating = intgrPowerRating.intValue();
                            String key = item.getAttributeValue("DISPLAY_NAME");
                            jRobinParser.addPowerRating(key, intPowerRating);
                    	 } catch (NumberFormatException ex){}
                    }

					if (itemName.equals ("PARAMETERS")) {
						readParameters (deviceModel,item,groupName);
						type = DeviceType.NA;
					}

					if (itemName.equals("TOGGLE_OUTPUT")) {
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.TOGGLE_OUTPUT,groupName,rawHelper);
					}
					if (itemName.equals("PULSE_OUTPUT")) {
						pulseOutputFactory.addPulse(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.PULSE_OUTPUT,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_CBUS")) {
						lightFactory.addLight( deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.LIGHT_CBUS,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_DYNALITE")) {
						lightFactory.addLight( deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.LIGHT_DYNALITE,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_DYNALITE_AREA")) {
						lightFactory.addLightArea( deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.LIGHT_DYNALITE_AREA,groupName,rawHelper);
					}
					if (itemName.equals("SENSOR")) {
						sensorFactory.addSensor(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.SENSOR,groupName,rawHelper);
					}
					if (itemName.equals("TEMPERATURE")) {
						sensorFactory.addSensor(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.TEMPERATURE,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_X10")) {
						lightFactory.addLight( deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.COMFORT_LIGHT_X10_UNITCODE,groupName,rawHelper);
						lightFactory.addLight( deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.COMFORT_LIGHT_X10,groupName,rawHelper);
					}
					if (itemName.equals("TOGGLE_INPUT")) {
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, DeviceType.INPUT,
								DeviceType.TOGGLE_INPUT,groupName,rawHelper);
					}
					if (itemName.equals("CONTACT_CLOSURE")) {
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, DeviceType.INPUT,
								DeviceType.CONTACT_CLOSURE,groupName,rawHelper);
					}
					if (itemName.equals("TOGGLE_OUTPUT_MONITOR")) {
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.TOGGLE_OUTPUT_MONITOR,groupName,rawHelper);
					}
					if (itemName.equals("COUNTER")) {
						counterFactory.addCounter(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.COUNTER,groupName,rawHelper);
					}
					if (itemName.equals("VIRTUAL_OUTPUT")) {
						virtualOutputFactory.addVirtualOutput(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.COUNTER,groupName,rawHelper);
					}
					if (itemName.equals("RAW_INTERFACE")) {
						rawFactory.addRaw(deviceModel, clientModels, item, DeviceType.OUTPUT,
								DeviceType.RAW_INTERFACE,groupName,rawHelper);
					}
					if (itemName.equals("CUSTOM_INPUT")) {
						customInputFactory.addCustomInput(deviceModel, clientModels, item, DeviceType.INPUT,
								DeviceType.CUSTOM_INPUT,groupName,rawHelper);
					}
					if (itemName.equals("IR")) {
						iRFactory.addIR(deviceModel, clientModels, item, DeviceType.OUTPUT,
								DeviceType.IR,groupName,rawHelper);
					}
					if (itemName.equals("AUDIO")|| itemName.equals("AUDIO_OUTPUT")) {
						audioFactory.addAudio(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.AUDIO,groupName,rawHelper);
					}
					if (itemName.equals("AV") || itemName.equals("AV_OUTPUT") ) {
						aVFactory.addAV(deviceModel, clientModels, item, DeviceType.INPUT,
								DeviceType.AV,groupName,rawHelper);
					}
					if (itemName.equals("CAMERA_INPUT") || itemName.equals("CAMERA")) {
						cameraFactory.addCamera(deviceModel, clientModels, item, DeviceType.OUTPUT,
								DeviceType.CAMERA,groupName,rawHelper);
					}
					if (itemName.equals("ANALOGUE") || itemName.equals ("ANALOG")) {
						analogFactory.addAnalogue(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.ANALOGUE,groupName,rawHelper);
					}
					if (itemName.equals("ALERT")) {
						alertFactory.addAlert(deviceModel, clientModels, item, DeviceType.MONITORED,
								DeviceType.ALERT,groupName,rawHelper);
					}
					if (itemName.equals("ALARM")) {
						alertFactory.addAlarm(deviceModel, clientModels, item, DeviceType.OUTPUT,
								DeviceType.ALARM,groupName,rawHelper);
					}
				}
			}
		}
	}

	/**
	 * Generic parameters to all devices
	 *
	 */
	public void readParameters (DeviceModel deviceModel,Element parameterBlock,String groupName) {
		List parameters = parameterBlock.getChildren("ITEM");
		Iterator eachParameter = parameters.iterator();
		while (eachParameter.hasNext()) {
			Element parameter = (Element)eachParameter.next();
			String paramKey = parameter.getAttributeValue("NAME");
			String paramValue = parameter.getAttributeValue("VALUE");
			if (paramKey != null && !paramKey.equals ("")) {
				deviceModel.setParameter(paramKey,Utility.unEscape(paramValue),groupName);
			}
		}

	}

	public String padTo2(String key){
		if (key.length() ==1) {
			return "0" + key;
		} else {
			return key;
		}
	}
	
	public HashMap getCalendar_message_params() {
		return calendar_message_params;
	}

	public Security getSecurity() {
		return security;
	}

	public final void setSecurity(Security security) {
		this.security = security;
	}

	public void setAlertFactory(AlertFactory alertFactory) {
		this.alertFactory = alertFactory;
	}

	public void setAnalogFactory(AnalogFactory analogFactory) {
		this.analogFactory = analogFactory;
	}

	public void setAudioFactory(AudioFactory audioFactory) {
		this.audioFactory = audioFactory;
	}

	public void setAVFactory(AVFactory factory) {
		aVFactory = factory;
	}

	public void setCameraFactory(CameraFactory cameraFactory) {
		this.cameraFactory = cameraFactory;
	}

	public void setCounterFactory(CounterFactory counterFactory) {
		this.counterFactory = counterFactory;
	}

	public void setCustomInputFactory(CustomInputFactory customInputFactory) {
		this.customInputFactory = customInputFactory;
	}

	public void setIRFactory(IRFactory factory) {
		iRFactory = factory;
	}

	public void setLightFactory(LightFactory lightFactory) {
		this.lightFactory = lightFactory;
	}

	public void setPulseOutputFactory(PulseOutputFactory pulseOutputFactory) {
		this.pulseOutputFactory = pulseOutputFactory;
	}

	public void setRawFactory(RawFactory rawFactory) {
		this.rawFactory = rawFactory;
	}

	public void setSensorFactory(SensorFactory sensorFactory) {
		this.sensorFactory = sensorFactory;
	}

	public void setToggleSwitchFactory(ToggleSwitchFactory toggleSwitchFactory) {
		this.toggleSwitchFactory = toggleSwitchFactory;
	}

	public void setVirtualOutputFactory(VirtualOutputFactory virtualOutputFactory) {
		this.virtualOutputFactory = virtualOutputFactory;
	}
	
}
