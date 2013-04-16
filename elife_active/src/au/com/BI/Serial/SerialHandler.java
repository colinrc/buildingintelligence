/*
 * Created on 25/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.Serial;

import java.util.HashMap;

import au.com.BI.Command.Command;
import au.com.BI.Connection.ServerHandler;
import au.com.BI.GUI.MainWindowBG;

/**
 * @author David
 *
 * 
 * 
 */
public class SerialHandler {
	private MainWindowBG bg;
	private ServerHandler serverHandle;
	private HashMap serialCommands;
	private SerialCommsObject commsObject;
	/**
	 * 
	 */
	public SerialHandler(ServerHandler serverHandle) {
		super();		
		this.serverHandle = serverHandle;
		serialCommands = new HashMap();
		setSerialDefaults();
		
		// TODO Auto-generated constructor stub
	}
	public void setWindowBG(MainWindowBG bg){
		this.bg = bg;
	}
	public void setOverride(String inKey, Object inOverride){
		serialCommands.put(inKey,inOverride);
	}
	public void setSerialDefaults(){
		serialCommands.put("PIROn","PIROn");
		serialCommands.put("PIROff","PIROff");
		serialCommands.put("Temp","Temp");
		serialCommands.put("Light","Light");
		serialCommands.put("RotEncMoved","RotEncMoved");
		serialCommands.put("RotEncClick","select");
		serialCommands.put("b1Down","pageBack");
		serialCommands.put("b1Up","");
		serialCommands.put("b2Down","pageUp");
		serialCommands.put("b2Up","");
		serialCommands.put("b3Down","pageDown");
		serialCommands.put("b3Up","");
		serialCommands.put("b4Down","ok");
		serialCommands.put("b4Up","");
	}
	public void processMessage(String inString){
		String key ="";
		int value =0;
		if(inString.lastIndexOf(":")!=-1){
			key =inString.substring(0,inString.lastIndexOf(":"));
			value =Integer.parseInt(inString.substring(inString.lastIndexOf(":")+1));
		} else{
			key = inString;
		}
		if(serialCommands.get(key) instanceof String){
			String serialCommand = (String)serialCommands.get(key);
			if(serialCommand.equals("PIROn")){
				sendPIROn();
			} else if(serialCommand.equals("PIROff")){
				sendPIROff();
			} else if(serialCommand.equals("Temp")){
				sendTempLevel(value);
			} else if(serialCommand.equals("Light")){
				sendLightLevel(value);
			} else if(serialCommand.equals("RotEncMoved")){
				bg.rotEncChange(value);
			} else if(serialCommand.equals("select")){
				bg.select();
			} else if(serialCommand.equals("ok")){
				bg.ok();
			} else if(serialCommand.equals("pageBack")){
				bg.backPage();
			} else if(serialCommand.equals("pageDown")){
				bg.downButton();
			} else if(serialCommand.equals("pageUp")){
				bg.upButton();
			} else{
				//System.err.println("Do Nothing");
			}		
		} else if(serialCommands.get(key) instanceof Command){
			sendElifeCommand((Command)serialCommands.get(key));
		} else{
			//System.err.println(inString);
		}
	}
	private void sendPIROn(){
		Command newCommand = new Command();
		newCommand.setKey("ELIFE_ACTIVE1_PIR");
		newCommand.setCommand("ON");
		serverHandle.sendToServer(newCommand);
	}
	private void sendPIROff(){
		Command newCommand = new Command();
		newCommand.setKey("ELIFE_ACTIVE1_PIR");
		newCommand.setCommand("OFF");
		serverHandle.sendToServer(newCommand);
	}
	private void sendLightLevel(int value){
		Command newCommand = new Command();
		newCommand.setKey("ELIFE_ACTIVE1_PIR");
		newCommand.setCommand("LIGHTLEVEL");
		newCommand.setExtraInfo(value+"");
		serverHandle.sendToServer(newCommand);
	}
	private void sendTempLevel(int value){
		Command newCommand = new Command();
		newCommand.setKey("ELIFE_ACTIVE1_PIR");
		newCommand.setCommand("TEMPERATURE");
		newCommand.setExtraInfo(value+"");
		serverHandle.sendToServer(newCommand);
	}
	private void sendElifeCommand(Command inCommand){
		serverHandle.sendToServer(inCommand);
	}
	public void sendSerialMessage(String inString){
		if(commsObject != null){
			commsObject.incomingSerial(inString);
		}		
	}
	public void setSerialCommsObject(SerialCommsObject inObject){
		 commsObject = inObject;
	}
	
}
