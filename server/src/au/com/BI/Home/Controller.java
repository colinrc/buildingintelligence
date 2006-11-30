/*
 * Created on Dec 28, 2003
 *
 */
package au.com.BI.Home;

import au.com.BI.User.*;
import au.com.BI.Jetty.*;
import org.quartz.*;
import au.com.BI.Util.*;
import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.LabelMgr.LabelError;
import au.com.BI.LabelMgr.LabelMgr;
import au.com.BI.Macro.*;
import au.com.BI.Maintainance.DailyTaskFactory;
import au.com.BI.Messaging.*;

import java.util.logging.*;
import java.util.*;
import java.io.*;

import au.com.BI.Admin.LogHandler;
import au.com.BI.Flash.*;
import au.com.BI.GC100.IRCodeDB;
import au.com.BI.Config.*;
import au.com.BI.AlarmLogging.*;
import au.com.BI.JRobin.*;
import org.jrobin.core.*;

/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:53 PM
 */

public class Controller {
	protected User currentUser;

	protected Logger logger;

	protected CommandQueue commandQueue;

	protected boolean running;

	protected FlashHandler flashHandler;

	protected au.com.BI.Admin.Model adminModel;

	protected au.com.BI.Macro.Model macroModel;

	protected au.com.BI.Messaging.Model messagingModel;

	protected String configFile = "";

	protected int clientPort = 10000;

	protected String bindToAddress;

	protected Config config;

	protected ArrayList<DeviceModel> deviceModels;

	protected ArrayList<DeviceModel> clientModels;

	protected boolean configLoaded;

	protected HashMap<String, String> modelRegistry;

	protected au.com.BI.Command.Cache cache;

	protected MacroHandler macroHandler;

	protected HashMap iRControllers;

	protected IRCodeDB irCodeDB;

	protected EventCalendar eventCalendar;

	protected Bootstrap bootstrap;

	private Security security = null;

	protected AlarmLogging alarmLogging = null;

	protected LabelMgr labelMgr = null;

	protected au.com.BI.Script.Model scriptModel;

	protected au.com.BI.GroovyModels.Model groovyModelHandler;

	protected JRobinQuery jrobin;

	public JRobinSupport jRobinSupport;

	protected Controls controls;

	protected LogHandler logHandler;

	protected AddressBook addressBook = null;

	protected JettyHandler jettyHandler = null;

	protected VersionManager versionManager = null;

	protected DailyTaskFactory dailyTasks = null;

	// All known object representations of devices active in the system
	/**
	 * Creates a new controller class. A logger called au.com.BI.House should be
	 * created before this A model will be initialised for system controls
	 * 
	 */
	public Controller() {
		deviceModels = new ArrayList<DeviceModel>();
		clientModels = new ArrayList<DeviceModel>();
		modelRegistry = new HashMap<String, String>(10);
		commandQueue = new CommandQueue();
		jRobinSupport = new JRobinSupport();
		cache = new Cache(jRobinSupport);
		cache.setController(this);
		security = new Security();
		addressBook = new AddressBook();
		alarmLogging = new AlarmLogging();
		alarmLogging.setCache(cache);
		alarmLogging.setCommandQueue(commandQueue);

		configLoaded = false;

		modelRegistry.put("COMFORT", "au.com.BI.Comfort.Model");
		modelRegistry.put("RAW_CONNECTION", "au.com.BI.Raw.Model");
		modelRegistry.put("FLASH_CLIENT", "au.com.BI.Flash.FlashHandler");
		modelRegistry.put("ADMIN", "au.com.BI.Admin.Model");
		modelRegistry.put("MESSAGING", "au.com.BI.Messaging.Model");
		modelRegistry.put("JETTY", "au.com.BI.Jetty.JettyHandler");
		modelRegistry.put("GROOVY", "au.com.BI.GroovyModels.Model");
		modelRegistry.put("HAL", "au.com.BI.HAL.Model");
		modelRegistry.put("TUTONDO", "au.com.BI.Tutondo.Model");
		modelRegistry.put("KRAMER", "au.com.BI.Kramer.Model");
		modelRegistry.put("DYNALITE", "au.com.BI.Dynalite.Model");
		modelRegistry.put("CBUS", "au.com.BI.CBUS.Model");
		modelRegistry.put("GC100", "au.com.BI.GC100.Model");
		modelRegistry.put("OREGON", "au.com.BI.OregonScientific.Model");
		modelRegistry.put("PELCO", "au.com.BI.Pelco.Model");
		modelRegistry.put("IR_LEARNER", "au.com.BI.IR.Model");
		modelRegistry.put("M1", "au.com.BI.M1.Model");
		modelRegistry.put("NUVO", "au.com.BI.Nuvo.Model");
		modelRegistry.put("SIGN_VIDEO", "au.com.BI.SignVideo.Model");
		modelRegistry.put("MACRO", "au.com.BI.Macro.Model");
		modelRegistry.put("SCRIPT", "au.com.BI.Script.Model");

	}

