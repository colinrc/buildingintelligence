/*
 * Created on Apr 11, 2004
 *
 */

package au.com.BI.Command;

import au.com.BI.Util.*;
import java.util.*;
import java.util.logging.*;
import au.com.BI.Home.Controller;
import au.com.BI.JRobin.*;

/**
 * @author Colin Canfield
 *
 * This object caches commands to and from the flash interface.
 * It provides a representation of the physical state of devices
 *
 */

public class Cache {

        protected Map<String,CacheWrapper> cachedCommands;
        protected Logger logger;
        protected Controller controller;
        protected JRobinCacheUpdater jRobinCacheUpdater = null;
		protected boolean jRobinActive = false;
		protected List<CacheListener> cacheListeners = null;

        public Cache() {
                cachedCommands = Collections.synchronizedMap(new HashMap<String,CacheWrapper>(
                    DeviceModel.NUMBER_CACHE_COMMANDS));
                logger = Logger.getLogger(this.getClass().getPackage().getName());
                cacheListeners = new LinkedList<CacheListener>();
        }

        public Collection getSetElements(CacheWrapper cachedObject) {
			if (cachedObject.isSet()) {
                return cachedObject.getMapValues();
			} else {
				return null;
			}
        }

        /**
         * Notified when cache updates occur
         * @param cacheListener
         */
        public void registerCacheListener (CacheListener cacheListener){
        	cacheListeners.add(cacheListener);
        }
        
        /**
         * Returns a particular command structure or a set of command structures based on the rules determined
         * by cacheAllCommands. See setCachedCommand for details.
         * <P>
         * The objectIsSet method is provided to help determined the correct way to process the command
         * @param key
         * @return
         * @DEPRECATED
         */
/*
        public Object  getCachedCommand(String key) {
                Object commandObj ;
				
                synchronized (cachedCommands) {
					commandObj = cachedCommands.get(key);
                }
				if (!objectIsSet (commandObj)) {
					CommandInterface command = (CommandInterface)commandObj;
					if (command.getKey().equals ("CLIENT_SEND")) {
						command.setKey(key);
				    }
					return command;
				} else {
					return commandObj;
				}
        }*/

        /**
         * Returns a particular command structure or a set of command structures based on the rules determined
         * by cacheAllCommands. See setCachedCommand for details.
         * <P>
         * The objectIsSet method is provided to help determined the correct way to process the command
         * @param key
         * @return
         */

        public CacheWrapper getCachedObject(String key) {
             CacheWrapper commandObj ;
			try {	
                synchronized (cachedCommands) {
					commandObj = (CacheWrapper)cachedCommands.get(key);
                }
				if (commandObj == null) return null;
				if (!commandObj.isSet()) {
					CommandInterface command = (CommandInterface)(commandObj.getCommand());
					if (command.getKey().equals ("CLIENT_SEND")) {
						command.setKey(key);
				    }
					return commandObj;
				} else {
					return commandObj;
				}
			} catch (ClassCastException ex){
				logger.log (Level.WARNING ,"Cache object was incorrect type for key " + key);
				return null;
			}
        }
        

        public Collection<CacheWrapper> getAllCommands (){


    		LinkedList<CacheWrapper> result = new LinkedList<CacheWrapper>();
    		synchronized (cachedCommands){
    			Collection <CacheWrapper> commandSet = cachedCommands.values();

    			for (CacheWrapper command:commandSet){
    				if (command.isSendWithStartup()) {
    					result.add(command);
    				}
    			}
    		}
    		return result;
        }
        
        public Collection<CacheWrapper> getAllCommands (Date startTime, Date endTime){
        		long startLong = startTime.getTime();
        		long endLong = endTime.getTime();
        		LinkedList<CacheWrapper> result = new LinkedList<CacheWrapper>();
        		synchronized (cachedCommands){
        			Collection <CacheWrapper> commandSet = cachedCommands.values();

        			for (CacheWrapper command:commandSet){
        				if (!command.isSendWithStartup() && command.creationTime >= startLong && command.creationTime < endLong) {
        					//result.add(command.clone());
        					result.add(command);
        				}
        			}
        		}
        		return result;	
        }
		
        /*
         * @return Time last accessed
         */

        public Long getCachedTime(String key) {
                CacheWrapper cacheObject = this.getCachedObject(key);
                if (cacheObject == null) {
                        return new Long(0);
                }else {
					return cacheObject.getCreationDate();
                }
        }
		
