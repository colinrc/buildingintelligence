/*
 * Created on Sep 29, 2004
 *
*/
package au.com.BI.IR;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;

import java.util.regex.*;
import java.util.logging.*;
import java.io.File;


public class Model extends SimplifiedModel implements DeviceModel {

	protected String parameter;
	protected String nextIRName = "";
	protected String initEndTime = "";


	public Model () {
		super();
	}

 	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		configHelper.wholeKeyChecked(keyName);
		if (isClientCommand)
			return false;
		else 
			return true;
	}

	public void doCommand (CommandInterface command) throws CommsFail
	{
		String theWholeKey = command.getKey().trim();
		String irCommand = "";
		String irDevice = "";

		boolean commandDone = false;

	    if (theWholeKey.endsWith("Z")) {
	        logger.log (Level.WARNING,"IR Capture failed, try again");
	        commandDone = true;
	    } 

	    if (!commandDone && theWholeKey.startsWith("IRend=")) {
    			String startVal = "";
    			startVal = theWholeKey.substring(6,theWholeKey.length()-4);
			Command irLearnt = new Command();
			irLearnt.setKey("IR_INTERNAL");
			irLearnt.setCommand ("EndInit");
			irLearnt.setExtraInfo(startVal);
			irLearnt.setAdminCommand(true);
			commandQueue.add((irLearnt));
    		commandDone = true;
	    } 
	    
	    if (!commandDone && theWholeKey.startsWith("IRend,")) {
	    		initEndTime = theWholeKey.substring(6,theWholeKey.length()-4);
			Command irLearnt = new Command();
			irLearnt.setKey("IR_INTERNAL");
			irLearnt.setCommand ("EndChanged");
			irLearnt.setAdminCommand(true);
			irLearnt.setExtraInfo(initEndTime);
			synchronized (this.commandQueue) {
				commandQueue.add((irLearnt));
				commandQueue.notifyAll();
			}
	    		commandDone = true;
	    }
	    if (!commandDone) {
			logger.log(Level.FINER,"IR sequence received for " + nextIRName);
			try {
				if (!nextIRName.equals("")) {
				    String [] iRNameBits = nextIRName.split("\\.",2);
				    	if (iRNameBits[1] != null && !iRNameBits[1].equals("")) {
				    	    irCommand = iRNameBits[1];
				    	} else {
						logger.log(Level.SEVERE,"IR name should be in the form IR_DEVICE.COMMAND");
						return;
				    	}

				    	if (iRNameBits[0] != null && !iRNameBits[0].equals("")) {
				    	    irDevice = iRNameBits[0];
				    	} else {
						logger.log(Level.SEVERE,"IR name should be in the form IR_DEVICE.COMMAND");
						return;
				    	}


				    	String [] irValBits = theWholeKey.split(",",3);
					if (irValBits.length < 3) {
						logger.log(Level.SEVERE,"IR value string was misformed");
						return;
					}

				    	String frq = irValBits[1];
				    	String vals = irValBits[2];

				    irCodeDB.add (irDevice,irCommand,frq,deCompress(vals));
				    irCodeDB.writeIRCodesFile ("datafiles" + File.separator + "ircodes");
					logger.log(Level.FINE,"IR sequence learnt for " + nextIRName);

					Command irLearnt = new Command();
					irLearnt.setKey("IR_INTERNAL");
					irLearnt.setCommand ("Learnt");
					irLearnt.setAdminCommand(true);
					irLearnt.setExtraInfo(nextIRName);
					synchronized (this.commandQueue) {
						commandQueue.add((irLearnt));
						commandQueue.notifyAll();
					}
				}
				nextIRName = ""; // Switch off recording until user requests another
			} catch (ArrayIndexOutOfBoundsException ex) {
			    logger.log(Level.SEVERE,"IR name should be in the form IR_DEVICE.COMMAND");
			}
	    }
	}


	public String deCompress (String gc100Code) {
	    //GC-IRL,38000,341,170,21,20,22,63BBBBBBCBCCCCCCCBBBBBCCBCCCCCBB,21,758

	    //sendir,2:1,8,38000,1,1,341,170,21,20,22,63,21,20,21,20,21,20,21,20,21,
	    // 20,21,20,22,63,21,20,22,63,22,63,22,63,22,63,22,63,22,63,22,63,21,20,
	    // 21,20,21,20,21,20,21,20,22,63,22,63,21,20,22,63,22,63,22,63,22,63,22,63,21,20,21,20,21,758

	    String compress1[] = new String[5];
	    String compress2[] = new String[5];
	    int compressCounter = 0;
	    StringBuffer outputString = new StringBuffer("1,1");

	    Pattern p = Pattern.compile("(^(\\d*)([ABCD]+))$");
	    int compressPos;

	    String strBits[] = gc100Code.split (",");
	    try {
			for (int i = 0; i < strBits.length-1; i+=2){
			    outputString.append(",");

			    Matcher m = p.matcher(strBits[i+1]);

			    String secondField = strBits[i+1];

			    if (m.matches()) {
			        secondField = m.group(2);
			        String theChars = m.group(3);
		            outputString.append(strBits[i] + "," + secondField);

		            if (compressCounter < 5) {
		                compress1[compressCounter] = strBits[i];
		                compress2[compressCounter] = secondField;
		                compressCounter ++;
		            }

			        for (int j = 0; j < theChars.length(); j++) {
			            compressPos = theChars.charAt(j) - 'A';
			            outputString.append("," + compress1[compressPos] + "," + compress2[compressPos]);
			        }
			    }
				else {
		            outputString.append(strBits[i] + "," + strBits[i+1]);
		            if (compressCounter < 5) {
		                compress1[compressCounter] = strBits[i];
		                compress2[compressCounter] = strBits[i+1];
		                compressCounter ++;
		            }
				}
	    		}
	    }
	    catch (IndexOutOfBoundsException ex) {
	        logger.log (Level.INFO,"IR string was malformed"); }
	    catch (IllegalStateException ex) {
	        logger.log (Level.INFO,"IR string was malformed");
	    }

	    return outputString.toString();
	}
	
	public void sendConfigCommand (String ir_command)   {
		String command = "";
		if (ir_command.equals("20")){
			command = "e1";
		}
		if (ir_command.equals("35")){
			command = "e2";
		}
		if (ir_command.equals("50")){
			command = "e3";
		}
		if (ir_command.equals("100")){
			command = "e4";
		}
		CommsCommand commsCommand = new CommsCommand();
		commsCommand.setKeepForHandshake(false);
		commsCommand.setCommand(command + "\r\n");
		try {
			comms.addCommandToQueue (commsCommand);
		} catch (CommsFail ex){
			logger.log(Level.WARNING, "Restablishing communication with IR Learner " + ex.getMessage());
			Command commandRec = new Command();
			commandRec.setCommand ("Attatch");
			commandRec.setKey("SYSTEM");
			commandRec.setExtraInfo (Integer.toString(this.InstanceID));
			commandQueue.add(commandRec);
		}
	}
	

	public void sendCommand (String commandToSend) {
		logger.log (Level.FINEST,"Sending to IR learner : " + commandToSend);
		CommsCommand commsCommand = new CommsCommand();
		commsCommand.setKeepForHandshake(false);
		commsCommand.setCommand(commandToSend+"\r\n");
			try {
				//comms.sendCommandAndKeepInSentQueue (cbusCommsCommand);
				comms.addCommandToQueue (commsCommand);
			} catch (CommsFail e1) {
				logger.log(Level.WARNING, "Restablishing communication with IR Learner " + e1.getMessage());
				Command command = new Command();
				command.setCommand ("Attatch");
				command.setKey("SYSTEM");
				command.setExtraInfo (Integer.toString(this.InstanceID));
				commandQueue.add(command);

			}
	}
	

	public void doStartup() throws CommsFail {
		CommsCommand commsCommand = new CommsCommand();
		commsCommand.setKeepForHandshake(false);
		commsCommand.setCommand("gs\r\n");
		comms.addCommandToQueue (commsCommand);
	}
	
	public void learnCommand (String commandName) {
		logger.log(Level.FINE,"Waiting for IR instruction for " + commandName);
	    nextIRName = commandName;
	}

	public boolean doIControlIR () {
	    return true;
	}

	public String getInitEndTime() {
		return initEndTime;
	}

	public void setInitEndTime(String initEndTime) {
		this.initEndTime = initEndTime;
	}

 
}
