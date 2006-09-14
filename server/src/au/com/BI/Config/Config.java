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

import au.com.BI.AlarmLogging.*;
import au.com.BI.Messaging.*;
import au.com.BI.AV.*;
import au.com.BI.Alert.*;
import au.com.BI.Camera.*;
import au.com.BI.Command.*;
import au.com.BI.CustomConnect.CustomConnectFactory;
import au.com.BI.CustomInput.*;
import au.com.BI.Audio.*;
import au.com.BI.Analog.*;
import au.com.BI.GC100.*;
import au.com.BI.GroovyModels.GroovyRunBlock;
import au.com.BI.Counter.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Label.LabelFactory;
import au.com.BI.VirtualOutput.*;
import au.com.BI.PulseOutput.*;
import au.com.BI.Macro.*;
import au.com.BI.Home.Controls;
import au.com.BI.Home.VersionManager;
import au.com.BI.IR.*;
import au.com.BI.SMS.SMSFactory;
import au.com.BI.Sensors.*;
import au.com.BI.Raw.RawFactory;

/**
 * @author Colin Canfield
 *
 */

public class Config {
	public Logger logger;
        protected String scriptDirectory;
        protected Security security;

        protected Controls controls;


		protected HashMap <String,String>calendar_message_params;
		public JRobinParser jRobinParser = null;
		protected RawHelper rawHelper;
		protected LightFactory lightFactory;		
		protected SensorFactory sensorFactory;		
		protected SMSFactory smsFactory;		
		protected ToggleSwitchFactory toggleSwitchFactory;		
		protected CustomConnectFactory customConnectFactory;
		protected AVFactory aVFactory;		
		protected AudioFactory audioFactory;		
		protected PulseOutputFactory pulseOutputFactory;		
		protected VirtualOutputFactory virtualOutputFactory;		
		protected CameraFactory cameraFactory;		
		protected LabelFactory labelFactory;
		protected CustomInputFactory customInputFactory;		
		protected CounterFactory counterFactory;		
		protected AlertFactory alertFactory;		
		protected RawFactory rawFactory;		
		protected AnalogFactory analogFactory;		
		protected IRFactory iRFactory;		
		protected Map <String,String>modelRegistry = null;
		protected Map <String,GroovyRunBlock>groovyModels = null;
		protected MacroHandler macroHandler = null;
		protected Bootstrap bootstrap = null;
		protected  AddressBook addressBook = null;
		protected VersionManager versionManager = null;
		protected  AlarmLogging alarmLogging = null;
		protected au.com.BI.GroovyModels.Model groovyModelHandler  = null;
		
	public Config() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		rawHelper = new RawHelper();

		controls = null;
		jRobinParser = new JRobinParser();
		lightFactory = new LightFactory() ;

		this.setSensorFactory ( SensorFactory.getInstance()) ;		
		this.setToggleSwitchFactory ( ToggleSwitchFactory.getInstance()) ;		
		this.setAVFactory(AVFactory.getInstance()) ;		
		this.setAudioFactory(AudioFactory.getInstance());		
		this.setPulseOutputFactory(PulseOutputFactory.getInstance());		
		this.setVirtualOutputFactory ( VirtualOutputFactory.getInstance());	
		this.setCameraFactory ( CameraFactory.getInstance());		
		this.setCustomInputFactory ( CustomInputFactory.getInstance());		
		this.setCounterFactory (  CounterFactory.getInstance());	
		this.setAlertFactory (AlertFactory.getInstance());		
		this.setRawFactory (RawFactory.getInstance());		
		this.setAnalogFactory ( AnalogFactory.getInstance());		
		this.setIRFactory (IRFactory.getInstance());		
		this.setSmsFactory(SMSFactory.getInstance());
		this.setLabelFactory (LabelFactory.getInstance());
		this.setCustomConnectFactory(CustomConnectFactory.getInstance());
		
