/*
 * Created on Jan 26, 2004
 *
*/
package au.com.BI.Util;

import java.util.*;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.Bootstrap;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Config.ParameterException;
import au.com.BI.GC100.IRCodeDB;
import au.com.BI.Home.VersionManager;
import au.com.BI.Macro.MacroHandler;
import au.com.BI.Messaging.AddressBook;
/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 * Provides a consistent ancestor for all device specific model classes
 *
*/
public interface DeviceModel {

	public static final int SUCCESS = 0;
	public static final int FAIL = 2;
	public static final int SECURITY_FAIL = 1;

	public static final int SERIAL = 1;
	public static final int IP = 2;

	public static final int COMFORT_SERIAL = 0;
	public static final int COMFORT_IP = 1;
	public static final int CBUS_COMFORT = 2;
	public static final int CBUS = 3;
	public static final int X10 = 4;
	public static final int COMFORT_DIRECT = 5;

	public static final int NUMBER_CATALOGUES = 5;
	public static final int NUMBER_PARAMETERS = 10;
	public static final int NUMBER_DEVICE_GROUPS = 5;
	public static final String MAIN_DEVICE_GROUP = "Group0";

	public static final int NUMBER_CACHE_COMMANDS = 100;
	// probably number of devices that will need flash client commands cached for
	// startup information

	public static final int PROBABLE_FLASH_CLIENTS = 5;

	public static final int NUMBER_MACROS = 10;

	public static final long TIME_TO_WAIT_FOR_RESPONSE = 2000; // 2 seconds maximum time for a device to respond before sending next command

	public static final int FLASH_SLIDER_RES = 10;

	/**
	 * True if this device is a touch panel
	 * @return true or false
	 */
	public boolean touchPanel ();

	/**
	 * Finds which controller is used to communicate with a physical device
	 * Items are either controlled; the server will act in some way from this command
	 * or output; output items are physical devices the server can activate
	 * @param itemKey The name of the item from the configuration file
	 * @param isClientCommand Did this command originate from a flash client
	 * @return if this item is controlled by this device
	 */
	public boolean doIControl (String itemKey, boolean isClientCommand);


	/**
	 * The primary way for the device controller to execute a command once it is found
	 * to control it.
	 * @param command The command object off the command queue
	 */
	public void doCommand (CommandInterface command) throws au.com.BI.Comms.CommsFail ;

	/**
	 * Every device should know how to restablish connections with itself
	 * If it is not able to self repair or has catastrophically failed false is returned
	 *
	 */
	public boolean reEstablishConnection ();

        /*
         * Some devices the controller should not try to re-establish connections after comms failure 
         * default is to enable auto reconnect (true)
         */
        
        public boolean isAutoReconnect();

        public void setAutoReconnect(boolean autoReconnect);
	/**
	 * Establishes connection based on parameters read from the config file
	 */
	public void attatchComms() throws au.com.BI.Comms.ConnectionFail;

	/** Provides a hook to disable manual heartbeats (newline character) on IP connections
	 *
	 * @return true/false
	 * @throws au.com.BI.Comms.CommsFail
	 */
	public boolean doIPHeartbeat ();

	/**
	 * Log into the device handler.
	 * Return true if the device has no security concepts.
	 * @param user user object
	 * @see au.com.BI.User.User
	 * @throws au.com.BI.Comms.CommsFail
	 * @return Success
	 */
	public int login(au.com.BI.User.User user) throws au.com.BI.Comms.CommsFail;

	/**
	 * Log into the device handler.
	 * Return true if the device has no security concepts.
	 * @param user user object
	 * @see au.com.BI.User.User
	 * @throws au.com.BI.Comms.CommsFail
	 * @return Success
	 */
	public int logout(au.com.BI.User.User user) throws au.com.BI.Comms.CommsFail;

	/**
	 * Called by the configuration reader
	 * @param controlType monitored, input our output
	 * <B>DeviceType.monitored</B> items have the state monitored and changes are reflected
	 * in the client
	 * <B>DeviceType.output</B> items are controlled by the device
	 * <B>DeviceType.input</B> items generate actions within the server software to represent
	 * user interaction on the item. At this stage only the flash client generates these
	 * @param name non unique key name for physical device
	 * @param details object representing details of the device
	 * @see au.com.BI.Util.DeviceType
	 */
	public void addControlledItem (String name, DeviceType details, int controlType);