	public void setUp() throws CommsFail {
		controls = new Controls(cache);

		macroHandler = new MacroHandler();
		macroHandler.setFileName("macros");
		macroHandler.setCache(cache);
		macroHandler.setIntegratorFileName("integrator_macros");
		macroHandler.setCalendarFileName("calendar");
		macroHandler.setCommandList(commandQueue);
		if (!macroHandler.readMacroFile(false) && logger != null) {
			logger.log(Level.WARNING, "Could not read user macro file");
		}
		if (!macroHandler.readMacroFile(true) && logger != null) {
			logger.log(Level.WARNING, "Could not read integrator macro file");
		}

		try {
			macroHandler.startCalendar(currentUser);
		} catch (SchedulerException ex) {
			logger.log(Level.SEVERE,
					"Event scheduler failed to start, timed events will not be availlable. "
							+ ex.getMessage());
		}

		labelMgr = new LabelMgr();
		try {
			labelMgr.readLabelFile("datafiles", "labels.xml");
		} catch (LabelError e) {
			logger
					.log(Level.SEVERE, "Label setup has failed "
							+ e.getMessage());
		}

		scriptModel = new au.com.BI.Script.Model();
		scriptModel.setController(this);
		this.setupModel(scriptModel);
		scriptModel.setInstanceID(deviceModels.size() - 1);

		flashHandler = new FlashHandler(DeviceModel.PROBABLE_FLASH_CLIENTS,
				security);
		this.setupModel(flashHandler);
		flashHandler.setEventCalendar(macroHandler.getEventCalendar());
		clientModels.add(flashHandler);

		adminModel = new au.com.BI.Admin.Model(1);
		this.setupModel(adminModel);
		adminModel.setLogHandler(logHandler);
		deviceModels.add(adminModel);
		adminModel.setInstanceID(deviceModels.size() - 1);

		messagingModel = new au.com.BI.Messaging.Model();
		this.setupModel(messagingModel);
		deviceModels.add(messagingModel);
		messagingModel.setInstanceID(deviceModels.size() - 1);

		macroModel = new au.com.BI.Macro.Model();
		this.setupModel(macroModel);
		deviceModels.add(macroModel);
		macroModel.setInstanceID(deviceModels.size() - 1);

		jettyHandler = new JettyHandler(security);
		this.setupModel(jettyHandler);
		deviceModels.add(jettyHandler);
		jettyHandler.setInstanceID(deviceModels.size() - 1);

		groovyModelHandler = new au.com.BI.GroovyModels.Model();
		this.setupModel(groovyModelHandler);
		deviceModels.add(groovyModelHandler);
		groovyModelHandler.setInstanceID(deviceModels.size() - 1);

		dailyTasks = new DailyTaskFactory();
		dailyTasks.setStartTime(bootstrap.getMaintenanceTime());
		dailyTasks.setMacroHandler(macroHandler);
		dailyTasks.start();

		try {
			jettyHandler.start();
		} catch (Exception ex) {
			logger.log(Level.SEVERE, "Could not start web server "
					+ ex.getMessage());
		}
	}

	public void setupModel(DeviceModel model) {
		model.setCommandQueue(commandQueue);
		model.setCache(cache);
		model.setVariableCache(jRobinSupport.variableCache);
		model.setMacroHandler(macroHandler);
		model.setModelList(deviceModels);
		model.setBootstrap(bootstrap);
		model.setVersionManager(versionManager);
		model.setAddressBook(addressBook);
		model.setAlarmLogging(alarmLogging);
		model.setLabelMgr(labelMgr);
		model.setEventCalendar(macroHandler.getEventCalendar());
		model.setInstanceID(deviceModels.size() - 1);
		// If adding items to here remember to also add them to
		// config.readConfig.
		// These should be fixed to both use the same method CC
	}

