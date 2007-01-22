/**
 * 
 */
package au.com.BI.CBUS;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.Lights.LightFascade;
import au.com.BI.User.User;

/**
 * @author colin
 *
 */
public class MMIHelpers {
	
	protected Logger logger;
	protected CBUSHelper cBUSHelper;
	protected ConfigHelper configHelper;
	protected CommDevice comms ;
	public HashMap <String,ArrayList<Integer>>levelMMIQueues;
	public HashMap <String,String>sendingExtended;
	protected HashMap <String,String>cachedMMI;
	protected Model model;
	protected HashMap <String,StateOfGroup>state;
	protected boolean receivedLevelReturn = true;
	
	MMIHelpers (CBUSHelper cBUSHelper, ConfigHelper configHelper, CommDevice comms, HashMap  <String,StateOfGroup>state, Model model) {
		logger = Logger.getLogger(this.getClass().getPackage().getName());	
		sendingExtended = new HashMap<String,String> (256);
		levelMMIQueues = new HashMap<String,ArrayList<Integer>> (5);
		cachedMMI = new HashMap<String,String> (128);
		this.comms = comms;
		this.configHelper = configHelper;
		this.cBUSHelper= cBUSHelper;
		this.model = model;
		this.state = state;
	}
	
	protected void processMMI (String cBUSString, User currentUser ) throws CommsFail {
		String MMIKey = cBUSString.substring(0,6);
		String lastMMI = (String)cachedMMI.get (MMIKey);
		String numCharsStr = cBUSString.substring(0,2);
		int numPairs = 0;

		try {
			numPairs = Integer.parseInt(numCharsStr,16) - 192;
		} catch (NumberFormatException ex) {
			logger.log (Level.FINEST,"Received invalid pair count from Cbus MMI " + numCharsStr);
		}
		String appAddress = cBUSString.substring(2,4);
		int firstKey = 0;
		String firstKeyStr = cBUSString.substring(4,6);
		try {
			firstKey = Integer.parseInt(firstKeyStr,16);
		} catch (NumberFormatException ex) {
			logger.log (Level.FINEST,"Received invalid MMI group start address " + firstKeyStr);
		}
		if (firstKey == 0) {
			sendMMIQueue(appAddress);
			clearLevelMMIQueue(appAddress);
		}
		if (lastMMI == null || !lastMMI.equals(cBUSString) ) {
		    logger.log (Level.FINEST,"MMI command not cached, evaluating");

		    cachedMMI.put (MMIKey,cBUSString);

			if (numPairs >=  1) {


				String pairVal = "";
				int testValue1 = 0;
				int testValue2 = 0;
				int testValue3 = 0;
				int testValue4 = 0;

				// pair 0 is used to show the start group code.
				for (int i = 0; i < numPairs - 2; i ++ ) {
					pairVal = cBUSString.substring(6+i*2,8+i*2);
	
					int value = 0;
					try {
						value = Integer.parseInt(pairVal,16);
					} catch (NumberFormatException ex) {
						logger.log (Level.FINEST,"Received invalid MMI status byte " + pairVal);
					}
	
					testValue1 = value & 3;
					testValue2 = value & 12;
					testValue3 = value & 48;
					testValue4 = value & 192;
	
					if (testValue1 == 1) { 
						int key = firstKey + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!model.hasState(fullKey)) {
									if (receivedLevelReturn && !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}
							} else {									
								updateMMIState (MMIKey, key,appAddress,"on","100",currentUser);
							}
						}
					}
					if (testValue1 == 2) { 
						int key = firstKey + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						if (!model.hasState(fullKey)) {
							model.sendOutput (fullKey,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + i * 4,appAddress,"off","0",currentUser); 
						}
					}
	
					if (testValue2 == 4) {
						int key = firstKey + 1 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!model.hasState(fullKey)) {
									if (receivedLevelReturn && !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}
							} else {									
								updateMMIState (MMIKey,key,appAddress,"on","100",currentUser); 
							}
						}
					}
					if (testValue2 == 8) { 
						int key = firstKey + 1 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						if (!model.hasState(fullKey)) {
							model.sendOutput (fullKey,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + 1 + i * 4,appAddress,"off","0",currentUser); 
						}
					}
	