	/**
	 * Called by the configuration reader.
	 * This are the commands that are used to pick up state after a startup query.
	 * @param controlType monitored, input our output
	 * <B>DeviceType.monitored</B> items have the state monitored and changes are reflected
	 * in the client
	 * <B>DeviceType.output</B> items are controlled by the device
	 * <B>DeviceType.input</B> items generate actions within the server software to represent
	 * user interaction on the item. At this stage only the flash client generates these
	 * @param name non unique key name for physical device
	 * @param details object representing details of the device
	 * @see au.com.BI.Util.DeviceType
	 */
	public void addStartupQueryItem (String name, Object details, int controlType);

	/**
	 * Used on restart to clear all currently known items
	 */
	public void clearItems ();

	/**
	 * Name is used by the config reader to tie a particular device to configuration
	 * @param name The identifying string for this device handler
	 */
	public void setName (String name);


	/**
	 * Name is used by the config reader to tie a particular device to configuration
	 */
	public String getName ();

	/**
	 * Any object can add commands to the queue
	 * @param commandQueue A syncronised list to add commands
	 */
	public void setCommandQueue (CommandQueue commandQueue);
    public CommandQueue getCommandQueue() ;
	public void setParameter (String name, String value,String groupName);
	public String getParameterValue (String Name,String groupName);

	
	/**
	 * Finds the key for a particular catalogue value
	 * @param srcCode The value
	 * @param catalogName The catalog to search
	 * @param device The device that is associated with the command being interpretted
	 * @exception NumberFormatException,ParameterException
	 * @return The key
	 */
	public String findKeyForParameterValue(String srcCode, String catalogName,DeviceType device)  throws NumberFormatException,ParameterException;
	
	/**
	 * Finds the key for a particular catalogue value
	 * @param src The value
	 * @param catalogName The catalog to search
	 * @param device The device that is associated with the command being interpretted
	 * @return The key
	 */
	public String findKeyForParameterValue(int src, String catalogName,DeviceType device) throws ParameterException;
		
	/**
	 * Raw definitions are used for direct serial strings
	 * @param raw defs. A map of the definitions.
	 */
	public void setCatalogueDefs (String mapName, HashMap<String,String> defs);
	public Map getCatalogueDef (String mapName);

	/**
	 * Close the communication layer
	 * @throws ConnectionFail
	 */
	public void closeComms() throws ConnectionFail;

	/**
	 * Called for a model to clean up before closing down, any threads it has launched should be terminated
	 * @throws ConnectionFail
	 */
	public void close() throws ConnectionFail;

	/**
	 * Runs the overall system startup
	 * @param commandQueue The system command queue
	 */
	public void doStartup() throws au.com.BI.Comms.CommsFail;

	public int getInstanceID ();

	public void setInstanceID (int instanceID);

	public void setCache (au.com.BI.Command.Cache cache);

     public void setVariableCache(HashMap<String,Object> variableCache);

	/** General hook for a device to do any final startup once the configuration is loaded and before comms is 
	 * established */
	public void finishedReadingConfig () throws SetupException;

   	/** 
   	 * A hook which occurs after the configuration parser has read the to level parameters 
    *	but has not yet begun the individual device entries. 
    */
	public void finishedReadingParameters ();
	
	/**
	 * Sets a display name to be used error reporting
	 * @param displayModel
	 */
	public void setDescription (String description);

	/**
	 * True if this device supports IR controllers
	 * @return true/false
	 */
	public boolean doIControlIR ();

    /**
     * @return Returns the irCodeDB.
     */
    public IRCodeDB getIrCodeDB();

    /**
     * @param irCodeDB The irCodeDB to set.
     */
    public void setIrCodeDB(IRCodeDB irCodeDB);

    /**
     * Every model may need to use the macro engine
     * @param macroHandler
     */
    public void setMacroHandler (MacroHandler macroHandler);


    /**
     * Whether to remove this model when the config file reloaded, or to leave it on the list
     * @return true for reload
     */
    public boolean removeModelOnConfigReload ();

    /**
     * Returns the list of models in the application
     * @return
     */
	public Collection getModelList();

