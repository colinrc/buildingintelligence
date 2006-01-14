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
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import java.util.logging.*;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.*;

import au.com.BI.Macro.MacroHandler;
import au.com.BI.User.*;


public class EventCalendar {
    protected Map events = null;
    protected SimpleDateFormat df = null;
    protected SimpleDateFormat tf = null;
    protected SimpleDateFormat totalDayF = null;
    
	protected Logger logger;
	protected String fileName = null;
	protected List commandList = null;
	protected Scheduler sched = null;
	
    protected int recurrance;
    
    protected int dayStartOffset = 0;
    protected int weekStartOffset = 0;
    protected int monthStartOffset = 0;
    protected int yearStartOffset = 0;
    protected int recurranceIntervalCount = 1;

	protected MacroHandler macroHandler = null;
	protected User user = null;
    protected SchedulerFactory schedFact = null;
	protected Map calendar_message_params;
	
    public EventCalendar (MacroHandler macroHandler, User user) throws SchedulerException {
		logger = Logger.getLogger(this.getClass().getPackage().getName());

        totalDayF = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
        totalDayF.applyPattern("yyyy-MM-dd HH:mm:ss");

        df = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
        df.applyPattern("yyyy-MM-dd");

        tf = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
        tf.applyPattern("HH:mm:ss");
        
		this.macroHandler = macroHandler;
		this.user = user;

		schedFact = new org.quartz.impl.StdSchedulerFactory();
		sched = schedFact.getScheduler();
		events = new HashMap (20);
		
		   
    }
	
 	
	public void setCommandList (List commandList){
		this.commandList = commandList;
	}
    
	public boolean parseCalendar (Element calendar) {
	
		Iterator eachEvent = calendar.getChildren().iterator();
		while (eachEvent.hasNext()) {
		    Element nextEvent = (Element)eachEvent.next();
		    this.addEvent(nextEvent);
		}
	
		return true;
	}
	
