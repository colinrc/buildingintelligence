/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Macro;

import au.com.BI.Calendar.*;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.User.*;

import java.util.*;
import java.util.logging.*;

import org.jdom.Element;

import au.com.BI.CustomInput.*;
import au.com.BI.Flash.*;

public class Model extends BaseModel implements DeviceModel {

	protected String STX;
	protected String ETX;
	protected String parameter;
	protected CustomInput deviceThatMatched;
	protected CalendarEventFactory calendarEventFactory;
	
	public Model () {
		super();
		this.setName("Macro");
		this.setCalendarEventFactory (new CalendarEventFactory());
	}

	public void setMacroHandler (MacroHandler macroHandler) {
		calendarEventFactory.setMacroHandler(macroHandler);
		super.setMacroHandler(macroHandler);
	}
	
	public void doClientStartup(java.util.List commandQueue, long targetFlashDeviceID, long serverID){
		if (macroHandler != null){
		    ClientCommand clientCommand = new ClientCommand();
		    clientCommand.setFromElement (macroHandler.get("",false,false));
		    clientCommand.setKey ("CLIENT_SEND");
		    clientCommand.setTargetDeviceID(targetFlashDeviceID);
			synchronized (commandQueue){
				commandQueue.add(clientCommand);
			}
		
			EventCalendar eventCalendar = macroHandler.getEventCalendar();
			if (eventCalendar != null){
			    ClientCommand calCommand = new ClientCommand();
			    calCommand.setFromElement (eventCalendar.get(""));
			    calCommand.setKey ("CLIENT_SEND");
			    calCommand.setTargetDeviceID(targetFlashDeviceID);
				synchronized (commandQueue){
					commandQueue.add(calCommand);
				}
			}
		}
	};

	public boolean isConnected () {
		return true;
	}
	
	public void finishedReadingConfig () {

	}

	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		configHelper.wholeKeyChecked(keyName);

		if (keyName.equals ("MACRO") || keyName.equals ("CALENDAR")){
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
		if (keyName.equals ("CALENDAR")){
		    doCalendarItem (command);
		}
	}

    public boolean removeModelOnConfigReload () {
    	return false;
    }

