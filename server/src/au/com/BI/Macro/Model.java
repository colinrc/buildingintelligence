/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Macro;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.User.*;

import java.util.logging.*;

import org.jdom.Element;

import au.com.BI.CustomInput.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Flash.*;

public class Model extends SimplifiedModel implements DeviceModel {

	protected String STX;
	protected String ETX;
	protected String parameter;
	protected CustomInput deviceThatMatched;
	
	public Model () {
		super();
		this.setName("Macro");
        this.setAutoReconnect(false);
	}

	
	public void doClientStartup(CommandQueue commandQueue, long targetFlashDeviceID, long serverID){
		if (macroHandler != null){
		    ClientCommand clientCommand = new ClientCommand();
		    clientCommand.setFromElement (macroHandler.get("",false,false));
		    clientCommand.setKey ("CLIENT_SEND");
		    clientCommand.setTargetDeviceID(targetFlashDeviceID);
			commandQueue.add(clientCommand);
		}
	};

	public boolean isConnected () {
		return true;
	}
	

	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		configHelper.wholeKeyChecked(keyName);

		if (keyName.equals ("MACRO") ){
			logger.log (Level.FINER,"Flash sent macro comamnd");
			return true;
		}
		else {

			return false;
		}
	}

	public void doCommand (CommandInterface command) throws CommsFail
	{
	    String keyName = command.getKey();
		if (keyName.equals ("MACRO")){
		    doMacroItem (command);
		}
	}

    public boolean removeModelOnConfigReload () {
    	return false;
    }

	public void doMacroItem (CommandInterface commandIntf) throws CommsFail {
	    ClientCommand command = (ClientCommand)commandIntf;
	    boolean doListUpdate = false;
	    String macroName = "";
	    String pureMacroName = "";

	    try {
	        command = (ClientCommand)commandIntf;
	    } catch (ClassCastException e) {
	        logger.log (Level.WARNING,"Error has occured in event system - recovering.");
	    }
		ClientCommand clientCommand = null;

		String theWholeKey = command.getKey();
		DeviceType device = configHelper.getOutputItem(theWholeKey);

		logger.log (Level.FINER, "Received macro command");

		pureMacroName = command.getExtraInfo();
		if (command.getExtra2Info().equals("")){
			macroName = pureMacroName;
		} else {
			macroName = pureMacroName + ":" + command.getExtra2Info();			
		}
		
		String commandStr = command.getCommandCode();
		User currentUser = command.getUser();
		if (commandStr.equals("run")) {
			macroHandler.run(macroName,currentUser,command);
			logger.log (Level.FINER, "Run macro " + macroName);
			doListUpdate = false;
		}
		if (commandStr.equals("abort")) {
			macroHandler.abort(macroName,currentUser);
			logger.log (Level.FINER, "Aborting macro " + command.getExtraInfo());
			doListUpdate = false;
		}
		if (commandStr.equals("stop")) {
			macroHandler.complete(macroName,currentUser);
			logger.log (Level.FINER, "Stopping macro " + macroName);
			doListUpdate = false;
		}
		if (commandStr.equals("complete")) {
			macroHandler.complete(macroName,currentUser);
			logger.log (Level.FINER, "Aborting macro " + macroName);
			doListUpdate = false;
		}

		if (commandStr.equals("save")) {
			macroHandler.put(pureMacroName,command.getMessageFromFlash(),false);
			logger.log (Level.FINER, "Saving new macro " + pureMacroName);
			doListUpdate = true;
		}
        if (commandStr.equals("getContents")) {
        	// Contents is always for the pure macro name without zone appended.
			Element macro = macroHandler.getContents(pureMacroName,false);
			logger.log (Level.FINER, "Fetching contents for macro " + pureMacroName);
			doListUpdate = false;
                        
			if (macro == null)
				logger.log (Level.WARNING, "Could not retrieve macro list");
			else {
			    clientCommand = new ClientCommand();
			    clientCommand.setFromElement (macro);
			    clientCommand.setKey ("CLIENT_SEND");
				clientCommand.setTargetDeviceID(command.getOriginatingID());
			}
		}
		if (commandStr.equals("saveList")) {
			macroHandler.saveMacroList(command.getMessageFromFlash(),false);
			macroHandler.readMacroFile(false);
			logger.log (Level.FINER, "Saving macro list" );
			doListUpdate = true;
		}
		if (commandStr.equals("delete")) {
        	// Delete is always for the pure macro name without zone appended.
			macroHandler.delete(pureMacroName,currentUser,false);
			logger.log (Level.FINER, "Deleting macro " + pureMacroName);
			macroName = "";
			doListUpdate = true;
		}
		if (commandStr.equals("getList")) {
			logger.log (Level.FINER, "Fetching macro list");
		    Element macro = macroHandler.get(command.getExtraInfo(),false,false);

			if (macro == null)
				logger.log (Level.WARNING, "Could not retrieve macro list");
			else {
			    clientCommand = new ClientCommand();
			    clientCommand.setFromElement (macro);
			    clientCommand.setKey ("CLIENT_SEND");
			    clientCommand.setDisplayName ("MACRO");
				clientCommand.setTargetDeviceID(command.getOriginatingID());
			}
		}
		if (doListUpdate) {
            logger.log (Level.FINER, "Fetching macro list");
		    Element macro = macroHandler.get(macroName,false,false);

                    if (macro == null)
                            logger.log (Level.WARNING, "Could not retrieve macro list");
                    else {
                        clientCommand = new ClientCommand();
                        clientCommand.setFromElement (macro);
                        clientCommand.setKey ("CLIENT_SEND");
                        clientCommand.setDisplayName ("MACRO");
                            clientCommand.setTargetDeviceID(0);
                    }
		}
		if (clientCommand != null) {
			synchronized (cache){
				cache.setCachedCommand("MACRO", clientCommand,false);
			}
			commandQueue.add(clientCommand);
		}
	}
	
	public void sendListToClient () {
            logger.log (Level.FINER, "Fetching macro list");
	    Element macro = macroHandler.get("",false,false);

            if (macro == null)
                    logger.log (Level.WARNING, "Could not retrieve macro list");
            else {
                ClientCommand clientCommand = new ClientCommand();
                clientCommand.setFromElement (macro);
                clientCommand.setKey ("CLIENT_SEND");
                clientCommand.setTargetDeviceID(0);
    			synchronized (cache){
    				cache.setCachedCommand("MACRO", clientCommand,false);
    			}
                 commandQueue.add(clientCommand);
            }
	}

	

	public void closeComms () {
	    macroHandler.abortAll();
	}

	public void attatchComms(CommandQueue commandList)
	throws ConnectionFail  {}

}
