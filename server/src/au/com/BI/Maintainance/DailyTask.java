/**
 * 
 */
package au.com.BI.Maintainance;

import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * @author colin
 *
 */
public class DailyTask implements Job {

    public void execute(JobExecutionContext context)
	throws JobExecutionException
	{
	      JobDataMap dataMap = context.getJobDetail().getJobDataMap();
	}
}
