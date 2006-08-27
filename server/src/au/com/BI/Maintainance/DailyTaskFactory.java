/**
 * 
 */
package au.com.BI.Maintainance;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.quartz.CronTrigger;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;

/**
 * @author colin
 *
 */
public class DailyTaskFactory  {
	protected Logger logger = null;
	protected au.com.BI.Macro.Model macroModel = null;
	protected String startTime = "23:30";
	protected JobDetail jobDetail = null;
	final String MAINTENANCE_GROUP = "Maintenance";
	protected Scheduler sched = null;
	
	public DailyTaskFactory() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());

	}

	public boolean start() {
		jobDetail = new JobDetail();
		jobDetail.setGroup("Maintenance");
		JobDataMap map = jobDetail.getJobDataMap();
		map.put("MACRO", macroModel);
		jobDetail.setJobClass(DailyTask.class);

		CronTrigger trigger = new CronTrigger("DailyTask",
				MAINTENANCE_GROUP);
		try {
			sched.deleteJob("DailyTask",MAINTENANCE_GROUP);
			sched.scheduleJob(jobDetail, trigger);
			return true;
		} catch (SchedulerException e) {
			logger.log (Level.WARNING,"An internal scheduler error occured adding the maintenance job "  + e.getMessage());
			return false;
		} catch (StringIndexOutOfBoundsException e){
			logger.log (Level.WARNING,"An internal scheduler error occured adding the maintenance job " +  e.getMessage());				
			return false;
		}
	}
	
	public au.com.BI.Macro.Model getMacroModel() {
		return macroModel;
	}

	public void setMacroModel(au.com.BI.Macro.Model macroModel) {
		this.macroModel = macroModel;
	}

	public String getStartTime() {
		return startTime;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public Scheduler getSched() {
		return sched;
	}

	public void setSched(Scheduler sched) {
		this.sched = sched;
	}
	
}