        private void setCachedCommandSet(String key, CommandInterface command) {
            if (key.equals("MACRO") || key.equals("CALENDAR") ||
                key.startsWith("AV:")) {
                    return;
            }
	
			if (key.equals("CLIENT_SEND")) {
				key = command.getDisplayName();
			}


            synchronized (cachedCommands) {
                if (cachedCommands.containsKey(key)) {
                    CacheWrapper oldItem = (CacheWrapper)cachedCommands.get(key);
					oldItem.addToMap (key,command);
					updateListeners (key,command,oldItem.getTargetID(),true);
                }
                else {
					CacheWrapper newItem = new CacheWrapper (true);
					newItem.addToMap(key,command);
                    cachedCommands.put(key, newItem);
					updateListeners (key,command,command.getTargetDeviceID(),true);
                }
            }
            String displayName;
            if (command.isClient()) {
                    displayName = key;
            }
            else {
                   displayName = command.getDisplayName();
            }

		   if (this.jRobinActive) {
			   command.setJRobinData(controller.getJrobinDataObject(displayName));
			   jRobinCacheUpdater.doCommandForJRobin(command);
		   }
    }
		
        public void updateListeners (String key , CommandInterface command, long targetID, boolean isSet) {
        	for (CacheListener cacheListener:cacheListeners){
        		//cacheListener.cacheUpdated(key, (CacheWrapper)cacheWrapper.clone());
        		cacheListener.addToCommandQueue( key ,  command,  targetID,  isSet);
        		
        	}
        }
        


        
        /**
         * Adds a command to the cache, this represents the state of devices
         *
         * If the command structure has cacheAllCommands set to true, the call will store every command for a
         * particular DISPLAY_NAME, otherwise only the most recent for each DISPLAY_NAME will be stored.
         * <P>
         * COMMAND=on, COMMAND=off, are exceptions, receiving one will always overwrite the other
         * <P>
         * The two different forms are required for different devices.
         * For example lights only record the last event that occured; but a TV would record the state of on /off
         * volume, channel etc.
         *
         * @param key
         * @param command
         */
        public void setCachedCommand(String key, CommandInterface command) {
        	setCachedCommand(key,  command,  true);
        }

        /**
         * Adds a command to the cache, this represents the state of devices
         *
         * If the command structure has cacheAllCommands set to true, the call will store every command for a
         * particular DISPLAY_NAME, otherwise only the most recent for each DISPLAY_NAME will be stored.
         * <P>
         * COMMAND=on, COMMAND=off, are exceptions, receiving one will always overwrite the other
         * <P>
         * The two different forms are required for different devices.
         * For example lights only record the last event that occured; but a TV would record the state of on /off
         * volume, channel etc.
         *
         * @param key
         * @param command
         * @param includeInStartup If the command should be sent during client startup set this true. Eg. macros
         */
        public void setCachedCommand(String key, CommandInterface command, boolean includeInStartup) {
                /* if (key.equals("MACRO") || key.equals("CALENDAR") ||
                    key.startsWith("AV:")) {
                        return;
                } */
                if (key.startsWith("AV:")) {
                            return;
                }
                
		
				if (key.equals("CLIENT_SEND")) {
					key = command.getDisplayName();
				}

                if (command.cacheAllCommands()) {
                        setCachedCommandSet(key, command);
                }
                else {
                        synchronized (cachedCommands) {
                                if (cachedCommands.containsKey(key)) {
                                        CacheWrapper oldItem = (CacheWrapper)cachedCommands.get(key);
                                        if (!includeInStartup) oldItem.setSendWithStartup(includeInStartup);
                                        if (oldItem.isSet()) {
											oldItem.addToMap (key,command);
											updateListeners (key,command,command.getTargetDeviceID(),true);
                                        }
                                        else {
											oldItem.setCommand(key,command);
											updateListeners (key,command,command.getTargetDeviceID(),false);
                                        }
                                }
                                else {
									CacheWrapper newItem = new CacheWrapper (key,command);
                                   cachedCommands.put(key, newItem);
                                   if (!includeInStartup) newItem.setSendWithStartup(includeInStartup);
        							 updateListeners (key,command,command.getTargetDeviceID(),false);
                                }
                        }
                }
                String displayName;
                if (command.isClient()) {
                        displayName = key;
                }
                else {
                       displayName = command.getDisplayName();
                }

			   if (this.jRobinActive) {
				   command.setJRobinData(controller.getJrobinDataObject(displayName));
				   jRobinCacheUpdater.doCommandForJRobin(command);
			   }
        }
		
        public Iterator getStartupItemList() {
                return cachedCommands.keySet().iterator();
        }
		
        public void clear() {
                cachedCommands.clear();
        }

        public void setController(Controller controller) {
                this.controller = controller;
                //must be set at instantiation
				if (this.jRobinActive) {
					jRobinCacheUpdater = new JRobinCacheUpdater(controller);
				}
        }

        public Controller getController() {
                return this.controller;
        }

		public boolean isJRobinActive() {
			return jRobinActive;
		}


		public void setJRobinActive(boolean robinActive) {
			jRobinActive = robinActive;
			if (robinActive && jRobinCacheUpdater == null) {
				jRobinCacheUpdater = new JRobinCacheUpdater(controller);
			}
		}

}