	public void setUpClients() throws CommsFail {
		flashHandler.startListenning(bindToAddress, clientPort);
	}

	public void closeDownClients() throws CommsFail {
		try {
			if (flashHandler != null) {
				flashHandler.closeComms();
			}
		} catch (ConnectionFail ex) {
		}
	}

	public void setUpAdmin() throws CommsFail {
		adminModel.startListenning(bootstrap.getAdminIP(), bootstrap
				.getAdminPort());
	}

	public void stopControlling() {
		running = false;
	}

	public void setConfigFile(String configFile) {
		this.configFile = configFile;
	}

	/**
	 * Main entry point for the handling loop
	 * 
	 */
	public void run() {
		currentUser = new User();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		logger.setLevel(Level.INFO);
		config = new Config();
		config.setSecurity(security);
		config.setModelRegistry(modelRegistry);
		config.setMacroHandler(macroHandler);
		config.setBootstrap(bootstrap);
		config.setVersionManager(versionManager);
		config.setAlarmLogging(alarmLogging);
		config.setAddressBook(addressBook);
		config.setLabelMgr(labelMgr);
		config.setGroovyModels(this.groovyModelHandler.getGroovyModelClasses());
		config.setGroovyModelHandler(groovyModelHandler);
		boolean commandDone;

		logger.fine("Started the controller");
		Iterator deviceModelList;
		boolean successfulCommand = false;

		irCodeDB = new IRCodeDB();
		try {
			this.setUpClients();

			running = true;

			if (!configFile.equals("")) {
				doReadConfig("config", configFile);
			} else {
				doReadConfig("config", bootstrap.getConfigFile());
			}

			doSystemStartup(deviceModels);
			if (config.jRobinParser.isJRobinActive()) {

				jRobinSupport.doJRobinStartup(bootstrap, this,  cache, config.jRobinParser);
			}
			this.setUpAdmin();
			this.macroHandler.runStartup();

		} catch (CommsFail ex) {
			System.err.println("Could not set up flash interface");

			logger.log(Level.SEVERE, "Could not set up flash interface");
			try {
				this.closeDownClients();
			} catch (CommsFail ex2) {

			}
			running = false;
		}

		while (running) {
			CommandInterface item;
			commandDone = false;
			if (!commandQueue.isEmpty()) {
				item = (CommandInterface) commandQueue.remove();
				successfulCommand = false;
			} else {
				item = null;
			}
			if (item != null) {

				String itemKey = item.getKey();

				controls.doCommand(item);
				// if (!commandDone &&
				// item.getClass().getName().equals("au.com.BI.Flash.ClientCommand"))
				// {
				// flashHandler.broadcastCommand(item);
				// }
				if (itemKey.equals("SYSTEM")) {
					doCommand(item); // Handled here
					commandDone = true;
				}
				if (item.isAdminCommand()) {
					adminModel.doCommand(item);
					commandDone = true;
				}

				boolean jrobinSet = false;
				if (itemKey.equals("RRDUPDATE")) {
					jrobinSet = true;
					if (!config.jRobinParser.isJRobinActive()) {
						commandDone = true;
					}
					RRDValueObject rrdVO;
					rrdVO = (RRDValueObject) item.getRrdValueObject();
					if (rrdVO.getRRDValues().length > 0) {
						jRobinSupport.rrdUpdate(rrdVO.getRRD(), rrdVO.getStartTime(), rrdVO
								.getRRDValues());
						commandDone = true;
					} else {
						if (rrdVO.getStartTime() > 0) {
							jRobinSupport.rrdUpdate(rrdVO.getRRD(), rrdVO.getStartTime(),
									rrdVO.getDataSource(), rrdVO.getRRDValue());
							commandDone = true;
						} else {
							jRobinSupport.rrdUpdate(rrdVO.getRRD(), rrdVO.getDataSource(),
									rrdVO.getRRDValue());
							commandDone = true;
						}
					}
				}
				if (itemKey.equals("RRDGRAPH")) {
					jrobinSet = true;
					if (!config.jRobinParser.isJRobinActive()) {
						commandDone = true;
					}
					RRDValueObject rrdVO;
					rrdVO = (RRDValueObject) item.getRrdValueObject();
					if (rrdVO != null) {
						jRobinSupport.rrdGraph.getGraph(rrdVO);
					}
					commandDone = true;
				}
				if (item.isAdminCommand()) {
					adminModel.doCommand(item);
					commandDone = true;
				}
				boolean clientKeySet;
				if (itemKey.equals("CLIENT_SEND")) {
					clientKeySet = true;
				} else {
					clientKeySet = false;
				}
				if (!commandDone
						&& (clientKeySet || itemKey.equals("RawXML_Send"))) {
					doSendCommand(item);
					commandDone = true;
				}
				if (!commandDone && !item.isCommsCommand()
						&& (item.getCommandCode().startsWith("AV."))) {
					commandDone = true;
					deviceModelList = deviceModels.iterator();
					while (deviceModelList.hasNext()) {
						DeviceModel deviceModel = (DeviceModel) deviceModelList
								.next();
						if (deviceModel.doIControlIR())
							successfulCommand = doDeviceCommand(deviceModel,
									item);
					}
				}
				if (!commandDone && !item.isCommsCommand()
						&& (item.getCommandCode().startsWith("MACRO."))) {
					commandDone = true;
					successfulCommand = doDeviceCommand(macroModel, item);
				}
				if (!commandDone && item.isClient()) {
					if (item.getTargetDeviceModel() >= 0) {
						DeviceModel clientModel = (DeviceModel) clientModels
								.get(item.getTargetDeviceModel());
						successfulCommand = doClientCommand(clientModel, item);
					} else {
						Iterator clientModelList = clientModels.iterator();
						while (clientModelList.hasNext()) {
							DeviceModel clientModel = (DeviceModel) clientModelList
									.next();
							try {
								if (((ClientCommand) item).isBroadcast())
									((ClientModel) clientModel)
											.broadcastCommand(item);
							} catch (ClassCastException ex) {
								logger.log(Level.WARNING,
										"The flash controller received a message on an incorrect type "
												+ ex.getMessage());
							}
							successfulCommand = doClientCommand(clientModel,
									item);
						}
					}
				}
				if (!clientKeySet && !jrobinSet && !commandDone
						&& item.getTargetDeviceModel() >= 0) {
					commandDone = true;
					DeviceModel deviceModel = (DeviceModel) deviceModels
							.get(item.getTargetDeviceModel());
					successfulCommand = doDeviceCommand(deviceModel, item);
				}
				if (!clientKeySet && !jrobinSet && !commandDone
						&& !item.isCommsCommand()) {
					// comms commands always go to their specific target device
					// flash commands only get sent to client handlers
					commandDone = true;
					deviceModelList = deviceModels.iterator();
					while (deviceModelList.hasNext()) {
						DeviceModel deviceModel = (DeviceModel) deviceModelList
								.next();
						successfulCommand = doDeviceCommand(deviceModel, item);
					}
				}
				if (!item.isCommsCommand()) {
					doScriptCommand(item);
				}

			}
			try {
				int i = 0;
				do {
						Thread.sleep(100);
						i ++;
				} while (!commandQueue.isEmpty() && i < 5);
			} catch (InterruptedException ex) {
			}
			;

			Thread.yield();
		}
	}


