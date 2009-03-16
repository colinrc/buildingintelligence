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

import au.com.BI.Command.CommandQueue;


/**
 * @author colin
 *
 */
public class RegularTaskFactory  {
	protected Logger logger = null;

	protected JobDetail jobDetail = null;
	final String MAINTENANCE_GROUP = "Maintenance";
	protected Scheduler sched = null;
    protected SchedulerFactory schedFact = null;
	private CommandQueue commandQueue;
    
	public RegularTaskFactory() {
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
		jobDetail.setName("RegularEvent");
		jobDetail.setGroup(MAINTENANCE_GROUP);
		JobDataMap map = jobDetail.getJobDataMap();
		map.put("COMMANDS", commandQueue);
		jobDetail.setJobClass(RegularTask.class);


		CronTrigger  trigger = new CronTrigger ("RegularTask",
				MAINTENANCE_GROUP);

		
		try {
			trigger.setGroup(MAINTENANCE_GROUP);
			trigger.setCronExpression("0 0/5 * * * ?");
			sched.deleteJob("RegularTask",MAINTENANCE_GROUP);
			sched.scheduleJob(jobDetail, trigger);
			return true;
		} catch (SchedulerException e) {
			logger.log (Level.WARNING,"An internal scheduler error occured adding the maintenance job. "  + e.getMessage());
			return false;
		} catch (StringIndexOutOfBoundsException e){
			logger.log (Level.WARNING,"An internal scheduler error occured adding the maintenance job. " +  e.getMessage());				
			return false;
		} catch (ParseException e) {
			logger.log (Level.WARNING,"An incorrect time was specified for the regular event job.  " +  e.getMessage());				
			return false;
		}catch (IndexOutOfBoundsException  e) {
			logger.log (Level.WARNING,"An incorrect time was specified for the regular event job.  " +  e.getMessage());				
			return false;
		}
	}
	

	public Scheduler getSched() {
		return sched;
	}

	public void setSched(Scheduler sched) {
		this.sched = sched;
	}

	/**
	 * @param commandQueue
	 */
	public void setCommandList(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
		
	}
	
}
