/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Calendar;

import au.com.BI.Command.*;
import au.com.BI.Macro.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.User.*;

import java.util.*;
import java.util.logging.*;

import org.jdom.Element;

import au.com.BI.CustomInput.*;
import au.com.BI.Flash.*;

public class Model extends SimplifiedModel implements DeviceModel {

	protected String STX;
	protected String ETX;
	protected String parameter;
	protected CustomInput deviceThatMatched;
	protected CalendarEventFactory calendarEventFactory;
	protected CalendarHandler calendarHandler;
	
	public Model () {
		super();
		this.setName("Calendar");
		this.setCalendarEventFactory (new CalendarEventFactory());
		calendarHandler = new CalendarHandler();
        this.setAutoReconnect(false);
	}

	public void setMacroHandler (MacroHandler macroHandler) {
		calendarEventFactory.setMacroHandler(macroHandler);
		calendarHandler.setMacroHandler(macroHandler);
		super.setMacroHandler(macroHandler);
	}
	
	public void doClientStartup(CommandQueue commandQueue, long targetFlashDeviceID, long serverID){
		if (calendarHandler != null){
			EventCalendar eventCalendar = calendarHandler.getEventCalendar();
			if (eventCalendar != null){
			    ClientCommand calCommand = new ClientCommand();
			    calCommand.setFromElement (eventCalendar.get(""));
			    calCommand.setKey ("CLIENT_SEND");
			    calCommand.setTargetDeviceID(targetFlashDeviceID);
					commandQueue.add(calCommand);
			}
		}
	};

	public boolean isConnected () {
		return true;
	}
	

	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		configHelper.wholeKeyChecked(keyName);

		if (keyName.equals ("CALENDAR")){
			logger.log (Level.FINER,"Flash sent calendar comamnd");
			return true;
		}
		else {

			return false;
		}
	}

	public void doCommand (CommandInterface command) throws CommsFail
	{
	    String keyName = command.getKey();

		if (keyName.equals ("CALENDAR")){
		    doCalendarItem (command);
		}
	}

    public boolean removeModelOnConfigReload () {
    	return false;
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
		EventCalendar eventCalendar = calendarHandler.getEventCalendar();
		boolean successfullyParsed = true;

		logger.log (Level.FINER, "Received calendar command");


		if (commandStr.equals("saveAll")) {
			logger.log (Level.FINER, "Received new event calendar");
			eventCalendar.clear();

			Element original_message = command.getMessageFromFlash();
			if (original_message == null) return;
			Element calendar = original_message.getChild("events");
			successfullyParsed = eventCalendar.parseCalendar (calendar,false);
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
			    	if (calendarEventEntry.isStillActive()  && calendarEventEntry.isActive()){
			    		eventCalendar.addEvent (calendarEventEntry);
			    	}
			    	eventID = eventID +','+ calendarEventEntry.getId();
                   if (eventID.length() > 0 && eventID.charAt(0) == ',')eventID = eventID.substring(1);
                 
			    	eventCalendar.addEventXMLToStore (calendarEventEntry.getId(),nextEvent);
			    } catch (CalendarException ex){
			    	logger.log (Level.WARNING,ex.getMessage());
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
			synchronized (cache){
				clientCommand.setDisplayName("CALENDAR");
				cache.setCachedCommand("CALENDAR", clientCommand,false);
			}
			commandQueue.add(clientCommand);
		}

	}


	public void attatchComms(CommandQueue commandList)
	throws ConnectionFail  {}

	public void setCalendarEventFactory(CalendarEventFactory calendarEventFactory) {
		this.calendarEventFactory = calendarEventFactory;
	}

	public CalendarHandler getCalendarHandler() {
		return calendarHandler;
	}

	public void setCalendarHandler(CalendarHandler calendarHandler) {
		this.calendarHandler = calendarHandler;
	}
}