	/**
	 * This method is called when a new client connects
	 */
	public void doClientStartup(long targetFlashDeviceID, long serverID) {
		Iterator models = deviceModels.iterator();
		while (models.hasNext()) {
			DeviceModel nextModel = (DeviceModel) models.next();
			nextModel.doClientStartup(targetFlashDeviceID, serverID);
		}

		Iterator cl_models = clientModels.iterator();
		while (cl_models.hasNext()) {
			DeviceModel nextModel = (DeviceModel) cl_models.next();
			nextModel.doClientStartup(targetFlashDeviceID, serverID);
		}

		scriptModel.doClientStartup(targetFlashDeviceID, serverID);
	}



	public boolean doScriptCommand(CommandInterface item) {
		boolean successfulCommand = false;
		String itemKey;
		if (item.isClient()) {
			itemKey = item.getKey();
		} else {
			itemKey = item.getDisplayName();
		}
		if (itemKey != null && !itemKey.equals("")) {
			if (scriptModel.doIControl(itemKey, item.isUserControllerCommand())) {
				try {
					scriptModel.doCommand(item);
					successfulCommand = true;
				} catch (CommsFail commsFail) {
				}
			}
		}
		return successfulCommand;
	}

	public boolean doClientCommand(DeviceModel clientModel,
			CommandInterface item) {
		boolean successfulCommand = false;
		String itemKey = item.getKey();
		if (itemKey != null && !itemKey.equals("")) {
			if (clientModel.doIControl(itemKey, item.isUserControllerCommand())) {
				while (!successfulCommand) {
					try {
						clientModel.doCommand(item);
						successfulCommand = true;
					} catch (CommsFail commsFail) {
					}
				}
			}
		}
		return successfulCommand;
	}