	/**
	 * @param modelList The modelList to set.
	 */
	public void setModelList(Collection modelList) ;

	/**
	 * @return Returns the configHelper.
	 */
	public ConfigHelper getConfigHelper() ;

	/**
	 * @param configHelper The configHelper to set.
	 */
	public void setConfigHelper(ConfigHelper configHelper);

	/**
	 * @return Returns the bootstrap.
	 */
	public Bootstrap getBootstrap();

	/**
	 * @param bootstrap The bootstrap to set.
	 */
	public void setBootstrap(Bootstrap bootstrap);

	/**
	 * Tests if the device has successfully connected
	 * @return true/false
	 */
	public boolean isConnected();

	/**
	 * Sets the connected state for the device
	 * @param connected
	 */
	public void setConnected(boolean connected) ;
	
	/**
	 * This is a hook to allow specific IP heartbeat strings to be specified if required for a device. The default if not
	 * specified is for \n
	 * @return The string to use
	 */
	public String getHeartbeatString ();
	
	/**
	 * If the controller is currently trying to connect to this device 
	 * @return true if currently trying
	 */
	public boolean isTryingToConnect ();
	
	public void setTryingToConnect (boolean state);

	/**
	 * ALL_SERVERS indicates that all servers should attend to the command.
	 */
	public static final long ALL_SERVERS = -1;
	
	/**
	 * Gets the server ID supporting the model
	 * @return Server ID
	 */
	public long getServerID();

	/**
	 * Sets the server ID supporting the model
	 * @param serverID
	 */
	public void setServerID(long serverID);

    /** 
     * Called when a new client connects to the server identified by serverID
     * @param commandQueue The global event queue
     * @param targetFlashDeviceID The target ID of the handler for the new client
     * @param serverID The server ID to process the startup. 
     */
	public void doClientStartup( long targetFlashDeviceID, long serverID);


	public AddressBook getAddressBook();

	public void setAddressBook(AddressBook addressBook);

	public AlarmLogging getAlarmLogging();

	public void setAlarmLogging(AlarmLogging alarmLogging);
	
	/**
	 * Padding is greater than 1 when a device requires a key of a certain length.
	 * @return The required key length.
	 */
	public int getPadding();

	/**
	 * Padding is greater than 1 when a device requires a key of a certain length.
	 */	
	public void setPadding(int padding);
	
	
	/**
	 * The key is formatted as required by the particular model. Currently pading and decimal/hex can be configured as 
	 * parameters that this function will use.
	 * @param key
	 * @return The formatted key
	 */
    public String formatKey(String key);
    
	/**
	 * The key is formatted as required by the particular model. Currently pading and decimal/hex can be configured as 
	 * parameters that this function will use.
	 * @param key
	 * @return The formatted key
	 */
    public String formatKey(int key);
   
	/**
	 * True if decimal to the device requires decimal keys (rare) 
	 * @return True or false
	 */
	public boolean isDeviceKeysDecimal() ;
	/**
	 * True if decimal to the device requires decimal keys (rare) 
	 */	
	public void setDeviceKeysDecimal(boolean decimalKeys) ;
	/**
	 * True if the keys are specified in the configuration file in decimal
	 * @return True or false
	 */
	public boolean isConfigKeysInDecimal();

	/**
	 * True if the keys are specified in the configuration file in decimal
	 * @return True or false
	 */
	public void setConfigKeysInDecimal(boolean configKeysInDecimal) ;
	
	/**
	 * Used to specify a minimum interval between commands sent by the server. Leave as 0 if no minimum is required.
	 * @return The interval
	 */
	public int getInterCommandInterval();

	/**
	 * Used to specify a minimum interval between commands sent by the server. Leave as 0 if no minimum is required.
	 * @param interCommandInterval
	 */
	public void setInterCommandInterval(int interCommandInterval);

	/**
	 * A utility function to assist in model development
	 * @param command
	 * @param cache
	 */
	public void sendToFlash (CommandInterface command, Cache cache ) ;
	
	/**
	 * A utility function to assist in model development
	 * @param command
	 * @param cache
	 */
	public void sendToFlash (String displayName, String command, String value);

	public VersionManager getVersionManager() ;

	public void setVersionManager(VersionManager versionManager) ;
	
}


