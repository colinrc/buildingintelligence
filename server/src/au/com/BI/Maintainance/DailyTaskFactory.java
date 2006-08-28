/**
 * 
 */
package au.com.BI.Maintainance;

import java.text.ParseException;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.quartz.CronTrigger;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SchedulerFactory;

import au.com.BI.Macro.MacroHandler;

/**
 * @author colin
 *
 */
public class DailyTaskFactory  {
	protected Logger logger = null;
	protected MacroHandler macroHandler = null;
	protected String startTime = "23:30";
	protected JobDetail jobDetail = null;
	final String MAINTENANCE_GROUP = "Maintenance";
	protected Scheduler sched = null;
    protected SchedulerFactory schedFact = null;
    
	public DailyTaskFactory() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		try {
			schedFact = new org.quartz.impl.StdSchedulerFactory();
			sched = schedFact.getScheduler();

			sched.start();
		} catch (SchedulerException e) {
			logger.log (Level.FINE,"Error starting the scheduler " + e.getMessage());
		}
	}

	public boolean start() {
		jobDetail = new JobDetail();
		jobDetail.setName("Maintenance");
		jobDetail.setGroup(MAINTENANCE_GROUP);
		JobDataMap map = jobDetail.getJobDataMap();
		map.put("MACRO", macroHandler);
		jobDetail.setJobClass(DailyTask.class);


		CronTrigger  trigger = new CronTrigger ("DailyTask",
				MAINTENANCE_GROUP);
		String [] timeParts = this.startTime.split(":");
		
		try {
			trigger.setGroup(MAINTENANCE_GROUP);
			trigger.setCronExpression("0 " + timeParts[1] + " " + timeParts[0] + " * * ?");
			sched.deleteJob("DailyTask",MAINTENANCE_GROUP);
			sched.scheduleJob(jobDetail, trigger);
			return true;
		} catch (SchedulerException e) {
			logger.log (Level.WARNING,"An internal scheduler error occured adding the maintenance job. "  + e.getMessage());
			return false;
		} catch (StringIndexOutOfBoundsException e){
			logger.log (Level.WARNING,"An internal scheduler error occured adding the maintenance job. " +  e.getMessage());				
			return false;
		} catch (ParseException e) {
			logger.log (Level.WARNING,"An incorrect time was specified for the daily maintenance job in the bootstrap file.  " +  e.getMessage());				
			return false;
		}catch (IndexOutOfBoundsException  e) {
			logger.log (Level.WARNING,"An incorrect time was specified for the daily maintenance job in the bootstrap file.  " +  e.getMessage());				
			return false;
		}
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

	public MacroHandler getMacroHandler() {
		return macroHandler;
	}

	public void setMacroHandler(MacroHandler macroHandler) {
		this.macroHandler = macroHandler;
	}
	
}