		calendar_message_params = new HashMap<String,String> (5);
		calendar_message_params.put ("ICON","");
		calendar_message_params.put ("HIDECLOSE","HIDECLOSE");
		calendar_message_params.put ("AUTOCLOSE","ON");
		calendar_message_params.put ("TARGET","All");
	}

        public void prepareToReadConfigs (List deviceModels,Controls controls) {
            jRobinParser.clearRRDS();
            removeModels (deviceModels);
            macroHandler.setCalendar_message_params (this.calendar_message_params);
            this.controls = controls;
            controls.clearVariables();
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


	@SuppressWarnings("unchecked")
	public void readConfig(List <DeviceModel>deviceModels, List clientModels,Cache cache,
			HashMap <String,Object>variableCache, CommandQueue commandQueue, 
			IRCodeDB irCodeDB, File configFile,Controls controls)
			throws ConfigError {
		// Create an instance of the tester and test
		try {

			SAXBuilder builder = null;

			Iterator clientModelList = clientModels.iterator();
			while (clientModelList.hasNext()) {
				DeviceModel model = (DeviceModel) clientModelList.next();
				model.clearItems();
			}
			builder = new SAXBuilder();
			Document doc = builder.build(configFile);
			Element theConfig = doc.getRootElement();

			List <Element>deviceConfigs = (List<Element>)theConfig.getChildren("DEVICE");
			for (Element config: deviceConfigs){
					DeviceModel newDeviceModel = parseDeviceModel(config, deviceModels, clientModels);
					if (newDeviceModel != null){
						logger.log (Level.INFO,"Adding device handler for " + newDeviceModel.getName());
						parseCatalogueList (config,newDeviceModel);
						newDeviceModel.setCommandQueue(commandQueue);
						newDeviceModel.setCache (cache);
                       newDeviceModel.setVariableCache(variableCache);
						newDeviceModel.setMacroHandler(macroHandler);
						newDeviceModel.setModelList(deviceModels);
						newDeviceModel.setBootstrap(bootstrap);
						newDeviceModel.setAddressBook (addressBook);						
						newDeviceModel.setAlarmLogging (alarmLogging);	
						newDeviceModel.setVersionManager(versionManager);
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
		HashMap<String,String>  defs= new HashMap<String,String> (40);
		Iterator rawItemListIterator = rawItemList.iterator();
		while (rawItemListIterator.hasNext()){
			Element rawItem = (Element) rawItemListIterator.next();
			String value = Utility.unEscape (rawItem.getAttributeValue("VALUE"));
			defs.put((String)rawItem.getAttributeValue("CODE"), value);
		}

		deviceModel.setCatalogueDefs (catalogueName,defs);

	}


        public DeviceModel parseDeviceModel(Element deviceConfig,
                                            List deviceModels,
                                            List clientModels) throws
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
                String modelClass = "";
                try {
                	 
                	if (modelRegistry.containsKey(deviceConfigName)){
			                modelClass =  modelRegistry.get(deviceConfigName);
			                if (modelClass == null)return null;
			                if (modelClass.equals(""))return null;
		                    Class deviceModelClass = java.lang.Class.forName(
		                            modelClass);
		                        deviceModel = (DeviceModel) deviceModelClass.
		                            newInstance();
			          } else {
			        	  if (this.groovyModels.containsKey(deviceConfigName)){
			        		  logger.log(Level.INFO, "Setup groovy device . "+ deviceConfigName);
			        		  GroovyRunBlock groovyRunBlock = groovyModels.get(deviceConfigName);
			        		  if (groovyRunBlock == null) return null;
			        		  deviceModel = groovyModelHandler.setupGroovyModel(groovyRunBlock,description);
			        	  } else {
			        		  logger.log(Level.SEVERE, "Device support was requested that has not been implemented yet. "+ deviceConfigName);
			        	  }
			          }
                	if (deviceModel == null) {
                		return null;
                	}
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
				deviceModel.finishedReadingParameters();
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
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.TOGGLE_OUTPUT,groupName,rawHelper);
					}
					if (itemName.equals("PULSE_OUTPUT")) {
						pulseOutputFactory.addPulse(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.PULSE_OUTPUT,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT")) {
						lightFactory.addLight( deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.LIGHT,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_CBUS")) {
						lightFactory.addLight( deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.LIGHT_CBUS,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_DYNALITE")) {
						lightFactory.addLight( deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.LIGHT_DYNALITE,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_DYNALITE_AREA")) {
						lightFactory.addLightArea( deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.LIGHT_DYNALITE_AREA,groupName,rawHelper);
					}
					if (itemName.equals("SENSOR")) {
						sensorFactory.addSensor(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.SENSOR,groupName,rawHelper);
					}
					if (itemName.equals("TEMPERATURE")) {
						sensorFactory.addSensor(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.TEMPERATURE,groupName,rawHelper);
					}
					if (itemName.equals("LIGHT_X10")) {
						if (deviceModel.getName().equals("COMFORT")){
							lightFactory.addLight( deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
									DeviceType.COMFORT_LIGHT_X10_UNITCODE,groupName,rawHelper);
						}
						lightFactory.addLight( deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.COMFORT_LIGHT_X10,groupName,rawHelper);
					}
					if (itemName.equals("TOGGLE_INPUT")) {
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.TOGGLE_INPUT,groupName,rawHelper);
					}
					if (itemName.equals("CONTACT_CLOSURE")) {
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.CONTACT_CLOSURE,groupName,rawHelper);
					}
					if (itemName.equals("TOGGLE_OUTPUT_MONITOR")) {
						toggleSwitchFactory.addToggle(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.TOGGLE_OUTPUT_MONITOR,groupName,rawHelper);
					}
					if (itemName.equals("COUNTER")) {
						counterFactory.addCounter(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.COUNTER,groupName,rawHelper);
					}
					if (itemName.equals("VIRTUAL_OUTPUT")) {
						virtualOutputFactory.addVirtualOutput(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.COUNTER,groupName,rawHelper);
					}
					if (itemName.equals("LABEL")) {
						labelFactory.addLabel(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE, DeviceType.LABEL, groupName, rawHelper);
					}
					if (itemName.equals("RAW_INTERFACE")) {
						rawFactory.addRaw(deviceModel, clientModels, item, MessageDirection.FROM_FLASH,
								DeviceType.RAW_INTERFACE,groupName,rawHelper);
					}
					if (itemName.equals("CUSTOM_INPUT")) {
						customInputFactory.addCustomInput(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.CUSTOM_INPUT,groupName,rawHelper);
					}
					if (itemName.equals("IR")) {
						iRFactory.addIR(deviceModel, clientModels, item, MessageDirection.FROM_FLASH,
								DeviceType.IR,groupName,rawHelper);
					}
					if (itemName.equals("AUDIO")|| itemName.equals("AUDIO_OUTPUT")) {
						audioFactory.addAudio(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.AUDIO,groupName,rawHelper);
					}
					if (itemName.equals("AV") || itemName.equals("AV_OUTPUT") ) {
						aVFactory.addAV(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.AV,groupName,rawHelper);
					}
					if (itemName.equals("CAMERA_INPUT") || itemName.equals("CAMERA")) {
						cameraFactory.addCamera(deviceModel, clientModels, item, MessageDirection.FROM_FLASH,
								DeviceType.CAMERA,groupName,rawHelper);
					}
					if (itemName.equals("ANALOGUE") || itemName.equals ("ANALOG")) {
						analogFactory.addAnalog(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.ANALOGUE,groupName,rawHelper);
					}
					if (itemName.equals("ALERT")) {
						alertFactory.addAlert(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.ALERT,groupName,rawHelper);
					}
					if (itemName.equals("ALARM")) {
						alertFactory.addAlarm(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.ALARM,groupName,rawHelper);
					}
					if (itemName.equals("SMS")) {
						sensorFactory.addSensor(deviceModel, clientModels, item, MessageDirection.FROM_HARDWARE,
								DeviceType.SMS,groupName,rawHelper);
					}
					if (itemName.equals("CUSTOM_CONNECT")) {
						customConnectFactory.addCustomConnect(deviceModel, clientModels, item, MessageDirection.FROM_FLASH,
								DeviceType.CUSTOM_CONNECT,groupName,rawHelper);
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

	public Map getModelRegistry() {
		return modelRegistry;
	}

	public void setModelRegistry(Map <String,String>modelRegistry) {
		this.modelRegistry = modelRegistry;
	}

	public Map getGroovyModels() {
		return groovyModels;
	}

	public void setGroovyModels(Map <String,GroovyRunBlock>groovyModels) {
		this.groovyModels = groovyModels;
	}

	public MacroHandler getMacroHandler() {
		return macroHandler;
	}

	public void setMacroHandler(MacroHandler macroHandler) {
		this.macroHandler = macroHandler;
	}

	public Bootstrap getBootstrap() {
		return bootstrap;
	}

	public void setBootstrap(Bootstrap bootstrap) {
		this.bootstrap = bootstrap;
	}

	public AddressBook getAddressBook() {
		return addressBook;
	}

	public void setAddressBook(AddressBook addressBook) {
		this.addressBook = addressBook;
	}

	public AlarmLogging getAlarmLogging() {
		return alarmLogging;
	}

	public void setAlarmLogging(AlarmLogging alarmLogging) {
		this.alarmLogging = alarmLogging;
	}

	public VersionManager getVersionManager() {
		return versionManager;
	}

	public void setVersionManager(VersionManager versionManager) {
		this.versionManager = versionManager;
	}

	public au.com.BI.GroovyModels.Model getGroovyModelHandler() {
		return groovyModelHandler;
	}

	public void setGroovyModelHandler(
			au.com.BI.GroovyModels.Model groovyModelHandler) {
		this.groovyModelHandler = groovyModelHandler;
	}

	public CustomConnectFactory getCustomConnectFactory() {
		return customConnectFactory;
	}

	public void setCustomConnectFactory(CustomConnectFactory customConnectFactory) {
		this.customConnectFactory = customConnectFactory;
	}

	public SMSFactory getSmsFactory() {
		return smsFactory;
	}

	public void setSmsFactory(SMSFactory smsFactory) {
		this.smsFactory = smsFactory;
	}

	public LabelFactory getLabelFactory() {
		return labelFactory;
	}

	public void setLabelFactory(LabelFactory labelFactory) {
		this.labelFactory = labelFactory;
	}
	
}
