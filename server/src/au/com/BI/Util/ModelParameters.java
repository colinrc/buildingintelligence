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
import au.com.BI.GC100.IRCodeDB;
import au.com.BI.Home.VersionManager;
import au.com.BI.User.User;
import au.com.BI.Util.DeviceModel.ModelTypes;
import au.com.BI.LabelMgr.LabelMgr;
import au.com.BI.Macro.MacroHandler;
import au.com.BI.Config.Bootstrap;
import au.com.BI.AlarmLogging.*;
import au.com.BI.Messaging.*;
import au.com.BI.Device.DeviceType;

import java.util.*;
import java.util.logging.*;

public class ModelParameters  {
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

        protected au.com.BI.Command.Cache cache;
        protected HashMap<String,Object> variableCache;
        protected boolean isStartupQuery = false;
        protected IRCodeDB irCodeDB;

        protected int InstanceID;
        protected String description;
        protected int transmitOnBytes = 0;
        protected MacroHandler macroHandler;
        protected Collection <DeviceModel>modelList;
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
		protected LabelMgr labelMgr = null;
		protected boolean naturalPackets = false;
		protected au.com.BI.Patterns.Model patterns = null;
		protected boolean IPHeartbeat = true;;
		
		public User currentUser = null;
		
        public ModelParameters() {
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
	            parameters = new HashMap<String, HashMap<String,String>>(DeviceModel.NUMBER_DEVICE_GROUPS);
	            topMap = new HashMap<String,String>(DeviceModel.NUMBER_PARAMETERS);
	            parameters.put(DeviceModel.MAIN_DEVICE_GROUP, topMap);
	            rawDefs = new HashMap<String,HashMap<String,String>>(DeviceModel.NUMBER_CATALOGUES);
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


    	
    	
        public void doStartup()  throws au.com.BI.Comms.CommsFail {};

        
        /**
         * @deprecated
         */
        public final void doStartup(CommandQueue commandList)  throws au.com.BI.Comms.CommsFail {};

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

        public String getName() {
                return name;
        }

        public void setCache(au.com.BI.Command.Cache cache) {
                this.cache = cache;
        }
        
        public au.com.BI.Command.Cache getCache() {
           return  cache;
        }

        public void setVariableCache(HashMap <String,Object>variableCache) {
                this.variableCache = variableCache;
        }

  
        public boolean touchPanel() {
                return false;
        }



  

        public boolean reEstablishConnection() {
                return true;
        }

    
        public void setCommandQueue(CommandQueue commandQueue) {
                this.commandQueue = commandQueue;
        }
        
        public CommandQueue getCommandQueue() {
            return commandQueue;
        }

        /**
         * @return Returns the rawDefs.
         */
        public  HashMap<String,String> getCatalogueDef(String name) {
                return rawDefs.get(name);
        }

        /**
         * @param rawDefs The rawDefs to set.
         */
        public  void setCatalogueDefs(String name, HashMap<String,String> rawDefs) {
                this.rawDefs.put(name, rawDefs);
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
        public Collection <DeviceModel> getModelList() {
                return modelList;
        }

        /**
         * @param modelList The modelList to set.
         */
        public void setModelList(Collection<DeviceModel> modelList) {
                this.modelList = modelList;
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

	public LabelMgr getLabelMgr() {
		return labelMgr;
	}

	public void setLabelMgr(LabelMgr labelMgr) {
		this.labelMgr = labelMgr;
	}

	public boolean isNaturalPackets() {
		return naturalPackets;
	}

	public void setNaturalPackets(boolean naturalPackets) {
		this.naturalPackets = naturalPackets;
	}

	public au.com.BI.Patterns.Model getPatterns() {
		return patterns;
	}

	public void setPatterns(au.com.BI.Patterns.Model patterns) {
		this.patterns = patterns;
	}


    public boolean doIPHeartbeat() {
            return IPHeartbeat;
    }

	public void setIPHeartbeat(boolean heartbeat) {
		IPHeartbeat = heartbeat;
	}
}
