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

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.GC100.IRCodeDB;
import au.com.BI.User.User;
import java.util.*;
import java.util.logging.*;
import au.com.BI.Macro.MacroHandler;
import au.com.BI.Config.Bootstrap;
import au.com.BI.AlarmLogging.*;
import au.com.BI.Messaging.*;

public class BaseModel
  implements DeviceModel {
        protected CommDevice comms = null;

        protected boolean logged_in = false;

        protected boolean connected = false;
        private boolean autoReconnect = true;

        protected Map <String,Map>rawDefs;
        protected HashMap <String,HashMap> parameters;
        protected HashMap <String,String>topMap; // a convienience reference to the top level map

        protected Logger logger;

        protected String name = "Unknown";
        protected List commandQueue;
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
		protected AlarmLogging alarmLogging = null;
		
		protected int padding = 1; // Number of digits to pad the key too in the device.
		
		
		public User currentUser = null;
		
        public BaseModel() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
                configHelper = new ConfigHelper();
                parameters = new HashMap<String,HashMap>(DeviceModel.NUMBER_DEVICE_GROUPS);
                topMap = new HashMap<String,String>(DeviceModel.NUMBER_PARAMETERS);
                parameters.put(DeviceModel.MAIN_DEVICE_GROUP, topMap);
                rawDefs = new HashMap<String,Map>(DeviceModel.NUMBER_CATALOGUES);
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

        public void finishedReadingConfig() throws SetupException {};

        public void doStartup(java.util.List commandQueue)  throws au.com.BI.Comms.CommsFail {};

        /** 
         * Called when a new client connects to the server
         * @param commandQueue
         * @param targetFlashDeviceID
         * @param serverID
         */
    		public void doClientStartup(java.util.List commandQueue, long targetFlashDeviceID, long serverID){};

    		
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

        public void addControlledItem(String name, DeviceType details, int controlType) {
                String theKey = name;

                configHelper.addControlledItem(theKey, details, controlType);
        }

        public boolean doIControl(String keyName, boolean isClientCommand) {

                configHelper.wholeKeyChecked(keyName);

                if (configHelper.checkForOutputItem(keyName)) {
                        logger.log(Level.FINER, "Flash sent command : " + keyName);
                        return true;
                }
                if (isClientCommand)return false; // only are about output for client commands

                if (configHelper.checkForStartupItem(keyName)) {
                        logger.log(Level.FINER, "Controls : " + keyName);
                        isStartupQuery = true;
                        return true;
                }
                if (configHelper.checkForControlledItem(keyName)) {
                        logger.log(Level.FINER, "Controls : " + keyName);
                        return true;
                }
                if (configHelper.checkForInputItem(keyName)) {
                        logger.log(Level.FINER, "Controls : " + keyName);
                        return true;
                }
                return false;
        }

        public void doCommand(CommandInterface command) throws CommsFail {

                if (configHelper.getLastCommandType() == DeviceType.OUTPUT) {
                        doOutputItem(command);
                }
                else {
                        if (configHelper.getLastCommandType() == DeviceType.INPUT) {
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
        public void attatchComms(List commandList) throws ConnectionFail {
                SerialParameters parameters = null;
                if ( ( (String)this.getParameter("Connection_Type", DeviceModel.MAIN_DEVICE_GROUP)).equals("SERIAL")) {

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
                        parameters = new SerialParameters();
                        parameters.buildFromDevice(this);
                        synchronized (comms) {
                                ( (Serial) comms).connect( (String)this.getParameter("Device_Port", DeviceModel.MAIN_DEVICE_GROUP),
                                  parameters, commandList, this.getInstanceID(),this.getName());
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
						if (penultimateArray != null) comms.setPenultimateArray(penultimateArray);

                        synchronized (comms) {
                                ( (IP) comms).connect( (String)this.getParameter("IP_Address", DeviceModel.MAIN_DEVICE_GROUP),
                                  (String)this.getParameter("Device_Port", DeviceModel.MAIN_DEVICE_GROUP),
                                  commandList, this.getInstanceID(), doIPHeartbeat(),getHeartbeatString(),this.getName());
                                comms.clearCommandQueue();
                        }
                }
                //connected = true;
        }

        public void setCommandQueue(List commandQueue) {
                this.commandQueue = commandQueue;
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
        public final Map getCatalogueDef(String name) {
                return (Map) rawDefs.get(name);
        }

        /**
         * @param rawDefs The rawDefs to set.
         */
        public final void setCatalogueDefs(String name, Map rawDefs) {
                this.rawDefs.put(name, rawDefs);
        }

        public Object getParameter(String name, String groupName) {
                HashMap theMap;
                if (groupName == null || groupName.equals("")) groupName = DeviceModel.MAIN_DEVICE_GROUP;

                if (!groupName.equals(DeviceModel.MAIN_DEVICE_GROUP) && parameters.containsKey(groupName)) {
                        theMap = (HashMap) parameters.get(groupName);
                        Object item = theMap.get(name);
                        if (item == null)
                                return "";
                        else
                                return item;
                }
                else {
                        Object item = topMap.get(name);
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
                                theMap = (HashMap<String,String>) parameters.get(groupName);
                        else
                                theMap = new HashMap<String,String>(DeviceModel.NUMBER_PARAMETERS);
                }

                theMap.put(name, value);
                parameters.put(groupName, theMap);
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

        public void addStartupQueryItem(String name, Object details, int controlType) {};

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

}