	public boolean doDeviceCommand(DeviceModel deviceModel,
			CommandInterface item) {
		boolean successfulCommand = false;
		String itemKey = item.getKey();
		if (item.getCommandCode().startsWith("AV.")) {
			int lastDot = item.getCommandCode().lastIndexOf(".");
			if (lastDot == 2) {
				itemKey = item.getCommandCode();
			} else {
				itemKey = item.getCommandCode().substring(0, lastDot);
			}
			item.setKey(itemKey);
		}
		if (item.getCommandCode().startsWith("MACRO.")) {
			itemKey = item.getCommandCode();
			String realCommand = item.getCommandCode().substring(6);
			item.setCommand(realCommand);
			item.setKey("MACRO");
			itemKey = "MACRO";
		}
		if (itemKey != null && !itemKey.equals("")) {
			if (!deviceModel.isConnected()) {
				return false;
			}
			if (deviceModel.doIControl(itemKey, item.isUserControllerCommand())) {
				try {
					while (!successfulCommand) {
						try {
							deviceModel.doCommand(item);
							successfulCommand = true;
						} catch (CommsFail commsFail) {
							logger.log(Level.WARNING,
									"Caught a communication error to device "
											+ deviceModel.getName() + " : "
											+ commsFail.getMessage());
							deviceModel.setConnected(false);
							if (deviceModel.isAutoReconnect()) {
								connectDevice(deviceModel, this.deviceModels);
							}
						} catch (NullPointerException ex) {
							logger.log(Level.WARNING,
									"Caught a null pointer exception in device "
											+ deviceModel.getName() + " ");
							ex.printStackTrace();
							deviceModel.setConnected(false);
							connectDevice(deviceModel, this.deviceModels);
							if (deviceModel.isAutoReconnect()) {
								connectDevice(deviceModel, this.deviceModels);
							}
						}

					}
				} catch (ArrayIndexOutOfBoundsException ex) {
					logger.log(Level.WARNING,
							"Caught an array index out of bounds exception in device "
									+ deviceModel.getName() + " ");
					ex.printStackTrace();
				} catch (Exception ex) {
					logger.log(Level.WARNING,
							"Caught an unknown error in device "
									+ deviceModel.getName() + " : "
									+ ex.getMessage());
					ex.printStackTrace();
				}
			}
		}
		return successfulCommand;

	}

	public void connectDevice(DeviceModel deviceModel, List deviceModelList) {

		if (deviceModel.isTryingToConnect()) {
			return;
		} else {
			if (deviceModel.isAutoReconnect()) {
				ConnectDevice connector = new ConnectDevice(deviceModel,
						adminModel, commandQueue, irCodeDB, bootstrap);
				connector.start();
			}
		}

	}

	public void displayStackTrace(Exception ex) {
		StackTraceElement stack[] = ex.getStackTrace();
		for (int i = 0; i < stack.length; i++) {
			String filename = stack[i].getFileName();
			if (filename == null) {
				filename = "";
			}
			String className = stack[i].getClassName();
			String methodName = stack[i].getMethodName();
			boolean isNativeMethod = stack[i].isNativeMethod();
			int line = stack[i].getLineNumber();
			logger.logp(Level.FINER, className, methodName, String
					.valueOf(line), ex);
		}
	}

