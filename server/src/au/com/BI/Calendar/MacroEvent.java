/*
 * Created on Oct 3, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.Calendar;

import java.util.logging.*;

import au.com.BI.Command.CommandInterface;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Macro.MacroHandler;

import org.quartz.*;
import au.com.BI.User.*;

import java.util.Calendar;
import java.util.List;

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
        String alarm;
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
	      alarm = dataMap.getString("Alarm");
	      category = dataMap.getString("Category");
	      skipDates = (SkipDates)dataMap.get("SkipDates");
		  macroHandler = (MacroHandler)dataMap.get ("MacroHandler");
		  memo =dataMap.getString ("Memo");
		  String icon =dataMap.getString ("Icon");
		  String autoclose = dataMap.getString ("AutoClose");
		  String hideclose = dataMap.getString ("HideClose");
		  if (skipDates.doISkipDate(context.getFireTime())) {
			  return;
		  }
		  user = (User)dataMap.get("User");
		  filter = (String)dataMap.get("Filter");
		  if (filter != null && !filter.equals( "")){
			  int dayNumber = java.util.Calendar.getInstance().get(Calendar.DATE);
			  int value = (new Double((double)dayNumber/2.0)).intValue() * 2;
			  
			  if (filter.equals("even") && dayNumber != value){
				  return;
			  }
			  if (filter.equals("odd") && dayNumber == value){
				  return;
			  }

		  }

		  if (!macroName.equals ("")) {
			  ClientCommand builtRunCommand = new ClientCommand ();
			  builtRunCommand.setExtra2Info(extra2);
			  builtRunCommand.setExtra3Info(extra3);
			  builtRunCommand.setExtra4Info(command);
			  builtRunCommand.setExtra5Info(extra);

			  macroHandler.run(macroName , user,builtRunCommand);
		  }
		  if (!memo.equals("") && !memo.equals("undefined") && !alarm.equals ("N")) {
			  ClientCommand newCommand = new ClientCommand();
			  newCommand.setTargetDeviceID(0);
			  
		        newCommand.setTitle(title);
		        newCommand.setIcon(icon);
		        newCommand.setContent(memo);
		        newCommand.setAutoclose(autoclose);
		        newCommand.setHideclose(hideclose);
		        newCommand.setMessageType (CommandInterface.Message);
				List commandList = macroHandler.getCommandList();
				synchronized (commandList) {
					commandList.add(newCommand);
					commandList.notify();
				}
		  }

		   logger.log( Level.FINER, this.title + " is running.");
		}

}
