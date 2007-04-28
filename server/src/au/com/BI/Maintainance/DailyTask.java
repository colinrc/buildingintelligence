/**
 * 
 */
package au.com.BI.Maintainance;

import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author colin
 *
 */
public class DailyTask implements Job {

	protected Logger logger = null;
	
	public DailyTask ( ){
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
    public void execute(JobExecutionContext context)
	throws JobExecutionException
	{
	      JobDataMap dataMap = context.getJobDetail().getJobDataMap();
	      au.com.BI.Calendar.Model  calendarModel = (au.com.BI.Calendar.Model)dataMap.get("CALENDAR");
	      calendarModel.getCalendarHandler().cleanCalendarFile();
	      logger.log (Level.FINE,"Maintenance completed");
	}
}
