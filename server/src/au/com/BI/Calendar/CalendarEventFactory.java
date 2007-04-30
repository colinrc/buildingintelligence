/*
 * Created on Oct 12, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.Calendar;

import java.util.*;

import org.quartz.*;

import org.jdom.*;
import java.util.logging.*;

import java.text.*;
import au.com.BI.Macro.MacroHandler;
import au.com.BI.User.*;


public class CalendarEventFactory {
    // protected Map events = null;
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
    protected Map <String,String>calendar_message_params;
    
    public CalendarEventFactory() {
	logger = Logger.getLogger(this.getClass().getPackage().getName());
	
	totalDayF = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
	totalDayF.applyPattern("yyyy-MM-dd HH:mm:ss");
	
	df = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
	df.applyPattern("yyyy-MM-dd");
	
	tf = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
	tf.applyPattern("HH:mm:ss");
    }
    
    
    public CalendarEventEntry createEvent(Element nextEvent) throws CalendarException {
	boolean success = true;
	CalendarEventEntry returnVal = new CalendarEventEntry();
	boolean eventTypeOnce = false;
	
	String id = nextEvent.getAttributeValue("id");
	if (id == null || id.equals("")) {
	    id = Long.toString(System.currentTimeMillis());
	}
	returnVal.setId(id);
	String eventType = nextEvent.getAttributeValue("eventType");
	if (eventType == null || eventType.equals("") || eventType.equals ("once")) {
	    eventType = "once";
	    eventTypeOnce = true;
	} 
	
	String startDate = "";
	if (eventTypeOnce ) {
	    startDate = nextEvent.getAttributeValue("date");
	} else {
	    startDate = nextEvent.getAttributeValue("startDate");
	}
	String endDate = nextEvent.getAttributeValue("endDate");
	String time  = nextEvent.getAttributeValue("time");
	String hours = "";
	String orig_hour = "";
	String dateBits[] = startDate.split("-");
	String year = dateBits[0];
	String orig_year = "";
	String minutes = "";
	String seconds = "";
	long hourMs = 1000 * 60 * 60;
	long dayMs = hourMs * 24;
		
	if (time == null || time.equals("")) {
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
	
	String title = nextEvent.getAttributeValue("title");
	if (title == null)  title = "";

	String popup = nextEvent.getAttributeValue("popup");
	if (popup == null)  popup = "";
	
	String alarm = nextEvent.getAttributeValue("alarm");
	if (alarm == null)  alarm = "";
	
	String target = nextEvent.getAttributeValue("target");
	if (target == null)  target = "";
	
	String target_user = nextEvent.getAttributeValue("target_user");
	if (target_user == null)  target_user = "";
	
	String category = nextEvent.getAttributeValue("category");
	if (category == null)  category = "";
	
	String memo = nextEvent.getAttributeValue("memo");
	if (memo == null)  memo = "";
	
	Date startDateDecoded;
	if (startDate == null || startDate.equals("")) {
	    startDateDecoded = new Date();
	} else {
	    try {
		startDateDecoded = totalDayF.parse(totalStartDate);
	    } catch ( ParseException ex) {
		String errorMessage = "Could not parse event " + title + " start date. " + ex.getMessage();
		logger.log(Level.WARNING,errorMessage);
		throw new CalendarException(errorMessage,ex);
	    }
	}
	
	Date endDateDecoded;
	if (endDate == null || endDate.equals("")) {
	    endDateDecoded = new Date();
	    endDateDecoded.setYear(2999);
	} else {
	    try {
		endDateDecoded = totalDayF.parse(totalEndDate);
	    } catch ( ParseException ex) {
		String errorMessage = "Could not parse event " + id + " end date. " + ex.getMessage();
		logger.log(Level.WARNING,errorMessage);
		throw new CalendarException(errorMessage,ex);	        }
	}
	if (endDateDecoded.before( new Date()) || (eventTypeOnce && startDateDecoded.before(new Date()))) {
	    returnVal.setStillActive(false);
	    return returnVal;
	}
	String active = nextEvent.getAttributeValue("active");
	if (active != null && active.equals("N")) {
		returnVal.setActive(false);
		return returnVal;
	}
	
	JobDetail jobDetail = new JobDetail(id,
		Scheduler.DEFAULT_GROUP, // job group
		MacroEvent.class);        // the java class to execute
	
	
	JobDataMap map = jobDetail.getJobDataMap();
	map.put("ID",id);
	map.put("Category",category);
	map.put("Popup",popup);
	map.put("Title",title);
	map.put("MacroHandler",macroHandler);
	map.put("MacroName",macroName);
	map.put("command",command);
	map.put("extra",extra);
	map.put("extra2",extra2);
	map.put("extra3",extra3);
	map.put("User", user);
	map.put("Filter", filter);
	map.put("Alarm",alarm);
	map.put("Memo",memo);
	map.put("StartTime",startDateDecoded);

	java.util.Calendar startCalendar = java.util.Calendar.getInstance();
	startCalendar.setTime(startDateDecoded);
	int startMonth = startCalendar.get(java.util.Calendar.MONTH);
	map.put ("StartMonth",startMonth);

	map.put("Target",target);
	map.put("Target_User",target_user);
	
	if (calendar_message_params != null) {
	    map.put("Icon",calendar_message_params.get("ICON"));
	    map.put("AutoClose",calendar_message_params.get("AUTOCLOSE"));
	    map.put("HideClose",calendar_message_params.get("HIDECLOSE"));
	} else {
	    map.put("Icon","");
	    map.put("AutoClose","AUTOCLOSE");
	    map.put("HideClose","HIDECLOSE");
	}
	
	String daysOfWeek = "";
	String weekOfMonth = "";
	String month = "*";
	String recur = "";
	String dateOfMonth = "?";
	
	if (eventType.equals("hourly")) {
	    orig_hour = hours;
	    hours="*";
	}
	if (eventType.equals("yearly")) {
	    orig_year = year;
	    year="*";
	}

	long interval = 1L;
	long intervalMonth = 1L;
	map.put ("Interval",interval);
	map.put ("IntervalMonth",intervalMonth);

	long recurVal = 1;
    map.put("RecurVal", recurVal);
	
	Element patternXML = nextEvent.getChild("pattern");
	if (patternXML != null) {
	    
	    
	    recur = (String)patternXML.getAttributeValue("recur");
	    if (recur == null ) {
	    	recurVal = 1L;
	    } else {
			try {
			    recurVal = Integer.parseInt(recur);
			} catch (NumberFormatException ex){
			    recurVal = 1L;
			    logger.log (Level.WARNING,"An invalid recurrance was sent with a calendar event " + recur);
			}
	    }
	    map.put("RecurVal", recurVal);
	    
	    
	    Iterator attributeList = patternXML.getAttributes().iterator();
	    while (attributeList.hasNext()) {
		Attribute patternElement = (Attribute)attributeList.next();

			String name = patternElement.getName();
			String value = patternElement.getValue();
			if (eventType.equals("cron") ) {
			    rawCronString = value;
			}
			if (eventType.equals("weekly") && value.equals("1")) {
			    if (name.equals("sun")) daysOfWeek += ",1" ;
			    if (name.equals("mon")) daysOfWeek += ",2" ;
			    if (name.equals("tue")) daysOfWeek += ",3" ;
			    if (name.equals("wed")) daysOfWeek += ",4" ;
			    if (name.equals("thu")) daysOfWeek += ",5" ;
			    if (name.equals("fri")) daysOfWeek += ",6" ;
			    if (name.equals("sat")) daysOfWeek += ",7" ;
			    if (name.equals("month")){
				month = value;
			    }
			    if (recurVal != 1){
				interval = recurVal * dayMs * 7L;
			    }
			    
			}
			if (eventType.equals("monthly")) {
			    
			    if (name.equals("day")) {
				daysOfWeek = value.toUpperCase();
			    }
			    if (name.equals("month")){
				month = value;
			    }
			    if (name.equals("week")){
				weekOfMonth = value;
			    }
			    if (name.equals("date")){
				dateOfMonth = value;
			    }
			    intervalMonth = recurVal;
			    map.put ("IntervalMonth",intervalMonth);
			}
			if (eventType.equals("daily")) {
			    if (recurVal != 1 && !filter.contains("odd") && !filter.contains("even")){
			    	interval = recurVal * dayMs;
			    }
			}
			if (eventType.equals("hourly")) {
			    if (recurVal != 1){
			    	interval = recurVal * hourMs;
			    }
			}
			if (eventType.equals("yearly")) {
			    
			    if (name.equals("recur")) {
			    	year = orig_year+"/" + value.toUpperCase();
			    }
			    if (name.equals("date")){
					dateOfMonth = value;
				}
			    if (name.equals("month")){
		    		month = value;
			    }
			}
			
			map.put ("Interval",interval);
			map.put("RecurVal",recurVal);
		    }
		    if (daysOfWeek.equals("")) {
			daysOfWeek = "?";
			if (dateOfMonth.equals("?")){
			    
			    dateOfMonth = "*";
			}
			    
		    }  else {
			if (daysOfWeek.charAt(0)==','){
			    daysOfWeek = daysOfWeek.substring(1);
			}
	    }
	}
	
	SkipDates skipDates = new SkipDates();
	skipDates.parseEvent(nextEvent);
	map.put("SkipDates",skipDates);
	
	logger.log(Level.FINE,"Adding event " + title + " to the calendar");
	
	if (skipDates.doISkipDate(new Date())){
		// Skip a macro if it is already running
		if (!macroName.equals("") ) {
			generateMacroCommand (macroName,"skip",extra);
		}
	}
	
	if (eventTypeOnce){
	    if (success) {
		SimpleTrigger trigger = new SimpleTrigger("ID:"+id,
			Scheduler.DEFAULT_GROUP,
			startDateDecoded,
			endDateDecoded,
			0,
			0L);
		trigger.setMisfireInstruction(SimpleTrigger.MISFIRE_INSTRUCTION_RESCHEDULE_NEXT_WITH_REMAINING_COUNT );
		returnVal.setEventType(CalendarEventEntry.SINGLE_EVENT);
		returnVal.setTrigger(trigger);
		returnVal.setId(id);
		returnVal.setJobDetail(jobDetail);
		
		return returnVal;
	    } else {
		return null;
	    }
	} else {
	    String cronString = "";
	    if (eventType.equals("cron")){
		cronString = rawCronString;
	    }else {
		if (!weekOfMonth.equals("")){
		    if (weekOfMonth.equals("5"))
			daysOfWeek += "L";
		    else {
			daysOfWeek += "#" + weekOfMonth;			
		    }
		}

		
		cronString = seconds + " " + minutes + " " + hours + " " + dateOfMonth + " " +  month + " " + daysOfWeek +" " + year;
	    }
	    logger.log(Level.FINEST,"Entry is a repeating entry. Cron string is " + cronString);
	    try {
		CronTrigger trigger = new CronTrigger("ID:"+id,
			Scheduler.DEFAULT_GROUP,
			id,
			Scheduler.DEFAULT_GROUP,
			startDateDecoded,
			endDateDecoded,
			cronString);
		trigger.setMisfireInstruction(CronTrigger.MISFIRE_INSTRUCTION_DO_NOTHING );
		returnVal.setEventType(CalendarEventEntry.REPEATING_EVENT);
		returnVal.setTrigger(trigger);
		returnVal.setJobDetail(jobDetail);
		org.quartz.impl.calendar.BaseCalendar baseCalendar = new org.quartz.impl.calendar.BaseCalendar();
		Date firstFire = trigger.computeFirstFireTime(baseCalendar);
		map.put("StartTime",firstFire);
		return returnVal;
		
	    } catch (ParseException ex){
		String errorMessage = "Unable to add repeating macro " + title + ". " + ex.getMessage();
		logger.log(Level.WARNING,errorMessage);
		throw new CalendarException(errorMessage,ex);
	    }
	}
    }
    
	public void generateMacroCommand (String macroName, String command, String targetDisplayName){	
		
		macroHandler.complete(macroHandler.buildFullName(macroName,targetDisplayName) , user);

	}

    
    public Map <String,String> getCalendar_message_params() {
    	return calendar_message_params;
    }
    
    
    public void setCalendar_message_params(Map <String,String> calendar_message_params) {
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
