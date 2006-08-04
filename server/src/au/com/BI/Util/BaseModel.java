/*
 * Created on Jan 25, 2004
 *
 */
package au.com.BI.Util;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
 */

import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Config.ParameterException;
import au.com.BI.Config.RawItemDetails;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.GC100.IRCodeDB;
import au.com.BI.Home.VersionManager;
import au.com.BI.User.User;
import java.util.*;
import java.util.logging.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import au.com.BI.Macro.MacroHandler;
import au.com.BI.Config.Bootstrap;
import au.com.BI.AlarmLogging.*;
import au.com.BI.Messaging.*;
import au.com.BI.Config.ParameterBlock;
import au.com.BI.CustomConnect.CustomConnect;
import au.com.BI.Device.DeviceType;

public class BaseModel
  implements DeviceModel {
        protected CommDevice comms = null;
        protected ModelTypes modelType = ModelTypes.Java;
    	protected String appendToSentStrings = "";
        protected boolean logged_in = false;

        protected boolean connected = false;
        private boolean autoReconnect = true;

        protected HashMap <String,HashMap<String,String>>rawDefs;
        protected HashMap <String,HashMap<String,String>> parameters;
        protected HashMap <String,String>topMap; // a convienience reference to the top level map

        protected Logger logger = null;

        protected String name = "Unknown";
        protected CommandQueue commandQueue = null;
        protected ConfigHelper configHelper;
        protected au.com.BI.Command.Cache cache;
        protected HashMap<String,Object> variableCache;
        protected boolean isStartupQuery = false;
        protected IRCodeDB irCodeDB;

        protected int InstanceID;
        protected String description;
        protected int transmitOnBytes = 0;
        protected MacroHandler macroHandler;
        protected Collection modelList;
        protected Bootstrap bootstrap;
        protected int powerRating;
		protected int etxArray[] = null;
		protected int penultimateArray[] = null;
		protected int stxArray[] = null;
		protected boolean tryingToConnect = false;
		protected long serverID = 0;
		protected AddressBook addressBook = null;
		protected EventCalendar eventCalendar;
		protected AlarmLogging alarmLogging = null;
		protected int interCommandInterval = 0;
        protected boolean deviceKeysDecimal = false;
        protected boolean configKeysInDecimal = false;
		protected int padding = 1; // Number of digits to pad the key too in the device.
		public DeviceType allDevices = null;
		protected VersionManager versionManager = null;
		protected String version = "0";
		protected Pattern customScanLookupString = null;
		protected Pattern customScanCommandString = null;
		
		public User currentUser = null;
		
        public BaseModel() {
	        	Package thisPackage = this.getClass().getPackage();
	        	if (thisPackage != null) {
	                logger = Logger.getLogger(thisPackage.getName());
	        	} else {
	        		String name = this.getName();
	        	   	if (name != null) {
		                logger = Logger.getLogger(name);
	        	   	} else {
	        	   		logger = Logger.getLogger("Unknown model");
	        	   	}
	        	}
                configHelper = new ConfigHelper(this);
                parameters = new HashMap<String, HashMap<String,String>>(DeviceModel.NUMBER_DEVICE_GROUPS);
                topMap = new HashMap<String,String>(DeviceModel.NUMBER_PARAMETERS);
                parameters.put(DeviceModel.MAIN_DEVICE_GROUP, topMap);
                rawDefs = new HashMap<String,HashMap<String,String>>(DeviceModel.NUMBER_CATALOGUES);
           		customScanLookupString = Pattern.compile("%LOOKUP (\\w+) (\\w+)");
           		customScanCommandString = Pattern.compile("%COMMAND\\.(\\w+)%");
        }

        public void setTransmitMessageOnBytes(int numberBytes) {
                transmitOnBytes = numberBytes;
        }

		public void setETXArray (int etxArray[]){
			this.etxArray = etxArray;
		}

		public void setSTXArray (int stxArray[]){
			this.stxArray = stxArray;
		}

        public void setPowerRating(int rating) {
                this.powerRating = rating;
        }

        public int getPowerRating() {
                return this.powerRating;
        }

        public void finishedReadingConfig() throws SetupException {
        	setupParameterBlocks();
        }

    	/** 
       	 * A hook which occurs after the configuration parser has read the to level parameters 
        *	but has not yet begun the individual device entries. 
        */
    	public void finishedReadingParameters (){
    		if (getParameterValue("DECIMAL_KEYS", DeviceModel.MAIN_DEVICE_GROUP).equals("Y")){
    			this.setConfigKeysInDecimal(true);
    		} else {
      			this.setConfigKeysInDecimal(false);  			
    		}
  
      		if (!getParameterValue("APPEND_TO_SENT_STRINGS", DeviceModel.MAIN_DEVICE_GROUP).equals("")){
    			this.setAppendToSentStrings(getParameterValue("APPEND_TO_SENT_STRINGS", DeviceModel.MAIN_DEVICE_GROUP));
    		}
  }
    	
    	public void setupParameterBlocks() throws SetupException {
    		for (ParameterBlock block: configHelper.getParameterBlocks()){
    			
	    		String paramDef = (String)this.getParameterValue(block.getCatalogName(),block.getGroup());
	    		if (paramDef == null || paramDef.equals ("")) {
	    			throw new SetupException ("The " + block.getVerboseName() + " input catalogue name was not specified in the device Parameter block");
	    		}
	    	
	    		Map inputs = this.getCatalogueDef(paramDef);
	    		if (inputs == null) {
	    			throw new SetupException ("The " + block.getVerboseName() + " input catgalogue was not specifed in the device Parameter block");
	    		}
	   		}
    	}
    	
        public void doStartup()  throws au.com.BI.Comms.CommsFail {};

        
        /**
         * @deprecated
         */
        public final void doStartup(List commandList)  throws au.com.BI.Comms.CommsFail {};

        /** 
         * Called when a new client connects to the server
         * @param targetFlashDeviceID
         * @param serverID
         */
    		public void doClientStartup(long targetFlashDeviceID, long serverID){};

    		
        /**
         * Name is used by the config reader to tie a particular device to configuration
         * @param name The identifying string for this device handler
         */
        public void setName(String name) {
                this.name = name;
        }

        public void clearItems() {
                configHelper.clearItems();
                parameters.clear();
                topMap = new HashMap<String,String>(DeviceModel.NUMBER_PARAMETERS);
                
                parameters.put(DeviceModel.MAIN_DEVICE_GROUP, topMap);
        }

        public String getName() {
                return name;
        }

        public void setCache(au.com.BI.Command.Cache cache) {
                this.cache = cache;
        }

        public void setVariableCache(HashMap <String,Object>variableCache) {
                this.variableCache = variableCache;
        }

        /**
         * @return Returns the value stored in variable.
         * @param key The key to get the value for.
         */
        public String getVariable(String key) {
                synchronized (variableCache) {
                        if (variableCache.containsKey(key) == true) {
                                return (String) variableCache.get(key);
                        }
                }
                return "None";
        }

        
  


    	public void sendWrapperItems (ReturnWrapper returnWrapper ){
    		if ( !returnWrapper.isError()) {
    			if (returnWrapper.isMessageIsBytes()){
    			    for(byte[] avOutputString : returnWrapper.getCommOutputBytes()) {			
    			    		this.sendToSerial(avOutputString);
    				}
    			} else {
    			    for(String avOutputString : returnWrapper.getCommOutputStrings()) {			
    			    	this.sendToSerial(avOutputString + this.getAppendToSentStrings());
    					if (logger.isLoggable(Level.FINE)){
    						logger.log(Level.FINE,"Sending a command to the device controlled by " + this.getName() + " " + avOutputString);
    					}
    				}					
    			}
    		    
    			for (CommandInterface eachCommand: returnWrapper.getOutputFlash()){
    				this.sendToFlash(eachCommand, cache);
    			}

    		} else {
    			if (returnWrapper != null){
    				logger.log (Level.WARNING,"There was error processing the message in the " + this.getName() + " support module." + returnWrapper.getErrorDescription());
    			}
    		}

    	}
    	

        /**
         * @return Returns the value stored in variable.
         * @param key The key to get the value for.
         */
        public Long getLongVariable(String key) {
                synchronized (variableCache) {
                        if (variableCache.containsKey(key) == true) {
                                return (Long) variableCache.get(key);
                        }
                }
                return null;
        }

        /**
         * @return Returns the value stored in variable.
         * @param key The key to get the value for.
         */
        public Double getDoubleVariable(String key) {
                synchronized (variableCache) {
                        if (variableCache.containsKey(key) == true) {
                                return (Double) variableCache.get(key);
                        }
                }
                return null;
        }


        /**
         * Set the varaible Key,Value
         * @param key The key to store the value for.
         * @param @value The value to store.
         */
        public void setVariable(String key, String value) {
                synchronized (variableCache) {
                        if (variableCache.containsKey(key) == true) {
                                variableCache.remove(key);
                                variableCache.put(key, value);
                                return;
                        }
                        variableCache.put(key, value);
                }
                return;
        }

        /**
         * Set the varaible Key,Value where value is a double, but stored as a string.
         * @param key The key to store the value for.
         * @param @value The value to store as a double.
         */
        public void setVariable(String key, double value) {
                synchronized (variableCache) {
                        if (variableCache.containsKey(key) == true) {
                                variableCache.remove(key);
                                variableCache.put(key, new Double(value));
                                return;
                        }
                        variableCache.put(key, new Double(value));
                }
                return;
        }

        /**
      * Set the varaible Key,Value where value is a long, but stored as a string.
      * @param key The key to store the value for.
      * @param @value The value to store as a long.
      */
     public void setVariable(String key, long value) {
             synchronized (variableCache) {
                     if (variableCache.containsKey(key) == true) {
                             variableCache.remove(key);
                             variableCache.put(key, new Long(value));
                             return;
                     }
                     variableCache.put(key, new Long(value));
             }
             return;
     }


        /**
         * Increment the variable Value
         * @param key The key to store the value for.
         */
        public void incrementVariable(String key) {
                Double value;
                double numValue;
                Object hold;
                Long longValue;
                long numLong;

                synchronized (variableCache) {
                        if (variableCache.containsKey(key) == true) {
                                hold = variableCache.get(key);
                                if (hold.getClass().getName() == "java.lang.Double") {
                                        value = (Double) variableCache.get(key);
                                        numValue = value.doubleValue();
                                        numValue = numValue + 1d;
                                        value = new Double(numValue);
                                        variableCache.remove(key);
                                        variableCache.put(key, value);
                                        return;
                                }
                                else if (hold.getClass().getName() == "java.lang.Long") {
                                        longValue = (Long) variableCache.get(key);
                                        numLong = longValue.longValue();
                                        numLong = numLong + 1;
                                        longValue = new Long(numLong);
                                        variableCache.remove(key);
                                        variableCache.put(key, longValue);
                                        return;
                                }
                                return;

                        }

                        variableCache.put(key, new Double(1d));
                        return;
                }
        }


        
        
        /**
         * Decrement the variable Value
         * @param key The key to store the value for.
         */
        public void decrementVariable(String key) {
                Double value;
                double numValue;
                Object hold;
                Long longValue;
                long numLong;

                synchronized (variableCache) {
                        if (variableCache.containsKey(key) == true) {
                                hold = variableCache.get(key);
                                if (hold.getClass().getName() == "java.lang.Double") {
                                        value = (Double) variableCache.get(key);
                                        numValue = value.doubleValue();
                                        numValue = numValue - 1d;
                                        value = new Double(numValue);
                                        variableCache.remove(key);
                                        variableCache.put(key, value);
                                        return;
                                }
                                else if (hold.getClass().getName() == "java.lang.Long") {
                                        longValue = (Long) variableCache.get(key);
                                        numLong = longValue.longValue();
                                        numLong = numLong - 1;
                                        longValue = new Long(numLong);
                                        variableCache.remove(key);
                                        variableCache.put(key, longValue);
                                        return;
                                }
                                return;
                        }
                        variableCache.put(key, new Double( -1d));
                        return;
                }
        }
        public boolean touchPanel() {
                return false;
        }

        public void addControlledItem(String name, DeviceType details, MessageDirection controlType) {
                String theKey = name;

                configHelper.addControlledItem(theKey, details, controlType);
        }

       public boolean doIControl(String keyName, boolean isClientCommand) {

                configHelper.wholeKeyChecked(keyName);

                if (configHelper.checkForOutputItem(keyName)) {
                        logger.log(Level.FINER, "Flash sent command : " + keyName);
                        return true;
                }
                if (isClientCommand)
                	return false; // only are about output for client commands
                else {
                	configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
                    logger.log(Level.FINER, "Controls : " + keyName);
                	return true; // anything come through comms we want to look at
                }

        }

        public void doCommand(CommandInterface command) throws CommsFail {

                if (configHelper.getLastCommandType() == MessageDirection.FROM_FLASH) {
                        doOutputItem(command);
                }
                else {
                        if (configHelper.getLastCommandType() == MessageDirection.INPUT) {
                                doInputItem(command);
                        }
                        else {
                                doControlledItem(command);
                        }
                }
        }


        public void doOutputItem(CommandInterface command) throws CommsFail {
        }

        public void doControlledItem(CommandInterface command) throws CommsFail {
        }

        public void doInputItem(CommandInterface command) throws CommsFail {
        }

        public int login(User user) throws CommsFail {
                logged_in = true;
                return DeviceModel.SUCCESS;
        }

        public int logout(User user) throws CommsFail {
                return DeviceModel.SUCCESS;
        }

        public boolean isLoggedIn() {
                return logged_in;
        }

        public void sendToSerial(String outputRawCommand) throws CommsFail {
                if (this.connected == true) {
                        synchronized (comms) {
                                comms.sendString(outputRawCommand);
                        }
                }
        }

        public void sendToSerial(byte[] outputRawCommand) throws CommsFail {
                if (this.connected == true) {
                        synchronized (comms) {
                                comms.sendString(outputRawCommand);
                        }
                }
        }
        

    	public void sendToSerial (byte avOutputString[],String deviceKey, String outputKey, int outputCommandType,boolean keyForHandshake) throws CommsFail{
    		CommsCommand avCommsCommand = new CommsCommand();
    		avCommsCommand.setKey (deviceKey);
    		avCommsCommand.setCommandBytes(avOutputString);
    		avCommsCommand.setActionType(outputCommandType);
    		avCommsCommand.setExtraInfo (outputKey);
    		avCommsCommand.setKeepForHandshake(keyForHandshake);
    		synchronized (comms){
    			try { 
    				comms.addCommandToQueue (avCommsCommand);
    			} catch (CommsFail e1) {
    				throw new CommsFail ("Communication failed communitating with SignAV " + e1.getMessage());
    			} 
    		}
    	}
    	

    	public void sendToSerial (String avOutputString,String deviceKey, String outputKey, int outputCommandType,boolean keyForHandshake) throws CommsFail{
    		CommsCommand avCommsCommand = new CommsCommand();
    		avCommsCommand.setKey (deviceKey);
    		avCommsCommand.setCommand(avOutputString);
    		avCommsCommand.setActionType(outputCommandType);
    		avCommsCommand.setExtraInfo (outputKey);
    		avCommsCommand.setKeepForHandshake(keyForHandshake);
    		synchronized (comms){
    			try { 
    				comms.addCommandToQueue (avCommsCommand);
    			} catch (CommsFail e1) {
    				throw new CommsFail ("Communication failed communitating with SignAV " + e1.getMessage());
    			} 
    		}
    	}

        public boolean reEstablishConnection() {
                return true;
        }

        /**
         * Attatch to a port
         * @param port
         * @param commandList The list object to place ReceiveEvent messages
         * @param handlerThread The thread to be notified when messages are added to the queue
         * @throws ConnectionFail
         * @see au.com.BI.Comms.CommsCommand;
         */
        public void attatchComms() throws ConnectionFail {
                SerialParameters parameters = null;
                if ( ( (String)this.getParameterValue("Connection_Type", DeviceModel.MAIN_DEVICE_GROUP)).equals("SERIAL")) {

                        if (comms != null) {
                                synchronized (comms) {
                                        comms.close();
                                }
                        }
                        else
                                comms = new Serial();

                        if (this.transmitOnBytes > 0) {
                                comms.setTransmitMessageOnBytes(transmitOnBytes);
                        }
						if (etxArray != null) comms.setETXArray(etxArray);
						if (penultimateArray != null) comms.setPenultimateArray(penultimateArray);
						if (stxArray != null) comms.setSTXArray(stxArray);
						if (interCommandInterval != 0 ) comms.setInterCommandInterval(interCommandInterval);
                        parameters = new SerialParameters();
                        parameters.buildFromDevice(this);
                        synchronized (comms) {
                                ( (Serial) comms).connect( (String)this.getParameterValue("Device_Port", DeviceModel.MAIN_DEVICE_GROUP),
                                  parameters, commandQueue, this.getInstanceID(),this.getName());
                                comms.clearCommandQueue();
                        }
                }
                else {

                        if (comms != null) {
                                synchronized (comms) {
                                        comms.close();
                                        comms = null;
                                }
                        }

                        comms = new IP();
                        if (this.transmitOnBytes > 0) {
                                comms.setTransmitMessageOnBytes(transmitOnBytes);
                        }
						if (etxArray != null) comms.setETXArray(etxArray);
						if (stxArray != null) comms.setSTXArray(stxArray);
						if (interCommandInterval != 0 ) comms.setInterCommandInterval(interCommandInterval);
						if (penultimateArray != null) comms.setPenultimateArray(penultimateArray);

                        synchronized (comms) {
                                ( (IP) comms).connect( (String)this.getParameterValue("IP_Address", DeviceModel.MAIN_DEVICE_GROUP),
                                  (String)this.getParameterValue("Device_Port", DeviceModel.MAIN_DEVICE_GROUP),
                                  commandQueue, this.getInstanceID(), doIPHeartbeat(),getHeartbeatString(),this.getName());
                                comms.clearCommandQueue();
                        }
                }
                //connected = true;
        }

        public void setCommandQueue(CommandQueue commandQueue) {
                this.commandQueue = commandQueue;
        }
        
        public CommandQueue getCommandQueue() {
            return commandQueue;
        }

        /**
         Closes the connection	 */
        public void closeComms() throws ConnectionFail {
                if (comms != null) {
                        synchronized (comms) {
                                comms.close();
                        }
                }
        }

        /**
         Finishes operations, closing down any other threads it is responsible for
         */
        public void close() throws ConnectionFail {
                closeComms();
        }

        /**
         * @return Returns the rawDefs.
         */
        public final HashMap<String,String> getCatalogueDef(String name) {
                return rawDefs.get(name);
        }

        /**
         * @param rawDefs The rawDefs to set.
         */
        public final void setCatalogueDefs(String name, HashMap<String,String> rawDefs) {
                this.rawDefs.put(name, rawDefs);
        }

        public String getParameterValue(String name, String groupName) {
                HashMap <String,String>theMap;
                if (groupName == null || groupName.equals("")) groupName = DeviceModel.MAIN_DEVICE_GROUP;

                if (!groupName.equals(DeviceModel.MAIN_DEVICE_GROUP) && parameters.containsKey(groupName)) {
                        theMap = parameters.get(groupName);
                        String item = theMap.get(name);
                        if (item == null)
                                return "";
                        else
                                return item;
                }
                else {
                        String item = topMap.get(name);
                        if (item == null)
                                return "";
                        else
                                return item;
                }
        }

        public void setParameter(String name, String value, String groupName) {
                HashMap <String,String>theMap;
                if (groupName.equals(DeviceModel.MAIN_DEVICE_GROUP))
                        theMap = topMap;
                else {
                        if (parameters.containsKey(groupName))
                                theMap = parameters.get(groupName);
                        else
                                theMap = new HashMap<String,String>(DeviceModel.NUMBER_PARAMETERS);
                }

                theMap.put(name, value);
                parameters.put(groupName, theMap);
        }
    	    	
 
       	public String findKeyForParameterValue(String srcCode, String catalogName,DeviceType device) throws NumberFormatException, ParameterException {
       		return findKeyForParameterValue (Integer.parseInt(srcCode) ,catalogName,device);
       	}
       	
        public String findKeyForParameterValue(int srcVal, String catalogName,DeviceType device) throws ParameterException {
    		String groupName = device.getGroupName();
    		String paramMapName = this.getParameterValue (catalogName,groupName);
    		Map <String,String>inputParameters = this.getCatalogueDef(paramMapName);
    		
    		String returnVal = "";
    		
    		for (String eachItem: inputParameters.keySet()){
    			int programVal = Integer.parseInt(inputParameters.get(eachItem));
    			if (programVal == srcVal) {
    				returnVal = eachItem;
    			}
    		}
    		if (returnVal.equals("")) throw new ParameterException ("An input device has been selected which has not been configured, please contact your integrator");
    		return returnVal;
    	}
    	
        /**
         * @return Returns the instanceID.
         */
        public int getInstanceID() {
                return InstanceID;
        }

        /**
         * @param instanceID The instanceID to set.
         */
        public void setInstanceID(int instanceID) {
                InstanceID = instanceID;
        }

        public void addStartupQueryItem(String name, Object details, MessageDirection controlType) {};

        /**
         * @return Returns the displayName.
         */
        public String getDescription() {
                return description;
        }

        /**
         * @param displayName The displayName to set.
         */
        public void setDescription(String description) {
                this.description = description;
        }

        public boolean doIPHeartbeat() {
                return true;
        }

        public boolean doIControlIR() {
                return false;
        }

        /**
         * @return Returns the irCodeDB.
         */
        public IRCodeDB getIrCodeDB() {
                return irCodeDB;
        }

        /**
         * @param irCodeDB The irCodeDB to set.
         */
        public void setIrCodeDB(IRCodeDB irCodeDB) {
                this.irCodeDB = irCodeDB;
        }

        /**
         * @return Returns the macroHandler.
         */
        public MacroHandler getMacroHandler() {
                return macroHandler;
        }

        /**
         * @param macroHandler The macroHandler to set.
         */
        public void setMacroHandler(MacroHandler macroHandler) {
                this.macroHandler = macroHandler;
        }

        public boolean removeModelOnConfigReload() {
                return true;
        }

        /**
         * @return Returns the modelList.
         */
        public Collection getModelList() {
                return modelList;
        }

        /**
         * @param modelList The modelList to set.
         */
        public void setModelList(Collection modelList) {
                this.modelList = modelList;
        }

        /**
         * @return Returns the configHelper.
         */
        public ConfigHelper getConfigHelper() {
                return configHelper;
        }

        /**
         * @param configHelper The configHelper to set.
         */
        public void setConfigHelper(ConfigHelper configHelper) {
                this.configHelper = configHelper;
        }

        /**
         * @return Returns the bootstrap.
         */
        public Bootstrap getBootstrap() {
                return bootstrap;
        }

        /**
         * @param bootstrap The bootstrap to set.
         */
        public void setBootstrap(Bootstrap bootstrap) {
                this.bootstrap = bootstrap;
        }

		public boolean isConnected() {
			return connected;
		}

		public void setConnected(boolean connected) {
			this.connected = connected;
		}

		public String getHeartbeatString () {
			return "\n";
		}

		public boolean isTryingToConnect() {
			return tryingToConnect;
		}

		public void setTryingToConnect(boolean tryingToConnect) {
			this.tryingToConnect = tryingToConnect;
		}

		public int[] getPenultimateArray() {
			return penultimateArray;
		}

		public void setPenultimateArray(int[] penultimateArray) {
			this.penultimateArray = penultimateArray;
		}

		public User getCurrentUser() {
			return currentUser;
		}

		public void setCurrentUser(User currentUser) {
			this.currentUser = currentUser;
		}

		public long getServerID() {
			return serverID;
		}

		public void setServerID(long serverID) {
			this.serverID = serverID;
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

    public boolean isAutoReconnect() {
        return autoReconnect;
    }

    public void setAutoReconnect(boolean autoReconnect) {
        this.autoReconnect = autoReconnect;
    }

	public int getPadding() {
		return padding;
	}

	public void setPadding(int padding) {
		this.padding = padding;
	}

	public int getInterCommandInterval() {
		return interCommandInterval;
	}

	public void setInterCommandInterval(int interCommandInterval) {
		this.interCommandInterval = interCommandInterval;
	}

	public int paramToInt (CommandInterface command, Fields commandField, int minVal, int maxVal, String errorMessage) throws ParameterException  {
		String value = command.getValue (commandField);
		String exceptionMessage = errorMessage + " "+ value;
		try {
			Integer intVal = Integer.parseInt(value);
			if (intVal < minVal || intVal > maxVal){
					throw new ParameterException (exceptionMessage);
			}
			return intVal;
			
		} catch (NullPointerException ex){
			logger.log (Level.FINER,exceptionMessage);
			throw new ParameterException (exceptionMessage);
		} catch (NumberFormatException ex){
			logger.log (Level.FINER,exceptionMessage);		
			throw new ParameterException (exceptionMessage);
		}
	}
	

	public void sendToFlash ( long targetFlashID, CommandInterface command) {
		command.setTargetDeviceID(targetFlashID);
		String theKey = command.getDisplayName();
		logger.log (Level.FINEST,"Sending to flash " + theKey + ":" + command.getCommandCode() + ":" + command.getExtraInfo());
		sendToFlash (command,cache);
	}
	
	public void sendToFlash (CommandInterface command, Cache cache ) {
		cache.setCachedCommand(command.getDisplayName(),command);
		logger.log (Level.FINE,"Sending to flash " + command.getKey() + ":" + command.getCommandCode() + ":" + command.getExtraInfo());
		commandQueue.add(command);
	}
	

	public void sendToFlash (String displayName, String command, String value) {
		Command flashCommand = new Command ();
		flashCommand.setKey ("CLIENT_SEND");
		flashCommand.setDisplayName(displayName);
		flashCommand.setCommand(command);
		flashCommand.setExtraInfo(value);
		sendToFlash (flashCommand,cache);
	}

	public void sendToFlash (String displayName, String command, String value,String extra2,String extra3,String extra4,String extra5,long targetDeviceID) {		
		Command flashCommand = new Command ();
		flashCommand.setKey ("CLIENT_SEND");
		flashCommand.setDisplayName(displayName);
		flashCommand.setCommand(command);
		flashCommand.setExtraInfo(value);
		flashCommand.setExtra2Info(extra2);
		flashCommand.setExtra3Info(extra3);
		flashCommand.setExtra4Info(extra4);
		flashCommand.setExtra5Info(extra5);
		flashCommand.setTargetDeviceID(targetDeviceID);

		sendToFlash (flashCommand,cache);
	}
	
	public void sendMessage (String title, String content, String autoclose, String icon,String hideclose,String targetUser, String target, long targetDeviceID) {		
		ClientCommand flashMessage = new ClientCommand ();
		flashMessage.setMessageType(ClientCommand.Message);
		flashMessage.setTitle(title);
		flashMessage.setAutoclose(autoclose);
		flashMessage.setIcon(icon);
		flashMessage.setHideclose(hideclose);
		flashMessage.setTargetUser(targetUser);
		flashMessage.setContent(content);
		flashMessage.setTarget(target);
		flashMessage.setKey ("MESSAGE");
		flashMessage.setDisplayName("MESSAGE");
		flashMessage.setOriginatingID(this.getInstanceID());
		commandQueue.add(flashMessage);
	}
	
	public CommandInterface buildCommandForFlash (DeviceType device , String command, String extra,String extra2,String extra3,String extra4,String extra5,long targetDeviceID) {
		CommandInterface videoCommand = device.buildDisplayCommand ();
		videoCommand.setKey ("CLIENT_SEND");
		videoCommand.setTargetDeviceID(targetDeviceID);
		videoCommand.setCommand (command);
		videoCommand.setExtraInfo (extra);
		videoCommand.setExtra2Info (extra2);
		videoCommand.setExtra3Info (extra3);
		videoCommand.setExtra4Info (extra4);
		videoCommand.setExtra5Info (extra5);
		
		return videoCommand;
	}

	public CommandInterface buildOffCommandForFlash (DeviceType device) {
		return buildCommandForFlash (device,"off","","","","","", 0);
	}

	public CommandInterface buildCommandForFlash (DeviceType device , String command, String extra) {
		return buildCommandForFlash (device,command,extra,"","","","", 0);
	}

	public CommandInterface buildCommandForFlash (DeviceType device , String command, String extra, String extra2) {
		return buildCommandForFlash (device,command,extra,extra2,"","","", 0);
	}
	
	public CommandInterface buildCommandForFlash (DeviceType device , String command, String extra, String extra2, String extra3) {
		return buildCommandForFlash (device,command,extra,extra2,extra3,"","", 0);
	}

	public CommandInterface buildCommandForFlash (DeviceType device , String command, String extra, String extra2,String extra3,String extra4) {
		return buildCommandForFlash (device,command,extra,extra2,extra3,extra4,"", 0);
	}

	public CommandInterface buildCommandForFlash (DeviceType device , String command, String extra, String extra2,String extra3,String extra4,String extra5) {
		return buildCommandForFlash (device,command,extra,extra2,extra3,extra4,extra5, 0);
	}

	/**
	 * True if decimal to the device requires decimal keys (rare) 
	 * @return True or false
	 */
	public boolean isDeviceKeysDecimal() {
		return deviceKeysDecimal;
	}

	/**
	 * True if decimal to the device requires decimal keys (rare) 
	 */	
	public void setDeviceKeysDecimal(boolean decimalKeys) {
		this.deviceKeysDecimal = decimalKeys;
	}

	/**
	 * True if the keys are specified in the configuration file in decimal
	 * @return True or false
	 */
	public boolean isConfigKeysInDecimal() {
		return configKeysInDecimal;
	}

	/**
	 * True if the keys are specified in the configuration file in decimal
	 * @return True or false
	 */
	public void setConfigKeysInDecimal(boolean configKeysInDecimal) {
		this.configKeysInDecimal = configKeysInDecimal;
	}
	
	/**
	 * Formats a key into the appropriate format for interacting with the config file.
	 * @return Formatted key
	 */
    public String formatKey(int key,DeviceType device) throws NumberFormatException {
    	
		int padding = getPadding();
		String formatSpec = "%0";
		formatSpec += padding;

		if (!this.isDeviceKeysDecimal()){
			formatSpec += "X";
		} else {
			formatSpec += "d";			
		}
			
		return String.format(formatSpec,key);
    }

	/**
	 * Formats a key into the appropriate format for interacting with the config file.
	 * @return Formatted key
	 */
    public String formatKey(String key,DeviceType device) throws NumberFormatException {
		int keyInt = 0;
		if (isConfigKeysInDecimal()){
			keyInt = Integer.parseInt(key);
		} else{
			keyInt = Integer.parseInt(key,16);
		}
    	return formatKey(keyInt,device);
    }

	public VersionManager getVersionManager() {
		return versionManager;
	}

	public void setVersionManager(VersionManager versionManager) {
		this.versionManager = versionManager;
	}

	public ModelTypes getModelType() {
		return modelType;
	}

	public void setModelType(ModelTypes modelType) {
		this.modelType = modelType;
	}
	
	/**
	 * @return Returns the eventCalendar.
	 */
	public EventCalendar getEventCalendar() {
		return eventCalendar;
	}
	/**
	 * @param eventCalendar The eventCalendar to set.
	 */
	public void setEventCalendar(EventCalendar eventCalendar) {
		this.eventCalendar = eventCalendar;
	}

	public Logger getLogger() {
		return logger;
	}

	public void setLogger(Logger logger) {
		this.logger = logger;
	}

	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}
	


	public String getAppendToSentStrings() {
		return appendToSentStrings;
	}

	public void setAppendToSentStrings(String endString) {
		this.appendToSentStrings = endString;
	}
	
	/**
	 * If a raw code has been specified for this command on this device. It will be returned.
	 * @param command
	 * @param device
	 * @return
	 */
	public String doRawIfPresent (CommandInterface command, DeviceType targetDevice) { 
		
		String returnCode = doCustomConnectIfPresent(command,targetDevice);
		
		if (returnCode != null) return returnCode;
		
		Map rawCodes = targetDevice.getRawCodes(); // the list specified in the config for this device line.

		if (rawCodes!= null){
			String commandName = command.getCommandCode();
			String extraFromClient = (String)command.getExtraInfo();
			RawItemDetails rawCode = (RawItemDetails)rawCodes.get(commandName+":"+extraFromClient); // pull up details for the line
			
			if (rawCode == null) 
				rawCode = (RawItemDetails)rawCodes.get(commandName); // pull up details for the line				

			if (rawCode != null){
				Map rawCatalogue = getCatalogueDef(rawCode.getCatalogue());
				if (rawCatalogue == null ) {
					logger.log (Level.WARNING ,"Specified raw catalogue is not defined : "+rawCatalogue);	
					return null;
				}
				else {
					String catalogueValue = (String)rawCatalogue.get(rawCode.getCode());
					return rawCode.populateVariables (catalogueValue,command);
				}
			}
		} 
		
		return null;
	}

	/**
	 * If a raw code has been specified for this command on this device. It will be returned.
	 * @param command
	 * @param device
	 * @return
	 */
	public String doCustomConnectIfPresent (CommandInterface command, DeviceType device) { 
		if (device == null || device.getDeviceType() != DeviceType.CUSTOM_CONNECT ) return "";
			
		CustomConnect customConnect = (CustomConnect) device;

		String outValue = customConnect.getValue(command.getCommandCode(),command.getExtraInfo());
		outValue = scanCustomString (command, outValue, device);
		return outValue;
	}
	
	public String scanCustomString (CommandInterface command, String value,DeviceType device ) {
		try {
			StringBuffer sb = new StringBuffer();		
			Matcher resultLookup = customScanLookupString.matcher(value);
			while (resultLookup.find()) {
				// Lookup the parameter value from the catalogue
				this.findKeyForParameterValue( resultLookup.group(2),
						command.getValue(Fields.valueOf(resultLookup.group(1))),
						device);
			}
			resultLookup.appendTail(sb);
			value = sb.toString();

			sb = new StringBuffer();		
			
			Matcher resultCmd = customScanCommandString.matcher(value);
			while (resultCmd.find()){
				resultCmd.appendReplacement(sb,command.getValue(Fields.valueOf(resultCmd.group(1))) );
			}
			resultCmd.appendTail(sb);
	
			return sb.toString();
		} catch (IllegalArgumentException ex){
			logger.log (Level.WARNING,"There was a problem processing the custom instruction for " + device.getName() + " in the model " + this.getName() + " " + ex.getMessage());
			return "";
		}catch (ParameterException ex){
			logger.log (Level.WARNING,"There was a problem processing the custom instruction for " + device.getName() + " in the model " + this.getName() + " " + ex.getMessage());
			return "";
		}
	}
	
}