	public void doSendCommand(CommandInterface command) {
		String commandCode = command.getCommandCode();
		Iterator clientModelList = clientModels.iterator();
		while (clientModelList.hasNext()) {
			DeviceModel theClientModel = (DeviceModel) clientModelList.next();
			try {
				theClientModel.doCommand(command);
			} catch (CommsFail fail) {
				logger.log(Level.SEVERE,
						"Communication with the clients failed : "
								+ fail.getMessage());
			}
		}
	}

	public void doCommand(CommandInterface command) {
		String commandCode = command.getCommandCode();
		if (commandCode.equals("ShutDown")) {
			doShutdown();
		}
		if (commandCode.equals("Attatch")) {
			try {
				int deviceNumber = Integer.parseInt(command.getExtraInfo());
				DeviceModel model = (DeviceModel) deviceModels
						.get(deviceNumber);
				try {
					model.close();
				} catch (ConnectionFail ex) {
				}
				;
				this.connectDevice(model, deviceModels);
			} catch (NumberFormatException ex) {
				logger.log(Level.WARNING,
						"An incorrect call was made to restart model number "
								+ command.getExtraInfo());
			}

		}
		if (commandCode.equals("ClientAttach")) {
			try {
				long flashID = Long.parseLong(command.getExtraInfo());
				long serverID = Long.parseLong(command.getExtra2Info());
				this.doClientStartup(flashID, serverID);

			} catch (NumberFormatException ex) {
				logger.log(Level.WARNING,
						"An incorrect call was made on client connection");
			}

		}
		if (commandCode.equals("Login")) {
			login((User) ((CommsCommand) command).getUser());
		}
		if (commandCode.equals("ReadConfig")) {
			if (doReadConfig("config", (String) command.getExtraInfo())) {
				doSystemStartup(deviceModels);
			}

		}
		if (commandCode.equals("LoadScripts")) {
			try {
				this.scriptModel.loadScripts();
				this.scriptModel.sendListToClient();
			} catch (Exception e) {
				logger.log(Level.WARNING, "Scripts could not be loaded");
			}
		}
		if (commandCode.equals("LoadMacros")) {
			try {
				this.macroHandler.readMacroFile(false);
				this.macroModel.sendListToClient();
			} catch (Exception e) {
				logger.log(Level.WARNING, "Macros could not be loaded");
			}
		}
		if (commandCode.equals("LoadIRDB")) {
			this.irCodeDB.readIRCodesFile("datafiles" + File.separator
					+ "ircodes.xml");
			Command irCommand = new Command("ADMIN", "List_Devices",
					this.currentUser);
			commandQueue.add(irCommand);
		}

		if (commandCode.equals("Keypress")) {
			Iterator deviceModelList = deviceModels.iterator();
			while (deviceModelList.hasNext()) {
				DeviceModel deviceModel = (DeviceModel) deviceModelList.next();
				if (deviceModel.getName().equals("COMFORT")) {
					try {
						((au.com.BI.Comfort.Model) deviceModel)
								.sendKeypress(command);
					} catch (CommsFail e) {
						logger.log(Level.WARNING,
								"Keypress could not be sent to comfort");
					}
				}
			}
		}
	}

	public void doSystemStartup(List deviceModels) {
		scriptModel.setIrCodeDB(irCodeDB);
		flashHandler.setIrCodeDB(irCodeDB);
		adminModel.setIrCodeDB(irCodeDB);
		if (!macroHandler.readCalendarFile() && logger != null) {
			logger.log(Level.SEVERE, "Could not read calendar file");
		}

	}

