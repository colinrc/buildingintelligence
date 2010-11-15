package au.com.BI.Calendar;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.*;

import org.jdom.Element;


public class SkipDates {
	
    protected SimpleDateFormat skipDate = null;
    protected Logger logger;
    protected List<SkipEntry> skipDates = null;

    public SkipDates () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());

        skipDate = (SimpleDateFormat)SimpleDateFormat.getDateTimeInstance();
        skipDate.applyPattern("yyyy-MM-dd hh:mm:ss");
        skipDates = new LinkedList<SkipEntry>();    	
    }
    
	public void parseEvent (Element event){
        List<Element> skipElements = event.getChildren("skip");
        Iterator<Element> eachSkip = skipElements.iterator();
        while (eachSkip.hasNext()){
        		Element skipElement = (Element)eachSkip.next();
        		String skipStart = skipElement.getAttributeValue("start_date") + " 00:00:00";
           	String skipEnd = skipElement.getAttributeValue("end_date") + " 23:59:59";
           	this.addDates(skipStart,skipEnd);
        }
	}
	
	public void renderEvent (Element event){
		Iterator<SkipEntry> eachSkip = skipDates.iterator();
		while (eachSkip.hasNext()){
			SkipEntry skipEntry = eachSkip.next();
			String startDate = skipDate.format(skipEntry.startDate);
			String endDate = skipDate.format(skipEntry.endDate);					
			Element skipXML = new Element("skip");
			skipXML.setAttribute("start_date",startDate);
			skipXML.setAttribute("end_date",endDate);
			event.addContent(skipXML);
		}
	}
	
	public void addDates (String skipStart, String skipEnd){
       	SkipEntry skip = new SkipEntry ();
        try {
            skip.setStartDate(skipDate.parse(skipStart));
            skip.setEndDate(skipDate.parse(skipEnd));
            skipDates.add (skip);
        } catch (ParseException ex){
       	 	logger.log (Level.WARNING,"Skip entry in the calendar is misformatted " + ex.getMessage());
        }		
	}
	
	public boolean doISkipDate(Date testDate){
		Iterator<SkipEntry> eachSkip = skipDates.iterator();
		while (eachSkip.hasNext()){
			SkipEntry skipEntry = eachSkip.next();
			if ((skipEntry.getStartDate().compareTo(testDate) <= 0 ) &&
					(skipEntry.getEndDate().compareTo(testDate) >= 0 ))
				return true;
		}
		return false;
	}
}