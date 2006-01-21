/*
 * Created on Jul 18, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.Comms;

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
protected LinkedList commandQueue;	
protected LinkedList sentQueue;
protected int transmitMessageOnBytes = 0;

	public BaseComms () {
		commandQueue = new LinkedList();
		sentQueue = new LinkedList();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public void setTransmitMessageOnBytes(int numberBytes) {
	    transmitMessageOnBytes = numberBytes;
	}	

	public void clearCommandQueue () {
		synchronized (commandQueue){
			commandQueue.clear();
		}
		synchronized (sentQueue){
			sentQueue.clear();
		}
		this.waitingForFeedback = false;
	}
	
	public boolean isCommandQueueEmpty (){
		return commandQueue.isEmpty();
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
					if (item.key.equals (key)){
					    sentListIter.remove();
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
		if (!commandQueue.isEmpty())
			return (CommsCommand)commandQueue.getFirst();
		else
			return null;
	}

	public CommsCommand getLastCommandInQueue (){
		if (!commandQueue.isEmpty())
			return (CommsCommand)commandQueue.getLast();
		else return null;
	}
	
	public void addCommandToQueue (CommsCommand command) throws CommsFail {
		synchronized (commandQueue){
			commandQueue.add(command);
		}
	    if (sentQueue.isEmpty()) {
		// Nothing currently in the queue waiting so start it rolling
	        sendNextCommand();
	    } else {
			if ((System.currentTimeMillis() - this.timeOfLastCommand) > CommDevice.DelayUntilCommandRepeat) {
				logger.log(Level.INFO,"Commands not actioned in " + CommDevice.DelayUntilCommandRepeat + " ms, repeating");
				this.resendAllSentCommands();
			}
	    }
	}

	
	public void sendCommandAndKeepInSentQueue (CommsCommand command) throws CommsFail {
		this.addCommandToSentQueue(command);
		if (command.hasByteArray()) {
			if (logger.isLoggable(Level.FINEST)){
				logger.log (Level.FINEST,"Sending command to comms port "+ Utility.allBytesToHex(command.getCommandBytes()));
			}
			this.sendString(command.getCommandBytes());
		}
		else {
			logger.log (Level.FINEST,"Sending command to comms port " + (String)command.getCommandCode());
			this.sendString(command.getCommandCode());
		}
			
	}

	public void removeFirstCommandInQueue () {
		synchronized (commandQueue){
			if (!commandQueue.isEmpty()) commandQueue.removeFirst();
			if (commandQueue.isEmpty()) this.waitingForFeedback = false;
		}
	}
	
	public void 	removeAllCommands (int actionType) {
		synchronized (commandQueue){
		    Iterator commandList = commandQueue.iterator();
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
			if (logger.isLoggable(Level.FINEST)){
				logger.log (Level.FINEST,"Sending command to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
			}
			sendString(nextCommand.getCommandBytes());
		} else {
			logger.log (Level.FINEST,"Sending command to comms port " + (String)nextCommand.getCommandCode());
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
					logger.log(Level.FINER,"Comms command was sent 3 times without reply, deleting");
					eachSentCommand.remove();
				} else {
					if (nextCommand.hasByteArray()) {
						if (logger.isLoggable(Level.FINEST)){
							logger.log (Level.FINEST,"Resending command to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
						}
						sendString(lastCommand.getCommandBytes());
					} else {
						logger.log (Level.FINEST,"ReSending command to comms port " + (String)lastCommand.getCommandCode());
						sendString((String)lastCommand.getCommandCode());
					}
				}
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
			logger.log (Level.FINEST,"Repeating command to comms port ");
			sendString(nextCommand.getCommandBytes());
		} else {
			logger.log (Level.FINEST,"Repeating command to comms port " + (String)nextCommand.getCommandCode());
			sendString((String)nextCommand.getCommandCode());
		}
		return true;
		
	}


	public boolean sendNextCommand(int actionType, String key) throws CommsFail{
	    boolean foundCommand = false;
		if (isCommandQueueEmpty()) return false;
	
		synchronized (commandQueue){
			Iterator commandQueueList = commandQueue.iterator();
			
			while (!foundCommand && commandQueueList.hasNext()) {
				nextCommand = (CommsCommand)commandQueueList.next();
				if (nextCommand.getActionType() == actionType && nextCommand.getKey().equals(key)) {
				    commandQueueList.remove();
					
					if (nextCommand.isKeepForHandshake())
					    this.addCommandToSentQueue(nextCommand);
					
					timeOfLastCommand = System.currentTimeMillis();
					waitingForFeedback = true;
					if (nextCommand.hasByteArray()) {
						if (logger.isLoggable(Level.FINEST)){
							logger.log (Level.FINEST,"Sending command to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
						}
						sendString(nextCommand.getCommandBytes());
					} else {
						logger.log (Level.FINEST,"Sending command to comms port " + (String)nextCommand.getCommandCode());
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
	
		synchronized (commandQueue){
			Iterator commandQueueList = commandQueue.iterator();
			
			while (!foundCommand && commandQueueList.hasNext()) {
				nextCommand = (CommsCommand)commandQueueList.next();
				if (nextCommand.getActionType() == actionType) {
				    commandQueueList.remove();
					
					if (nextCommand.isKeepForHandshake())
					    this.addCommandToSentQueue(nextCommand);
					
					timeOfLastCommand = System.currentTimeMillis();
					waitingForFeedback = true;
					if (nextCommand.hasByteArray()) {
						if (logger.isLoggable(Level.FINEST)){
							logger.log (Level.FINEST,"Sending command to comms port "+ Utility.allBytesToHex(nextCommand.getCommandBytes()));
						}
						sendString(nextCommand.getCommandBytes());
					} else {
						logger.log (Level.FINEST,"Sending command to comms port " + (String)nextCommand.getCommandCode());
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
	
	
	public void sendString (String message) throws CommsFail {
		logger.log (Level.SEVERE,"Send String in Base Comms was not overwritten by extending class.");
		};

	public void sendString (byte[] message) throws CommsFail {
		logger.log (Level.SEVERE,"Send String in Base Comms was not overwritten by extending class.");
	};

}