	public boolean doReadConfig(String dir, String configPattern) {

		Iterator deviceModelClearList = deviceModels.iterator();
		// clear all model information
		while (deviceModelClearList.hasNext()) {
			DeviceModel model = (DeviceModel) deviceModelClearList.next();
			if (!model.removeModelOnConfigReload()) {
				try {
					model.close();
				} catch (ConnectionFail e1) {

				}
				model.clearItems();
			}
		}
		config.prepareToReadConfigs(deviceModels, controls);

		File theDir = new File(dir);
		AcceptConfig acceptConfig = new AcceptConfig();
		acceptConfig.setPattern(configPattern);
		File configFiles[] = theDir.listFiles(acceptConfig);

		configLoaded = false;
		for (int i = 0; i < configFiles.length; i++) {
			try {
				config.readConfig(deviceModels, clientModels, cache,
						jRobinSupport.variableCache, commandQueue, irCodeDB, configFiles[i],
						controls);
				configLoaded = true;
			} catch (ConfigError configError) {
				logger.log(Level.SEVERE, "Error in configuration file "
						+ configFiles[i].toString() + " "
						+ configError.getMessage());
			}
		}

		if (configLoaded) {
			logger.log(Level.FINER, "Read configuration file correctly.");
		}

		this.setBindToAddress(bootstrap.getServerString());
		this.setClientPort(bootstrap.getPort());

		Iterator deviceModelList = deviceModels.iterator();
		int deviceCounter = 0;
		while (deviceModelList.hasNext()) {
			DeviceModel deviceModel = (DeviceModel) deviceModelList.next();
			deviceModel.setInstanceID(deviceCounter); // update it in case the
														// position has changed.
			deviceCounter++;
			this.connectDevice(deviceModel, deviceModels);
		}
		try {
			scriptModel.finishedReadingConfig();
		} catch (SetupException fail) {
			logger.log(Level.SEVERE, "Error configuring script model. "
					+ fail.getMessage());
		}

		return true;
	}

	public CommandQueue getCommandQueue() {
		return commandQueue;
	}

	public void doShutdown() {
		Iterator deviceModelList = deviceModels.iterator();
		while (deviceModelList.hasNext()) {
			DeviceModel deviceModel = (DeviceModel) deviceModelList.next();
			try {
				deviceModel.closeComms();
			} catch (ConnectionFail e) {
			}
		}

		logger.log(Level.SEVERE, "eLife server exiting");
		System.exit(1);
	}

	/**
	 * Send login command to all attatched models
	 * 
	 * @param user
	 * @return
	 */
	public int login(User user) {
		int result = DeviceModel.SUCCESS;
		Iterator deviceModelList = deviceModels.iterator();
		while (deviceModelList.hasNext()) {
			DeviceModel deviceModel = (DeviceModel) deviceModelList.next();
			try {
				result = deviceModel.login(user);
			} catch (CommsFail fail) {
				logger.log(Level.SEVERE, "Could not log in "
						+ fail.getMessage());
			}
		}
		return result;
	}

	/**
	 * General interface to making things happen through devices.
	 * 
	 * @param target
	 *            the target string from the configuration file
	 * @param instruction
	 *            the action to occur from the interface
	 * @return
	 */
	public int doAction(Command command) {
		if (currentUser.canUserDoCommand(command))
			return DeviceModel.SUCCESS;
		else
			return DeviceModel.SECURITY_FAIL;
	}

	/**
	 * @return Returns the bindToAddress.
	 */
	public final String getBindToAddress() {
		return bindToAddress;
	}

	/**
	 * @param bindToAddress
	 *            The bindToAddress to set.
	 */
	public final void setBindToAddress(String bindToAddress) {
		this.bindToAddress = bindToAddress;
	}

	/**
	 * @return Returns the clientPort.
	 */
	public final int getClientPort() {
		return clientPort;
	}

	/**
	 * @param clientPort
	 *            The clientPort to set.
	 */
	public final void setClientPort(int clientPort) {
		this.clientPort = clientPort;
	}

	/**
	 * @return Returns the bootstrap.
	 */
	public Bootstrap getBootstrap() {
		return bootstrap;
	}

	/**
	 * @param bootstrap
	 *            The bootstrap to set.
	 */
	public void setBootstrap(Bootstrap bootstrap) {
		this.bootstrap = bootstrap;
	}

	/**
	 * @return Returns the overallLogger.
	 */
	public LogHandler getLogHandler() {
		return logHandler;
	}

	/**
	 * @param overallLogger
	 *            The overallLogger to set.
	 */
	public void setLogHandler(LogHandler logHandler) {
		this.logHandler = logHandler;
	}

	public VersionManager getVersionManager() {
		return versionManager;
	}

	public void setVersionManager(VersionManager versionManager) {
		this.versionManager = versionManager;
	}

}
