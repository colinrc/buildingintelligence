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
    protected LinkedHashMap events = null;
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
	protected CalendarEventFactory calendarEventFactory = null;
	
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
		events = new LinkedHashMap (20);
		
		this.setCalendarEventFactory(new CalendarEventFactory());
		calendarEventFactory.setMacroHandler(macroHandler);		   
    }
	
 	
	public void setCommandList (List commandList){
		this.commandList = commandList;
	}
    
	public boolean parseCalendar (Element calendar) {
	
		Iterator eachEvent = calendar.getChildren().iterator();
		while (eachEvent.hasNext()) {
		    Element nextEvent = (Element)eachEvent.next();
		    try {
		    	CalendarEventEntry calendarEventEntry = calendarEventFactory.createEvent(nextEvent);
		    	if (calendarEventEntry.isStillActive()){
		    		addEvent (calendarEventEntry);
		    	}
		    	addEventXMLToStore (calendarEventEntry.getId(),nextEvent);
		    } catch (CalendarException ex){
		    }	    	
		}
	
		return true;
	}
	
	public void addEventXMLToStore (String id, Element xml){
		xml.setAttribute("id",id);
		events.put( id,xml);		
	}

	public boolean addEvent (CalendarEventEntry calendarEventEntry){
    	if (calendarEventEntry.getEventType() == CalendarEventEntry.SINGLE_EVENT){
    		try {
				sched.deleteJob(calendarEventEntry.getId(),Scheduler.DEFAULT_GROUP);
				sched.scheduleJob(calendarEventEntry.getJobDetail(), (SimpleTrigger)calendarEventEntry.getTrigger());
				return true;
    		} catch (SchedulerException e) {
				logger.log (Level.WARNING,"Unable to add timed macro " + calendarEventEntry.getTitle() + " " + e.getMessage());
			}

    	} else {
    		try {
				sched.deleteJob(calendarEventEntry.getId(),Scheduler.DEFAULT_GROUP);
				sched.scheduleJob(calendarEventEntry.getJobDetail(), (CronTrigger)calendarEventEntry.getTrigger());
				return true;
			} catch (SchedulerException e) {
				logger.log (Level.WARNING,"An internal scheduler error occured adding the job " + calendarEventEntry.getTitle() + " " + e.getMessage());
			} catch (StringIndexOutOfBoundsException e){
				logger.log (Level.WARNING,"An internal scheduler error occured adding the job " + calendarEventEntry.getTitle() + " " + e.getMessage());				
			}
    	}
    	return false;
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

	public Element buildListElement (String eventID) {
		Element event = (Element)events.get(eventID);
				
		return event;
	}
	
	/**
	 * Returns the event list as an XML element,or a specific entry.
	 * @param eventName Empty string for all events or the name of an event
	 * @return
	 */
	public Element get (String eventID) {
		Element top = new Element ("events");

		synchronized (events) {
			if (eventID.equals ("")) {
                            top.setAttribute("COMPLETE","Y");
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
                            top.setAttribute("COMPLETE","N");
                            String eventIDs[] = eventID.split (",");
                            for (int i = 0; i < eventIDs.length; i ++){
                                Element eventDef = buildListElement (eventIDs[i]);
                                if (eventDef != null) {
                                        Element copyOfElement = (Element)eventDef.clone();
                                        top.addContent(copyOfElement);
                                }
                            }
                            
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
		return calendarEventFactory.getCalendar_message_params();
	}


	public void setCalendar_message_params(Map calendar_message_params) {
		calendarEventFactory.setCalendar_message_params(calendar_message_params);
	}

	public void setCalendarEventFactory(CalendarEventFactory calendarEventFactory) {
		this.calendarEventFactory = calendarEventFactory;
	}
	
}
