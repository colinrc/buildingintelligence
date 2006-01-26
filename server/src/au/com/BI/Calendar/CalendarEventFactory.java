/*
 * Created on Oct 12, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.Calendar;

import java.util.*;

import org.quartz.*;

import org.jdom.*;
import org.jdom.input.SAXBuilder;
import java.util.logging.*;

import java.io.IOException;
import java.text.*;

import au.com.BI.Macro.MacroHandler;
import au.com.BI.User.*;


public class CalendarEventFactory {
    protected Map events = null;
    protected SimpleDateFormat df = null;
    protected SimpleDateFormat tf = null;
    protected SimpleDateFormat totalDayF = null;
    
	protected Logger logger;
	
    protected int recurrance;
    
    protected int dayStartOffset = 0;
    protected int weekStartOffset = 0;
    protected int monthStartOffset = 0;
    protected int yearStartOffset = 0;
    protected int recurranceIntervalCount = 1;

	protected MacroHandler macroHandler = null;
	protected User user = null;
	protected Map calendar_message_params;

    public CalendarEventFactory () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());

        totalDayF = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
        totalDayF.applyPattern("yyyy-MM-dd HH:mm:ss");

        df = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
        df.applyPattern("yyyy-MM-dd");

        tf = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
        tf.applyPattern("HH:mm:ss");
    }
	
	
    public CalendarEventEntry createEvent (Element nextEvent) throws CalendarException {
        boolean success = true;
        CalendarEventEntry returnVal = new CalendarEventEntry();

	    	String title = nextEvent.getAttributeValue("title"); 
	    	String eventType = nextEvent.getAttributeValue("eventType"); 
		if (eventType == null || eventType.equals ("")) {
			eventType = "once";
		}
	    	String description = nextEvent.getAttributeValue("description"); 
	    	if (description == null) description = "";
		String startDate = "";
		if (eventType.equals ("once")) {
	    		startDate = nextEvent.getAttributeValue("date"); 
		} else {
    			startDate = nextEvent.getAttributeValue("startDate"); 			
		}
	    	String endDate = nextEvent.getAttributeValue("endDate"); 
	    	String time  = nextEvent.getAttributeValue("time");
			String hours = "";
			String minutes = "";
			String seconds = "";				
	    	if (time == null || time.equals ("")) {
				time = "09:00:00";
				hours = "09";
				minutes = "00";
				seconds = "00";				
	    	}else {
				String timeParts[] = time.split(":");
				if (timeParts.length > 2) seconds = timeParts[2]; else seconds = "00";		
				if (timeParts.length > 1) minutes = timeParts[1]; else minutes = "00";		
				if (timeParts.length > 0) hours = timeParts[0]; else hours = "09";		

	    	}
	    	String totalStartDate = startDate + " " + time;
		String totalEndDate = endDate + " 23:59:59";
	    	String macroName  = nextEvent.getAttributeValue("macroName");
	    	String command = nextEvent.getAttributeValue("command");
	    	String extra = nextEvent.getAttributeValue("extra");
	    	String extra2 = nextEvent.getAttributeValue("extra2");
	    	String extra3 = nextEvent.getAttributeValue("extra3");

	    	String filter  = nextEvent.getAttributeValue("filter");
	    	String rawCronString = "";
	    	if (filter == null) filter = "";


	    	if (title == null || title.equals ("") ) {
	    		String errorMessage = "No Title was set for the event";
	    		logger.log(Level.WARNING,errorMessage);
	    	    throw new CalendarException (errorMessage);
	    	}
		
        Date startDateDecoded;
		if (startDate == null || startDate.equals ("")) {
			startDateDecoded = new Date();
		} else { 
	        try {
	            startDateDecoded = totalDayF.parse(totalStartDate);
	        } catch ( ParseException ex) {
	        	String errorMessage = "Could not parse event " + title + " start date. " + ex.getMessage();
	        	logger.log(Level.WARNING,errorMessage);
	    	    throw new CalendarException (errorMessage,ex);
	        }
		}
		
		Date endDateDecoded;
		if (endDate == null || endDate.equals ("")) {
			endDateDecoded = new Date();
			endDateDecoded.setYear(2999);
		} else {
	        try {
	            endDateDecoded = totalDayF.parse(totalEndDate);
	        } catch ( ParseException ex) {
	        	String errorMessage = "Could not parse event " + title + " end date. " + ex.getMessage();
	        	logger.log(Level.WARNING,errorMessage);
	    	    throw new CalendarException (errorMessage,ex);	        }
		}
		if (endDateDecoded.before( new Date())) {
			returnVal.setStillActive(false);
			return returnVal;
		}
        
		JobDetail jobDetail = new JobDetail(title, 
                Scheduler.DEFAULT_GROUP, // job group
                MacroEvent.class);        // the java class to execute
		
		
		JobDataMap map = jobDetail.getJobDataMap(); 
		map.put ("Title",title);
		map.put("MacroHandler",macroHandler);
		map.put("MacroName",macroName);
		map.put("command",command);
		map.put("extra",extra);
		map.put("extra2",extra2);
		map.put("extra3",extra3);
		map.put ("User", user);
		map.put ("Filter", filter);
		map.put ("Description",description);
		
		if (calendar_message_params != null) {
	        map.put ("Icon",calendar_message_params.get("ICON"));
			map.put ("AutoClose",calendar_message_params.get("AUTOCLOSE"));
			map.put ("HideClose",calendar_message_params.get("HIDECLOSE"));
		} else {
	        map.put ("Icon","");
			map.put ("AutoClose","AUTOCLOSE");
			map.put ("HideClose","HIDECLOSE");			
		}
		
		String daysOfWeek = "";
		String weekOfMonth = "";
		String month = "*";
		String recur = "";
		
        Element patternXML = nextEvent.getChild("pattern");
        if (patternXML != null) {

			
			recur = (String)patternXML.getAttributeValue("recur");
			if (recur != null  && !recur.equals ("") && !recur.equals ("1")) {
				recur = "#" + recur;
			} else {
				recur = "";
			}
			Iterator attributeList = patternXML.getAttributes().iterator();
            	while (attributeList.hasNext()) {
                Attribute patternElement = (Attribute)attributeList.next();
                String name = patternElement.getName();
                String value = patternElement.getValue();
 			   if (eventType.equals ("cron") ) {
 				   rawCronString = value;
 			   }
			   if (eventType.equals ("weekly") && value.equals ("1")) {
				   if (name.equals ("sun")) daysOfWeek += ",1" + recur;
				   if (name.equals ("mon")) daysOfWeek += ",2" + recur;
				   if (name.equals ("tue")) daysOfWeek += ",3" + recur;
				   if (name.equals ("wed")) daysOfWeek += ",4" + recur;
				   if (name.equals ("thu")) daysOfWeek += ",5" + recur;
				   if (name.equals ("fri")) daysOfWeek += ",6" + recur;
				   if (name.equals ("sat")) daysOfWeek += ",7" + recur;
				   if (name.equals("month")){
					   month = value;
				   }			   
				   
			   }
			   if (eventType.equals ("monthly")) {

				   if (name.equals("day")) {
					   daysOfWeek = value.toUpperCase();
				   }
				   if (name.equals("month")){
					   month = value;
				   }	
				   if (name.equals("week")){
					   weekOfMonth = value;
				   }

			   }
			   if (name.equals ("hour")) {
				   hours=value;
			   }
			   if (name.equals ("minute")) {
				   minutes=value;
			   }
            }
    		   if (daysOfWeek.equals ("")) {
    			   daysOfWeek = "*";
    		   }  else {
    			   if (daysOfWeek.charAt(0)==','){
    				   daysOfWeek = daysOfWeek.substring(1);
    			   }
    		   }
        } 
        
        SkipDates skipDates = new SkipDates();
        skipDates.parseEvent(nextEvent);
		map.put("SkipDates",skipDates);
	
        logger.log (Level.FINE,"Adding event " + title + " to the calendar");
		if (eventType.equals ("once")){
	        if (success) {
				SimpleTrigger trigger = new SimpleTrigger("Trigger:"+title,
	                      Scheduler.DEFAULT_GROUP,
						 startDateDecoded,
						 endDateDecoded,
	                      0,
	                      0L);			
				trigger.setMisfireInstruction(SimpleTrigger.MISFIRE_INSTRUCTION_RESCHEDULE_NEXT_WITH_REMAINING_COUNT );
				returnVal.setEventType(CalendarEventEntry.SINGLE_EVENT);
				returnVal.setTrigger(trigger);
				returnVal.setTitle(title);
				returnVal.setJobDetail(jobDetail);
				
				return returnVal;
	        }
	        else {
	        	return null;
	        }
		} 
		else {
			String cronString = "";
			if (eventType.equals ("cron")){
				cronString = rawCronString;
			}else {
				if (!weekOfMonth.equals("")){
					daysOfWeek += "#" + weekOfMonth;
				}
				cronString = seconds + " " + minutes + " " + hours + " ? " +  month + " " + daysOfWeek;
			}
			logger.log (Level.FINEST,"Entry is a repeating entry. Cron string is " + cronString);
			try {
				CronTrigger trigger = new CronTrigger ("Tigger"+title,
							Scheduler.DEFAULT_GROUP,
							title,
							Scheduler.DEFAULT_GROUP,
							startDateDecoded,
							endDateDecoded,
							cronString);
				trigger.setMisfireInstruction(CronTrigger.MISFIRE_INSTRUCTION_DO_NOTHING );
				returnVal.setEventType(CalendarEventEntry.REPEATING_EVENT);
				returnVal.setTrigger(trigger);
				returnVal.setTitle(title);
				returnVal.setJobDetail(jobDetail);
				return returnVal;
				
			} catch (ParseException ex){
				String errorMessage = "Unable to add repeating macro " + title + ". " + ex.getMessage();
				logger.log (Level.WARNING,errorMessage);
				throw new CalendarException (errorMessage,ex);
			}
		}
    }


	public Map getCalendar_message_params() {
		return calendar_message_params;
	}


	public void setCalendar_message_params(Map calendar_message_params) {
		this.calendar_message_params = calendar_message_params;
	}


	public User getUser() {
		return user;
	}


	public void setUser(User user) {
		this.user = user;
	}


	public void setMacroHandler(MacroHandler macroHandler) {
		this.macroHandler = macroHandler;
	}	
	
}