	public void doMacroItem (CommandInterface commandIntf) throws CommsFail {
	    ClientCommand command = (ClientCommand)commandIntf;
	    boolean doListUpdate = false;

	    try {
	        command = (ClientCommand)commandIntf;
	    } catch (ClassCastException e) {
	        logger.log (Level.WARNING,"Error has occured in event system - recovering.");
	    }
		ClientCommand clientCommand = null;

		String theWholeKey = command.getKey();
		ArrayList deviceList = (ArrayList)configHelper.getOutputItem(theWholeKey);

		logger.log (Level.FINER, "Received macro command");

		String commandStr = command.getCommandCode();
		User currentUser = command.getUser();
		if (commandStr.equals("run")) {
			macroHandler.run((String)command.getExtraInfo(),currentUser,command);
			logger.log (Level.FINER, "Run macro " + command.getExtraInfo());
			doListUpdate = false;
		}
		if (commandStr.equals("abort")) {
			macroHandler.abort((String)command.getExtraInfo(),currentUser);
			logger.log (Level.FINER, "Aborting macro " + command.getExtraInfo());
			doListUpdate = false;
		}
		if (commandStr.equals("stop")) {
			macroHandler.complete((String)command.getExtraInfo(),currentUser);
			logger.log (Level.FINER, "Stopping macro " + command.getExtraInfo());
			doListUpdate = false;
		}
		if (commandStr.equals("complete")) {
			macroHandler.complete((String)command.getExtraInfo(),currentUser);
			logger.log (Level.FINER, "Aborting macro " + command.getExtraInfo());
			doListUpdate = false;
		}

		if (commandStr.equals("save")) {
			macroHandler.put((String)command.getExtraInfo(),command.getMessageFromFlash(),false);
			logger.log (Level.FINER, "Saving new macro " + command.getExtraInfo());
			doListUpdate = true;
		}
                if (commandStr.equals("getContents")) {
			Element macro = macroHandler.getContents((String)command.getExtraInfo(),false);
			logger.log (Level.FINER, "Fetching contents for macro " + command.getExtraInfo());
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
			macroHandler.delete((String)command.getExtraInfo(),currentUser,false);
			logger.log (Level.FINER, "Deleting macro " + command.getExtraInfo());
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
				clientCommand.setTargetDeviceID(command.getOriginatingID());
			}
		}
		if (doListUpdate) {
                    logger.log (Level.FINER, "Fetching macro list");
		    Element macro = macroHandler.get("",false,false);

                    if (macro == null)
                            logger.log (Level.WARNING, "Could not retrieve macro list");
                    else {
                        clientCommand = new ClientCommand();
                        clientCommand.setFromElement (macro);
                        clientCommand.setKey ("CLIENT_SEND");
                            clientCommand.setTargetDeviceID(0);
                    }
		}
		if (clientCommand != null) {

			synchronized (this.commandQueue){
				commandQueue.add(clientCommand);
			}
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

                synchronized (this.commandQueue){
                        commandQueue.add(clientCommand);
                        commandQueue.notifyAll();
                }
            }
	}

	public void doCalendarItem (CommandInterface commandIntf) {
	    ClientCommand command = (ClientCommand)commandIntf;
	    boolean doListUpdate = false;
            long targetDeviceID = 0;
            
	    try {
	        command = (ClientCommand)commandIntf;
	    } catch (ClassCastException e) {
	        logger.log (Level.WARNING,"Error has occured in calendar system - recovering.");
	    }
		ClientCommand clientCommand = null;

		String commandStr = command.getCommandCode();
		String eventID = "";
                String extra = command.getExtraInfo();
		User currentUser = command.getUser();
		EventCalendar eventCalendar = macroHandler.getEventCalendar();
		boolean successfullyParsed = true;

		logger.log (Level.FINER, "Received calendar command");


		if (commandStr.equals("saveAll")) {
			logger.log (Level.FINER, "Received new event calendar");
			eventCalendar.clear();

			Element original_message = command.getMessageFromFlash();
			if (original_message == null) return;
			Element calendar = original_message.getChild("events");
			successfullyParsed = eventCalendar.parseCalendar (calendar);
			if (successfullyParsed) {
				eventCalendar.saveCalendarFile();
				logger.log (Level.FINE, "Activating new events calendar");
                                doListUpdate = true; // make sure all calendars are updated
			}
			else {
                            logger.log (Level.WARNING, "Events calendar parse failed");
			    clientCommand = null;
			}
		}

		if (commandStr.equals("getEvents")) {
			logger.log (Level.FINER, "Listing all calendar entries to the client.");
                        doListUpdate = true;
                        eventID = "";
                        targetDeviceID = command.getOriginatingID();
		}

		if (commandStr.equals("save")) {
			logger.log (Level.FINER, "Adding new events to the calendar.");

			Element original_message = command.getMessageFromFlash();
			if (original_message == null) return;

			List elements = original_message.getChildren();
			Iterator eachEvent = elements.iterator();
			while (eachEvent.hasNext()) {
			    Element nextEvent = (Element)eachEvent.next();
			    try {
			    	CalendarEventEntry calendarEventEntry = calendarEventFactory.createEvent(nextEvent);
			    	if (calendarEventEntry.isStillActive()){
			    		eventCalendar.addEvent (calendarEventEntry);
                                        eventID = eventID +','+ calendarEventEntry.getId();
			    	}
                                if (eventID.charAt(0) == ',')eventID = eventID.substring(1);
                 
			    	eventCalendar.addEventXMLToStore (calendarEventEntry.getId(),nextEvent);
			    } catch (CalendarException ex){
			    	
			    }
			}
			eventCalendar.saveCalendarFile();
			doListUpdate = true;
		}

		if (commandStr.equals("delete") && !extra.equals("")) {
			logger.log (Level.FINER, "Deleting event : " + extra);
			eventCalendar.deleteEvent (extra);
			eventCalendar.saveCalendarFile();
                        eventID = "";
			doListUpdate = true;
		}

		if (commandStr.equals("clear")) {
			logger.log (Level.FINER, "Clearing all events in the calendar");
			eventCalendar.clear();
			eventCalendar.saveCalendarFile();
                        eventID = "";
			doListUpdate = true;
		}

		if (doListUpdate) {
			logger.log (Level.FINER, "Listing updated calendar entries to the client.");
			Element eventList = eventCalendar.get(eventID);
			if (eventList == null)
				logger.log (Level.WARNING, "Could not retrieve event list");
			else {
			    clientCommand = new ClientCommand();
			    clientCommand.setFromElement (eventList);
				clientCommand.setTargetDeviceID(0);
			    clientCommand.setKey ("CLIENT_SEND");
			}
		}
		if (clientCommand != null) {

			synchronized (this.commandQueue){
				commandQueue.add(clientCommand);
                                commandQueue.notifyAll();
			}
		}

	}



	public void closeComms () {
	    macroHandler.abortAll();
	}

	public void attatchComms(List commandList)
	throws ConnectionFail  {}

	public void setCalendarEventFactory(CalendarEventFactory calendarEventFactory) {
		this.calendarEventFactory = calendarEventFactory;
	}
}