    public boolean addEvent (Element nextEvent) {
        boolean success = true;

	    	String title = nextEvent.getAttributeValue("title"); 
		events.put( title,nextEvent.clone());
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
	    	String totalStartDate = startDate + " " + "0:00:00";
		String totalEndDate = endDate + " 23:59:59";
	    	String macroName  = nextEvent.getAttributeValue("macroName");
	    	String filter  = nextEvent.getAttributeValue("filter");
	    	String rawCronString = "";
	    	if (filter == null) filter = "";


	    	if (title == null || title.equals ("") ) {
	    	    logger.log (Level.WARNING ,"No Title was set for the event");
	    	    return false;
	    	}
		
        Date startDateDecoded;
		if (startDate == null || startDate.equals ("")) {
			startDateDecoded = new Date();
		} else { 
	        try {
	            startDateDecoded = totalDayF.parse(totalStartDate);
	        } catch ( ParseException ex) {
	            logger.log (Level.WARNING,"Could not parse event " + title + " start date. " + ex.getMessage());
	            return false;
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
	            logger.log (Level.WARNING,"Could not parse event " + title + " end date. " + ex.getMessage());
	            return false;
	        }
		}
		if (endDateDecoded.before( new Date())) {
			return false;
		}
        
		JobDetail jobDetail = new JobDetail(title, 
                Scheduler.DEFAULT_GROUP, // job group
                MacroEvent.class);        // the java class to execute
		
		
		JobDataMap map = jobDetail.getJobDataMap(); 
		map.put ("Title",title);
		map.put("MacroHandler",macroHandler);
		map.put("MacroName",macroName);
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
				
				try {
					sched.deleteJob(title,Scheduler.DEFAULT_GROUP);
					sched.scheduleJob(jobDetail, trigger);
				} catch (SchedulerException e) {
					logger.log (Level.WARNING,"Unable to add timed macro " + title + " " + e.getMessage());
				}
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
				sched.deleteJob(title,Scheduler.DEFAULT_GROUP);
				sched.scheduleJob(jobDetail,trigger);
			} catch (ParseException e) {
				logger.log (Level.WARNING,"Unable to add repeating macro " + title + ". " + e.getMessage());
			} catch (SchedulerException e) {
				logger.log (Level.WARNING,"An internal scheduler error occured adding the job " + title + " " + e.getMessage());
			} catch (StringIndexOutOfBoundsException e){
				logger.log (Level.WARNING,"An internal scheduler error occured adding the job " + title + " " + e.getMessage());				
			}
		}
    
        return success;
    }
	
	public void setFileName (String fileName){
		this.fileName = "datafiles" + File.separator + fileName;
	}
	
	public void deleteEvent (String title) {
		try {
			sched.deleteJob(title,Scheduler.DEFAULT_GROUP);
		} catch (SchedulerException e) {
			logger.log (Level.FINE,"Error deleting scheduled task " + title + " " + e.getMessage());
		}
		synchronized (events) {
		    events.remove(title);
		}
	}
	
	public void clear () {
		try {
			sched.shutdown();
			sched = schedFact.getScheduler();
			
			sched.start();
		} catch (SchedulerException e) {
			logger.log (Level.FINE,"Error clearing the scheduler " + e.getMessage());
		}
		synchronized (events) {
		    events.clear();
		}
	}
	
	
	public boolean readCalendarFile()  {
		SAXBuilder builder = null;
		Element macrosElement;
		
		builder = new SAXBuilder();
		Document doc;
		
		try {
			doc = builder.build(fileName+".xml");
			Element calendar = doc.getRootElement();
			this.parseCalendar(calendar);
			sched.start();
			
		} catch (SchedulerException e) {
			logger.log (Level.FINE,"Error starting the scheduler " + e.getMessage());
		}  catch (JDOMException e) {
			logger.log(Level.WARNING,"Error in calendar file "+ e.getLocalizedMessage());
			return false;
		} catch (IOException e) {
			logger.log(Level.WARNING,"IO error in reading file "+ e.getLocalizedMessage());
			return false;
		}
		logger.log (Level.FINE,"Successfully read calendar file " + fileName+".xml");
		return true;
	}

	public Element buildListElement (String eventName) {
		Element event = (Element)events.get(eventName);
				
		return event;
	}
	
	/**
	 * Returns the event list as an XML element,or a specific entry.
	 * @param eventName Empty string for all events or the name of an event
	 * @return
	 */
	public Element get (String eventName) {
		Element top = new Element ("events");
		
		synchronized (events) {
			if (eventName.equals ("")) {
				Iterator eventNames = events.keySet().iterator();
				while (eventNames.hasNext()) {
					Element macroDef =  buildListElement ((String)eventNames.next());
					if (macroDef != null) {
						Element copyOfElement = (Element)macroDef.clone();
						top.addContent(copyOfElement);
					}
				}
			}
			else {
				Element eventDef = buildListElement (eventName);
				top.addContent( eventDef);
				
				}
		}
		return top;
	}
	
	public boolean saveCalendarFile() {
		try	 {
    
			XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
			File outputFile = new File (fileName+".new");
			FileWriter out = new FileWriter(outputFile);
			xmlOut.output(this.get(""), out) ;
			out.flush();
			out.close();
			logger.log (Level.INFO,"Calendar write succeeded.");
			
			File oldFile = new File (fileName+".xml");
			File newName = new File (fileName+".old");
			
			if (oldFile.exists()) {
			    if (newName.exists() && !newName.delete()) {
				    logger.log (Level.SEVERE, "Could not delete old backup calendar file "+oldFile.getName());
				    return false;
			    }
				if (!oldFile.renameTo (newName)) { 
				    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
				    return false;
				}
			}

			if (!outputFile.renameTo(oldFile)) {
			    logger.log (Level.SEVERE, "Could not rename new file "+outputFile.getName()+" to " + oldFile.getName());
			    return false;
			} else {
				return true;
			}
			    
		}
		catch (IOException ex)
		{
			logger.log (Level.FINER, "IO error saving calendar file " + ex.getMessage());
			return false;
		}

	}

    /**
     * @return Returns the events.
     */
    public Map getEvents() {
        return events;
    }

	public Scheduler getSched() {
		return sched;
	}
	

	public void setSched(Scheduler sched) {
		this.sched = sched;
	}


	public Map getCalendar_message_params() {
		return calendar_message_params;
	}


	public void setCalendar_message_params(Map calendar_message_params) {
		this.calendar_message_params = calendar_message_params;
	}
	
}
