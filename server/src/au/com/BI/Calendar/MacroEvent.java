/*
 * Created on Oct 3, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.Calendar;

import java.util.logging.*;

import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Macro.MacroHandler;

import org.quartz.*;
import au.com.BI.User.*;

import java.util.Calendar;
import java.util.Date;

public class MacroEvent implements Job {

	protected MacroHandler macroHandler;
	protected Logger logger;
	protected User user;
	protected SkipDates skipDates = null;
    protected String macroName = "";
    protected String title = "";
    protected String memo = "";
    protected String filter ="";
    protected String extra ="";
    protected String extra2 ="";
    protected String extra3 ="";
    protected String command ="";
    protected String extra5 ="";
	protected String alarm = "";
	protected String target = "";
	protected String target_user = "";
	
    public MacroEvent () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
    }


    public void execute(JobExecutionContext context)
    		throws JobExecutionException
    		{
    	
        String macroName;
        String title;
        String memo;
        String filter;
        String popup;
        String id;
        String category;

	    //  String instGroup = context.getJobDetail().getGroup();

	      JobDataMap dataMap = context.getJobDetail().getJobDataMap();
	      macroName  = dataMap.getString("MacroName");
	      extra2  = dataMap.getString("extra2");
	      extra3  = dataMap.getString("extra3");
	      command  = dataMap.getString("command");
	      extra  = dataMap.getString("extra");
	      title = dataMap.getString("Title");
	      id = dataMap.getString("Id");
	      popup = dataMap.getString("Popup");
	      alarm = dataMap.getString("Alarm");
	      target = dataMap.getString("Target");
	      target_user = dataMap.getString("TargetUser");
	      
	      category = dataMap.getString("Category");
	      skipDates = (SkipDates)dataMap.get("SkipDates");
		  macroHandler = (MacroHandler)dataMap.get ("MacroHandler");
		  memo =dataMap.getString ("Memo");
		  String icon =dataMap.getString ("Icon");
		  String autoclose = dataMap.getString ("AutoClose");
		  String hideclose = dataMap.getString ("HideClose");
		  long recurVal = 1L;
		  long interval = 1L;
		  long intervalMonth = 1L;
		  try {
			  recurVal = dataMap.getLong("RecurVal");
			  interval = dataMap.getLong ("Interval");
			  intervalMonth = dataMap.getLong ("IntervalMonth");
		  } catch (NumberFormatException ex) {
			  throw new JobExecutionException (ex.getMessage());
		  }catch (NullPointerException  ex) {
			  throw new JobExecutionException (ex.getMessage());
		  }
		  
		  int startMonth = dataMap.getInt("StartMonth");
		  
		  if (skipDates.doISkipDate(context.getFireTime())) {
			  return;
		  }
		  user = (User)dataMap.get("User");
		  filter = (String)dataMap.get("Filter");
		  if (filter != null && !filter.equals( "")){
			  int dayNumber = java.util.Calendar.getInstance().get(Calendar.DATE);
			  boolean isOdd = false;
			  
			  if (dayNumber % 2 == 1){
				  isOdd = true;
			  }
			  
			  if (filter.equals("odd")) {
				  if (!isOdd ){
					  // Filter is odd , but day is even so do not continue
					  return ;
				  } else {
					  // day is odd, now check for recurring value
				  
					  if (recurVal != 1){
						  int firstDay = (int)recurVal * 2 -  1;
						  // recurVal * 2 due to odd + even
						  
						  if ((dayNumber - firstDay) % (recurVal * 2) != 0) 
							  return;
						  		// Not correct interval so return
					  } 
				  }
			  }

			  if (filter.equals("even")) {
				  if (isOdd ){
					  // Filter is even , but day is odd so do not continue
					  return ;
				  } else {
					  // day is odd, now check for recurring value
				  
					  if (recurVal != 1){
						  int firstDay = (int)recurVal * 2 ;
						  // recurVal * 2 due to odd + even
						  
						  if ((dayNumber - firstDay) % (recurVal * 2) != 0) 
							  return;
						  		// Not correct interval so return
					  } 
				  }
			  }

		  }
		  long scheduledTime = context.getScheduledFireTime().getTime();
		  long prevStart;
		  
		  if (context.getPreviousFireTime() != null) {
			prevStart = context.getPreviousFireTime().getTime();
		  } else {
			Date startTime = (Date)dataMap.get("StartTime");
			prevStart = startTime.getTime();
		      
		  }
		  
		  if (interval != 1 || intervalMonth != 1){
		      if (intervalMonth == 1){
			  long diff = scheduledTime - prevStart;
			  if (diff%interval != 0) {
			      return; // some multiple of the interval
			  }

		      } else {
			  Calendar execTime = Calendar.getInstance();
			  execTime.setTimeInMillis(scheduledTime);
			  int execMonth = execTime.get(Calendar.MONTH);
			  int monthDif = Math.abs (execMonth - startMonth);
			  if (monthDif % intervalMonth != 0) {
			      return;
			  }
		      }
		  }
		  
 		  if (!macroName.equals ("")) {
			  ClientCommand builtRunCommand = new ClientCommand ();
			  builtRunCommand.setExtra2Info(extra2);
			  builtRunCommand.setExtra3Info(extra3);
			  builtRunCommand.setExtra4Info(command);
			  builtRunCommand.setExtra5Info(extra);

			  macroHandler.run(macroHandler.buildFullName(macroName,extra), user,builtRunCommand);
		  }
		  if (alarm.equals("Y") || (!memo.equals("") && !memo.equals("undefined")  && !popup.equals ("N"))) {
			  ClientCommand newCommand = new ClientCommand();
			  newCommand.setTargetDeviceID(0);
			  
		        newCommand.setTitle(title);
		        newCommand.setIcon(icon);
		        newCommand.setContent(memo);
		        newCommand.setAutoclose(autoclose);
		        newCommand.setHideclose(hideclose);
		        newCommand.setTarget(target);
		        newCommand.setTargetUser(target_user);
		        newCommand.setAlarm (alarm);
		        newCommand.setMessageType (CommandInterface.Message);
				CommandQueue commandList = macroHandler.getCommandList();
				commandList.add(newCommand);
		  }

		   logger.log( Level.FINER, this.title + " is running.");
		}

}
