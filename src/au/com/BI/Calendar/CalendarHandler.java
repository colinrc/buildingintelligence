/*
 * Created on Apr 13, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Calendar;

import java.util.*;

import au.com.BI.Macro.MacroHandler;
import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandQueue;

import au.com.BI.User.*;
import java.util.logging.*;

import org.quartz.*;

/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class CalendarHandler {
	/**
	 * 
	 */
	protected String fileName = "";
	protected String calendarFileName = "";
	protected Logger logger;
	protected CommandQueue commandList = null;
	protected EventCalendar eventCalendar = null;
	protected Map<String, String> calendar_message_params;
    protected Cache cache = null;
    MacroHandler macroHandler = null;
                
	public CalendarHandler() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	

	public void clearAll (boolean integrator) {

            if (!integrator){
            	eventCalendar.clear();
            }
	}
	

	public void setCommandList (CommandQueue commandList){
		this.commandList = commandList;
	}
	
	
	public void setCalendarFileName (String fileName){
		this.calendarFileName = fileName;
	}

	public boolean readCalendarFile() {
		eventCalendar.setCalendar_message_params(calendar_message_params) ;
		return eventCalendar.readCalendarFile(false);
	}
	
	public boolean cleanCalendarFile() {
		eventCalendar.setCalendar_message_params(calendar_message_params) ;
		if ( eventCalendar.readCalendarFile(true)) {
			eventCalendar.saveCalendarFile();
			return true;
		}
		return false;
		
	}
	
    /**
     * @return Returns the eventCalendar.
     */
    public EventCalendar getEventCalendar() {
        return eventCalendar;
    }
    
    public void startCalendar (User user) throws SchedulerException {
            eventCalendar = new EventCalendar (macroHandler, user);
            eventCalendar.setFileName(this.calendarFileName);
            eventCalendar.setCommandList(commandList);
            /* if (!eventCalendar.readCalendarFile() && logger!= null) {
                    logger.log (Level.SEVERE,"Could not read calendar file");
            } */
    }

    public Map<String, String> getCalendar_message_params() {
		return calendar_message_params;
	}

	public void setCalendar_message_params(Map<String, String> calendar_message_params) {
		this.calendar_message_params = calendar_message_params;
	}

	public CommandQueue getCommandList() {
		return commandList;
	}

	public Cache getCache() {
		return cache;
	}

	public void setCache(Cache cache) {
		this.cache = cache;
	}


	public MacroHandler getMacroHandler() {
		return macroHandler;
	}


	public void setMacroHandler(MacroHandler macroHandler) {
		this.macroHandler = macroHandler;
	}
}
