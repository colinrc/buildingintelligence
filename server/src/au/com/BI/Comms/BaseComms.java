/*
 * Created on Jul 18, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.Comms;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Iterator;
import au.com.BI.Util.*;
import java.util.LinkedList;
import java.util.logging.*;

/**
 * @author colinc
 */

public class BaseComms {
	
protected CommsCommand nextCommand = null;
protected Logger logger;
protected boolean waitingForFeedback = false;
protected long timeOfLastCommand = 0;
protected LinkedList <CommsCommand>toSendQueue;	
protected LinkedList <CommsCommand>sentQueue;
protected int transmitMessageOnBytes = 0;
public int interCommandInterval = 0;
protected OutputStream os;
protected InputStream is;	
protected boolean portOpen = false;
protected CommsSend commsSend = null;
protected CommsGroup commsGroup = null;
protected String modelName = "";

	public BaseComms () {
		toSendQueue = new LinkedList<CommsCommand>();
		sentQueue = new LinkedList<CommsCommand>();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public void setTransmitMessageOnBytes(int numberBytes) {
	    transmitMessageOnBytes = numberBytes;
	}	

	public void clearCommandQueue () {
		synchronized (toSendQueue){
			toSendQueue.clear();
		}
		synchronized (sentQueue){
			sentQueue.clear();
		}
		this.waitingForFeedback = false;
	}
	
	public boolean isCommandQueueEmpty (){
		return toSendQueue.isEmpty();
	}

	public boolean isCommandSentQueueEmpty (){
		return sentQueue.isEmpty();
	}
	
	public CommsCommand getFirstCommandInSentQueue (){
		if (!sentQueue.isEmpty())
			return (CommsCommand)sentQueue.getFirst();
		else
			return null;
	}

	public CommsCommand getLastCommandInSentQueue (){
		if (!sentQueue.isEmpty())
			return (CommsCommand)sentQueue.getLast();
		else return null;
	}
	
	public CommsCommand getLastCommandSent () {
		// return nextCommand;
		return getLastCommandInSentQueue();
	}
	

	
	/**
	 * Clears a command from the sent queue
	 * @param key If empty or null the last command sent is removed else the key is searched for in the sent queue
	 * @return success if the key is found or not specified
	 */
	public boolean acknowlegeCommand (String key) {
		boolean returnCode = false;
		if (key != null && !key.equals("")) {
			synchronized (sentQueue){
				Iterator sentListIter = sentQueue.iterator();
				while (sentListIter.hasNext() && !returnCode) {
					CommsCommand item = (CommsCommand)sentListIter.next();
					if (item.actionCode.equals (key)){
					    sentListIter.remove();
					    if (logger.isLoggable(Level.FINER)){
						logger.log(Level.FINER,"Received acknowledgement for key " + key + " time diff (ms) " + 
						    (System.currentTimeMillis() - item.getCreationDate()));
					    }
					    returnCode = true;
					}
				}
			}
		}
		else {
			this.removeFirstCommandInSentQueue();
			returnCode = true;
		}
		return returnCode;
	}
	
	/**
	 * Clears a command from the sent queue
	 * @param key If empty or null the last command sent is removed else the key is searched for in the sent queue
	 * @return success if the key is found or not specified
	 */
	public boolean acknowlegeCommand (int actionType,String key) {
		if (key != null && !key.equals("")) {
			synchronized (sentQueue){
				Iterator sentListIter = sentQueue.iterator();
				while (sentListIter.hasNext()) {
					CommsCommand item = (CommsCommand)sentListIter.next();
					if (item.getActionType() == actionType &&  item.getActionCode().equals (key)){
					    sentListIter.remove();
					    if (logger.isLoggable(Level.FINER)){
						logger.log(Level.FINER,"Received acknowledgement for key " + key + " time diff (ms) " + 
						    (System.currentTimeMillis() - item.getCreationDate()));
					    }
					    return true;
					}
				}
			}
			return false;
		}
		else {
			this.removeFirstCommandInSentQueue();
			return true;
		}
	}

	public boolean acknowlegeCommand (int actionType) {
		boolean returnCode = false;
		synchronized (sentQueue){
	
			Iterator sentListIter = sentQueue.iterator();
			while (sentListIter.hasNext()) {
				CommsCommand item = (CommsCommand)sentListIter.next();
				if (item.getActionType() == actionType ){
				    sentListIter.remove();
				    if (logger.isLoggable(Level.FINER)){
					logger.log(Level.FINER,"Received acknowledgement for action type " + actionType + " time diff (ms) " + 
					    (System.currentTimeMillis() - item.getCreationDate()));
				    }
				    returnCode = true;
				}
			}
		}
		return returnCode;
	}
	
	public void removeFirstCommandInSentQueue () {
		synchronized (sentQueue){
			if (!sentQueue.isEmpty()) sentQueue.removeFirst();
			if (sentQueue.isEmpty()) this.waitingForFeedback = false;
		}
	}
	
	
	public void addCommandToSentQueue (CommsCommand command) throws CommsFail {
		synchronized (sentQueue){
			sentQueue.add(command);
		}
	}
	
	public CommsCommand getFirstCommandInQueue (){
		if (!toSendQueue.isEmpty())
			return (CommsCommand)toSendQueue.getFirst();
		else
			return null;
	}

	public CommsCommand getLastCommandInQueue (){
		if (!toSendQueue.isEmpty())
			return (CommsCommand)toSendQueue.getLast();
		else return null;
	}
	
	public void addCommandToQueue (CommsCommand command) throws CommsFail {
		synchronized (toSendQueue){
			toSendQueue.add(command);
			logger.finest("Queueing command " + command.getActionCode());
		}
	    if (sentQueue.isEmpty()) {
		// Nothing currently in the queue waiting so start it rolling
	        sendNextCommand();
	    } else {
	    	if (logger.isLoggable(Level.FINEST)){
	    		String sentKeySet = "";
		    	for (CommsCommand i: sentQueue){
		    		sentKeySet +=  i.actionCode + ":";
		    	}
		    	logger.log (Level.FINEST,"Items in sent queue : " + sentKeySet);
	    	}
			if ((System.currentTimeMillis() - this.timeOfLastCommand) > CommDevice.DelayUntilCommandRepeat) {
				logger.log(Level.INFO,"Commands not actioned in " + CommDevice.DelayUntilCommandRepeat + " ms, repeating. Time since request " + Long.toString(System.currentTimeMillis() - this.timeOfLastCommand)   );
				this.resendAllSentCommands();
			}
	    }
	}

	
	public void sendCommandAndKeepInSentQueue (CommsCommand command) throws CommsFail {
		this.addCommandToSentQueue(command);
		if (command.hasByteArray()) {
			if (logger.isLoggable(Level.FINER)){
				logger.log (Level.FINER,"Sending command at time " + System.currentTimeMillis() + " lag from queue ms " + (System.currentTimeMillis() - command.getCreationDate()) + " to comms port "+ Utility.allBytesToHex(command.getCommandBytes()));
			}
			this.sendString(command.getCommandBytes());
		}
		else {
		    if (logger.isLoggable(Level.FINER)){
			logger.log (Level.FINER,"Sending command at time " + System.currentTimeMillis() + " lag from queue ms " + (System.currentTimeMillis() - command.getCreationDate()) + " to comms port " + (String)command.getCommandCode());
		    }
		    this.sendString(command.getCommandCode());
		}
			
	}

	public void removeFirstCommandInQueue () {
		synchronized (toSendQueue){
			if (!toSendQueue.isEmpty()) toSendQueue.removeFirst();
			if (toSendQueue.isEmpty()) this.waitingForFeedback = false;
		}
	}
	
	public void 	removeAllCommands (int actionType) {
		synchronized (toSendQueue){
		    Iterator commandList = toSendQueue.iterator();
		    while (commandList.hasNext()) {
		        CommsCommand command = (CommsCommand)commandList.next();
		        if (command.getActionType() == actionType) commandList.remove();
		    }
		}
	}

	public boolean sentQueueContainsCommand (int actionType, String key) {
		synchronized (sentQueue){
		    Iterator commandList = sentQueue.iterator();
		    while (commandList.hasNext()) {
		        CommsCommand command = (CommsCommand)commandList.next();
		        if (command.getActionType() == actionType && command.getKey().equals (key)) return true;
		    }
		}
	    return false;
	}
	
	public boolean sentQueueContainsCommand (int actionType) {
		synchronized (sentQueue){
		    Iterator commandList = sentQueue.iterator();
		    while (commandList.hasNext()) {
		        CommsCommand command = (CommsCommand)commandList.next();
		        if (command.getActionType() == actionType) return true;
		    }
		}
	    return false;
	}
	
	public boolean sendNextCommand() throws CommsFail{	
		if (isCommandQueueEmpty()) return true;
	
		nextCommand = (CommsCommand)getFirstCommandInQueue();
		this.removeFirstCommandInQueue();
		
		if (nextCommand.isKeepForHandshake())
		    this.addCommandToSentQueue(nextCommand);
		
		timeOfLastCommand = System.currentTimeMillis();
		waitingForFeedback = true;
		if (nextCommand.hasByteArray()) {
			if (logger.isLoggable(Level.FINER)){
				logger.log (Level.FINER,"Sending command at time " + timeOfLastCommand + " (lag from queue ms " + (timeOfLastCommand - nextCommand.getCreationDate()) + ") to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
			}
			sendString(nextCommand.getCommandBytes());
		} else {
		    	if (logger.isLoggable(Level.FINER)){
			    logger.log (Level.FINER,"Sending command at time " + timeOfLastCommand + " (lag from queue ms " + (timeOfLastCommand - nextCommand.getCreationDate()) + ") to comms port " + (String)nextCommand.getCommandCode());
			}
			sendString((String)nextCommand.getCommandCode());
		}
		return true;
	}
	

	public boolean resendAllSentCommands () throws CommsFail{
		if (this.isCommandSentQueueEmpty()) return false;
		
		synchronized (this.sentQueue){
			Iterator eachSentCommand = sentQueue.iterator();
			while (eachSentCommand.hasNext()){
				CommsCommand lastCommand = (CommsCommand)eachSentCommand.next();

				timeOfLastCommand = System.currentTimeMillis();
				waitingForFeedback = true;
				lastCommand.incRepeatCount();
				if (lastCommand.getRepeatCount() > 3) {
					logger.log(Level.INFO,"Comms command was sent 3 times without reply, deleting");
					eachSentCommand.remove();
				} else {
					if (nextCommand.hasByteArray()) {
						if (logger.isLoggable(Level.FINE)){
							logger.log (Level.FINE,"Resending command to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
						}
						sendString(lastCommand.getCommandBytes());
					} else {
					    	if (logger.isLoggable(Level.FINE)){
						    logger.log (Level.FINE,"ReSending command to comms port " + (String)lastCommand.getCommandCode());
						}
						sendString((String)lastCommand.getCommandCode());
					}
				}
				break; 
			}
		}
		
		return true;
	}

	public boolean repeatLastCommand () throws CommsFail{
		if (isCommandQueueEmpty()) return false;
		CommsCommand lastCommand = (CommsCommand)this.getLastCommandInSentQueue();
		
		timeOfLastCommand = System.currentTimeMillis();
		waitingForFeedback = true;
		if (nextCommand.hasByteArray()) {
			logger.log (Level.FINER,"Repeating command to comms port " + Utility.allBytesToHex(lastCommand.getCommandBytes()));
			sendString(lastCommand.getCommandBytes());
		} else {
			logger.log (Level.FINER,"Repeating command to comms port " + (String)lastCommand.getCommandCode());
			sendString((String)lastCommand.getCommandCode());
		}
		
		return true;
	}

	/**
	 * Clears a command from the sent queue
	 * @param key If empty or null the last command sent is removed else the key is searched for in the sent queue
	 * @return success if the key is found or not specified
	 */
	public CommsCommand getCommandInQueue (String key) {
		if (key != null && !key.equals("")) {
			synchronized (sentQueue){
				Iterator sentListIter = sentQueue.iterator();
				while (sentListIter.hasNext()) {
					CommsCommand item = (CommsCommand)sentListIter.next();
					if (item.key.equals (key)){
					    return item;
					}
				}
			}
			return null;
		} else {
			return null;
		}
	}
	
	public boolean repeatCommand (String key) throws CommsFail {
		if (isCommandQueueEmpty()) return false;
		CommsCommand nextCommand = (CommsCommand)this.getCommandInQueue(key);
		
		if (nextCommand == null) return false;
		
		timeOfLastCommand = System.currentTimeMillis();
		waitingForFeedback = true;
		if (nextCommand.hasByteArray()) {
			logger.log (Level.FINER,"Repeating command to comms port ");
			sendString(nextCommand.getCommandBytes());
		} else {
			logger.log (Level.FINER,"Repeating command to comms port " + (String)nextCommand.getCommandCode());
			sendString((String)nextCommand.getCommandCode());
		}
		return true;
		
	}


	public boolean sendNextCommand(int actionType, String key) throws CommsFail{
	    boolean foundCommand = false;
		if (isCommandQueueEmpty()) return false;
	
		synchronized (toSendQueue){
			Iterator commandQueueList = toSendQueue.iterator();
			
			while (!foundCommand && commandQueueList.hasNext()) {
				nextCommand = (CommsCommand)commandQueueList.next();
				if (nextCommand.getActionType() == actionType && nextCommand.getKey().equals(key)) {
				    commandQueueList.remove();
					
					if (nextCommand.isKeepForHandshake())
					    this.addCommandToSentQueue(nextCommand);
					
					timeOfLastCommand = System.currentTimeMillis();
					waitingForFeedback = true;
					if (nextCommand.hasByteArray()) {
						if (logger.isLoggable(Level.FINER)){
							logger.log (Level.FINER,"Sending command to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
						}
						sendString(nextCommand.getCommandBytes());
					} else {
						logger.log (Level.FINER,"Sending command to comms port " + (String)nextCommand.getCommandCode());
						sendString((String)nextCommand.getCommandCode());
					}
					foundCommand = true;
				}
			}
		}
		return true;
	}

	public boolean sendNextCommand(int actionType) throws CommsFail{
	    boolean foundCommand = false;
		if (isCommandQueueEmpty()) return true;
	
		synchronized (toSendQueue){
			Iterator commandQueueList = toSendQueue.iterator();
			
			while (!foundCommand && commandQueueList.hasNext()) {
				nextCommand = (CommsCommand)commandQueueList.next();
				if (nextCommand.getActionType() == actionType) {
				    commandQueueList.remove();
					
					if (nextCommand.isKeepForHandshake())
					    this.addCommandToSentQueue(nextCommand);
					
					timeOfLastCommand = System.currentTimeMillis();
					waitingForFeedback = true;
					if (nextCommand.hasByteArray()) {
						if (logger.isLoggable(Level.FINER)){
							logger.log (Level.FINER,"Sending command to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
						}
						sendString(nextCommand.getCommandBytes());
					} else {
						logger.log (Level.FINER,"Sending command to comms port " + (String)nextCommand.getCommandCode());
						sendString((String)nextCommand.getCommandCode());
					}
					foundCommand = true;
				}
			}
		}
		return true;
	}
	
	public boolean isWaitingForFeedback () {
		return waitingForFeedback;
	}
	
	public void gotFeedback() {
		waitingForFeedback = false;
	}	
	
	public int getInterCommandInterval() {
		return interCommandInterval;
	}

	public void setInterCommandInterval(int interCommandInterval) {
		this.interCommandInterval = interCommandInterval;
	}
	
	
	public void sendString (String message)
	{
		if (message == null){
			logger.log (Level.INFO,"A null message was attempted to be sent from the model " + this.getModelName());
		} else {
			logger.log (Level.FINER,"Sending string " + message);
			sendString (message.getBytes());
		}
	}

	public void sendString (byte[] message)
	{
		if (message == null){
			logger.log (Level.INFO,"A null message was attempted to be sent from the model " + this.getModelName());
		} else {
			if (logger.isLoggable(Level.FINER)){
				logger.log (Level.FINER,"Sending string " + message);
			}
			commsSend.toSend.add(message);
		}
	}

	public String getModelName() {
		return modelName;
	}

	public void setModelName(String modelName) {
		this.modelName = modelName;
	}

}