					if (testValue3 == 16) { 
						int key = firstKey + 2 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!model.hasState(fullKey)) {
									if (receivedLevelReturn&& !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}
							} else {									
								updateMMIState (MMIKey,key,appAddress,"on","100",currentUser); 
							}
						}
					}
					if (testValue3 == 32) { 
						int key = firstKey + 2 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						if (!model.hasState(fullKey)) {
							model.sendOutput (fullKey,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + 2 + i * 4,appAddress,"off","0",currentUser); 
						}
					}
	
					if (testValue4 == 64) { 
						int key = firstKey + 3 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!model.hasState(fullKey)) {
									if (receivedLevelReturn && !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}

							} else {									
								updateMMIState (MMIKey,key,appAddress,"on","100",currentUser); 
							}
						}
					}
					if (testValue4 == 128) { 
						int key = firstKey + 3 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key,DeviceType.LIGHT_CBUS);
						if (!model.hasState(fullKey)) {
							model.sendOutput (fullKey,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + 3 + i * 4,appAddress,"off","0",currentUser);
						}
					}
				}
			}
		}
	}
		
	protected void processLevelMMI (String cBUSString,User currentUser) throws CommsFail {
		String numCharsStr = cBUSString.substring(0,2);
		int numPairs = 0;

		try {
			numPairs = ((Integer.parseInt(numCharsStr,16) - 224) - 4) / 2;
		} catch (NumberFormatException ex) {
			logger.log (Level.FINER,"Received invalid pair count from Cbus MMI " + numCharsStr);
		}

		if (numPairs >=  1) {
			String appAddress = cBUSString.substring(4,6);
			int firstKey = 0;
			String firstKeyStr = cBUSString.substring(6,8);
			try {
				firstKey = Integer.parseInt(firstKeyStr,16);
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Received invalid MMI group start address " + firstKeyStr);
			}
			logger.log (Level.FINEST,"Received Level MMI request. Start key="+firstKeyStr + " #pairs=" + numPairs + " Str:"+ cBUSString);
			if (!receivedLevelReturn) {
				receivedLevelReturn = true;
				logger.log (Level.FINER,"Received Level return string, will now start processing MMI");
			}

			char nibbleVal1 = ' ';
			char nibbleVal2 = ' ';
			char nibbleVal3 = ' ';
			char nibbleVal4 = ' ';


			// pair 0 is used to show the start group code. 
			for (int i = 0; i <= numPairs ; i ++ ) {
				int keyVal = firstKey + i;
				String fullKey = cBUSHelper.buildKey(appAddress , keyVal,DeviceType.LIGHT_CBUS);
				
				if (!this.sendingExtended.containsKey(fullKey))
					continue;

				nibbleVal1 = cBUSString.charAt(8+i*4);
				nibbleVal2 = cBUSString.charAt(9+i*4);
				nibbleVal3 = cBUSString.charAt(10+i*4);
				nibbleVal4 = cBUSString.charAt(11+i*4);

				if (nibbleVal1 == '0' && nibbleVal2 == '0' && nibbleVal3 == '0' && nibbleVal4 == '0') {
					continue; //group address not present so skip processing
				}

				String realValue1 = findVal (nibbleVal1);
				String realValue2 = findVal (nibbleVal2);
				String realValue3 = findVal (nibbleVal3);
				String realValue4 = findVal (nibbleVal4);


				if (realValue1 == null || realValue2 == null || realValue3 == null || realValue4 == null) {
					logger.log (Level.FINER,"Noise was present in level request, polling again");
					this.sendExtendedQuery(firstKey + i,appAddress, currentUser,true);
					continue;
				}

				String fullBoolean = realValue3 + realValue4 + realValue1 + realValue2;
				int value = Integer.parseInt (fullBoolean,2);
				int normValue = (int)((double)value / 255.0 * 100.0);
				if (value == 255) normValue = 100;
				if (normValue == 0) normValue =1;
				String valStr = Integer.toString(normValue);
				CBUSDevice cBUSDevice = (CBUSDevice)configHelper.getControlledItem(fullKey);
				if (cBUSDevice == null || cBUSDevice.isRelay()){
					continue;
				}
				if (value == 0) {
					if (logger.isLoggable(Level.FINEST)){
						logger.log (Level.FINEST,"Sending CBUS off to flash for key "+keyVal + "(0x"+Integer.toHexString(keyVal)+")");
					}
					model.sendOutput (fullKey,"off","00",currentUser);
					this.sendingExtended.remove(fullKey);
				} else {
					if (!model.testState(fullKey,"on",valStr)) {
						if (logger.isLoggable(Level.FINEST)) {
								logger.log (Level.FINEST,"Sending CBUS on to flash for key "+keyVal + "(0x"+Integer.toHexString(keyVal)+") Lvl=" + valStr + " boolean="+fullBoolean);
						}
						model.sendOutput (fullKey,"on",valStr,currentUser);
					}
					this.sendingExtended.remove(fullKey);
				}
			}
		}
	}
	
	protected void updateMMIState (String MMIKey, int key , String appAddress,String command ,String extra,User currentUser) throws CommsFail {
		String fullKey = this.cBUSHelper.buildKey(appAddress,key,DeviceType.LIGHT_CBUS);
		StateOfGroup currentState = model.getCurrentState(fullKey);
		boolean fromMMI = currentState.isFromMMI();
		currentState.setPower(command,true);
		try {
			if (extra != null) {
				int level = Integer.parseInt(extra);
				currentState.setLevel(level,true);
			}

			if (currentState.getIsDirty() &&   currentState.countConflict == 0) {
				currentState.countConflict++;
				this.cachedMMI.remove(MMIKey);					
				currentState.setIsDirty(false);
				model.setCurrentState(fullKey,currentState);
			} else {
				if (!currentState.getIsDirty() && fromMMI &&  currentState.countConflict > 0) {
					currentState.countConflict++;
					if (currentState.countConflict >= 3) {
						currentState.setIsDirty(false);
						currentState.countConflict = 0;
						model.setCurrentState(fullKey,currentState);
						if (extra == null){
							sendExtendedQuery(key,appAddress,currentUser,true);
						} else {
							model.sendOutput(fullKey,command,extra,currentUser);
						}
					} else {
						this.cachedMMI.remove(MMIKey);
						currentState.setIsDirty(false);
						model.setCurrentState(fullKey,currentState);
					}
				}
			}
		} catch (NumberFormatException ex) {
			
		} catch (NullPointerException ex) {}
	}

	public String findVal (char value) {
		if (value == '5') return "11";
		if (value == '6') return "10";
		if (value == '9') return "01";
		if (value == 'A') return "00";
		return null;
	}

	public void sendMMIQueue (String appNumber) throws CommsFail {
		try {
			for (Integer i: levelMMIQueues.get(appNumber)){
				sendLevelMMIQuery (appNumber,i);			
			}
		} catch (NullPointerException ex ){
			// no queue exsists for the app number
		}
	}
	
	public void clearLevelMMIQueue (String appNumber){
		this.levelMMIQueues.remove (appNumber);
	}

	public void clearAllLevelMMIQueues () {
		this.levelMMIQueues.clear();
		this.sendingExtended.clear();
	}

	public void sendAllLevelMMIQueues () throws CommsFail  {
		for (String i: levelMMIQueues.keySet()) {
			sendMMIQueue(i);
		}
	}

	public void sendLevelMMIQuery (String appNumber, int number) throws CommsFail {
		// code is 7308 + app Code + 00 ; 20 ; 40 ;60 ;80 ; A0 ;C0 ; E0 (ie. each start of groups to return)
		
		String currentChar = model.nextKey();
		
		String outputCbusCommand = model.buildCBUSLevelRequestCommand(appNumber, number,currentChar);

		
		if (outputCbusCommand == null || outputCbusCommand.trim().equals("")){
			logger.log (Level.FINE,"Build CBUS Level request returned an empty string for App " + appNumber + " key " + number);
		} else {
			logger.log (Level.FINEST,"Sending Level CBUS request handshake key " + currentChar + " " + outputCbusCommand);
			CommsCommand cbusCommsCommand = new CommsCommand();
			cbusCommsCommand.setCommand(outputCbusCommand);
			cbusCommsCommand.setActionCode(currentChar);
			cbusCommsCommand.setKeepForHandshake(true);


			try {
				comms.addCommandToQueue (cbusCommsCommand);
				
				model.setLastSentTime (new Date().getTime());
			} catch (CommsFail e1) {
				throw new CommsFail ("Communication failed communicating with CBUS " + e1.getMessage());
			} catch (NullPointerException ex){
				logger.log(Level.WARNING,"Comms has not been properly set up for MMI processor in CBUS");
			}
		
			logger.log (Level.FINEST,"Queueing cbus command " + currentChar + " for " + outputCbusCommand);
		}
	}
	
	public void addToLevelMMIQueue (String appNumber, Integer startNumber) {
		ArrayList <Integer> appList;
		if (this.levelMMIQueues.containsKey(appNumber)) {
			appList = (ArrayList <Integer>)levelMMIQueues.get(appNumber);
		} else {
			appList = new ArrayList <Integer>(10);
		}
		if (!appList.contains(startNumber)) {
			appList.add(startNumber);
		}
		levelMMIQueues.put(appNumber,appList);
	}
	

	public void sendExtendedQuery (String key, String appCode, User user, boolean immediate,String targetLevel) throws CommsFail{
		try {
			sendExtendedQuery (Integer.parseInt(key,16),appCode, user,immediate,targetLevel);
		} catch (NumberFormatException ex) {}
	}

	public void sendExtendedQuery (int key, String appCode, User user, boolean immediate) throws CommsFail{
		try {
			sendExtendedQuery (key,appCode, user,immediate,"");
		} catch (NumberFormatException ex) {}
	}




	public void sendExtendedQuery (int key, String appCode, User user, boolean immediate,String targetLevel) throws CommsFail {
		
		String keyStr = cBUSHelper.buildKey(appCode,key,DeviceType.LIGHT_CBUS);
		//logger.log (Level.FINEST,"Sending MMI output App Code : "  + appCode + " command " + command + " group " + keyStr);
		try {
			CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(keyStr);
			if (cbusDevice != null) {
				if (cbusDevice.supportsLevelMMI()) { 
					int startNumber = (int)(key / 32) * 32;
					Integer startNumberInt = new Integer (startNumber);
					
					if (!targetLevel.equals("")) {
						this.sendingExtended.put(keyStr,targetLevel);
					} else {
						if (!this.sendingExtended.containsKey(keyStr) )
							this.sendingExtended.put(keyStr,"");
					}
					//if (immediate && ((new Date().getTime() - lastSentTime ) > 3000)) {
					if (immediate) {
						sendLevelMMIQuery(appCode,startNumber);
						logger.log (Level.FINEST,"Sending level MMI query for App="+appCode + " Start=" + startNumber);
					} else {
						addToLevelMMIQueue(appCode,startNumberInt);
					}
				}
				else {
					model.sendOutput (keyStr,"on","100",user);
				}
			}
		} catch (ClassCastException ex) {
			logger.log (Level.WARNING,"Cbus extended Level MMI requested for a non-bus object. Key:" + keyStr + " App:" + appCode + " " + ex.getMessage());
		}

	}
}
