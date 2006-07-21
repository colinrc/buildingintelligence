/**
 * 
 */
package au.com.BI.GroovyModels;
import au.com.BI.AV.AV;
import au.com.BI.Alert.Alarm;
import au.com.BI.Alert.Alert;
import au.com.BI.Analog.Analog;
import au.com.BI.Audio.Audio;
import au.com.BI.Camera.Camera;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Lights.LightFascade;
import au.com.BI.PulseOutput.PulseOutput;
import au.com.BI.Sensors.Sensor;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.BaseModel;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import au.com.BI.Util.SetupException;

import java.util.logging.*;
/**
 * @author colin
 * @todo Add startup,poling, ETX  and  processing instructions from the device.
 */
public class GroovyModel extends BaseModel implements DeviceModel {
	protected String appendToSentStrings = "";

	
	public GroovyModel (){
		super();
	}
	
	public void finishedReadingConfig()throws SetupException  {
		super.finishedReadingConfig();
	}
	
	
	/*
	 * This function is called on model startup. The pattern will be similar to the doOutputItem below, and will contain a hook for a general whole of device sartup
	 * @see au.com.BI.Util.BaseModel#doStartup()
	 */
	public void doStartup () throws CommsFail {
		
	}
	

	public void doControlledItem () throws CommsFail {
		
	}
	 
	/*
	 * This function is called on model startup. The pattern will be similar to the doOutputItem below, and will contain a hook for a general whole of device sartup
	 * @see au.com.BI.Util.BaseModel#doOutputItem()
	 */
	public void doOutputItem(CommandInterface command) throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper ();

		
		try {
			decodeOutputItem (command, returnWrapper);
			addCheckSums(returnWrapper);
			
			if ( !returnWrapper.isError()) {
				if (returnWrapper.isMessageIsBytes()){
				    for(byte[] avOutputString : returnWrapper.getCommOutputBytes()) {			
				    		this.sendToSerial(avOutputString);
					}
				} else {
				    for(String avOutputString : returnWrapper.getCommOutputStrings()) {			
				    	this.sendToSerial(avOutputString + this.getAppendToSentStrings());
						if (logger.isLoggable(Level.FINE)){
							logger.log(Level.FINE,"Sending a command to the device controlled by " + this.getName() + " " + avOutputString);
						}
					}					
				}
			    
				for (CommandInterface eachCommand: returnWrapper.getOutputFlash()){
					this.sendToFlash(eachCommand, cache);
				}

			} else {
				if (returnWrapper != null){
					logger.log (Level.WARNING,"There was error processing the message in the " + this.getName() + " support module." + returnWrapper.getErrorDescription());
				}
			}
			


		} catch (GroovyModelException ex){
			logger.log (Level.WARNING,"An error occured in " + this.getName() +" support " + ex.getMessage());
		}
		
	}
	
	public void decodeOutputItem(CommandInterface command,ReturnWrapper returnWrapper) throws GroovyModelException  {
		
		DeviceType device = configHelper.getOutputItem(command.getKey());
		try {
			switch (device.getDeviceType()){
					case DeviceType.ANALOGUE: 
						logger.log (Level.INFO, "A command for an analog device was issued from " + device.getName());
						 buildAnalogControlString ((Analog)device,command,returnWrapper);
						break;
				
					case DeviceType.AUDIO: 
						logger.log (Level.INFO, "A command for an Audio device was issued from " + device.getName());
						buildAudioControlString ((Audio)device,command,returnWrapper);
						break;
						
					case DeviceType.AV: 
						logger.log (Level.INFO, "A command for an AV device was issued from " + device.getName());
						buildAVControlString ((AV)device,command,returnWrapper);
						break;
						
					case DeviceType.LIGHT: 
						logger.log (Level.INFO, "A command for a Lighting device was issued from " + device.getName()+ " for the model " + this.getName());
						buildLightString ((LightFascade)device,command,returnWrapper);
						break;
						
					case DeviceType.SENSOR: 
						logger.log (Level.INFO, "A command for a Sensor device was issued from " + device.getName());
						buildSensorControlString ((Sensor)device,command,returnWrapper);
						break;
						
					case DeviceType.ALARM: 
						logger.log (Level.INFO, "A command for an Alarm  was issued from " + device.getName());
						buildAlarmControlString ((Alarm)device,command,returnWrapper);
						break;
						
					case DeviceType.ALERT: 
						logger.log (Level.INFO, "A command for an Alert device was issued from " + device.getName());
						buildAlertControlString ((Alert)device,command,returnWrapper);
						break;
						
					case DeviceType.PULSE_OUTPUT: 
						logger.log (Level.INFO, "A command for a Pulse Output  was issued from " + device.getName());
						buildPulseOutputControlString ((PulseOutput)device,command,returnWrapper);
						break;
						
					case DeviceType.CAMERA: 
						logger.log (Level.INFO, "A command for a Camera device was issued from " + device.getName() + " for the model " + this.getName());
						buildCameraControlString ((Camera)device,command,returnWrapper);
						break;
						
					case DeviceType.TOGGLE_OUTPUT: 
						logger.log (Level.INFO, "A command for an Output Toggle device was issued from " + device.getName() + " for the model " + this.getName());
						buildToggleOutputControlString ((ToggleSwitch)device,command,returnWrapper);
						break;
			}
			

		    
		} catch (ClassCastException ex){
			logger.log(Level.SEVERE,"An internal error has occured in support for " + this.getName() + " ,please contact your integrator " + ex.getMessage());
		}		

	}
	
	public void addCheckSums (ReturnWrapper returnWrapper){
		if (returnWrapper.isMessageIsBytes()){
		    for(byte[] avOutputString : returnWrapper.getCommOutputBytes()) {			
		    	addCheckSum (avOutputString);
			}
		} else {
		    for(String avOutputString : returnWrapper.getCommOutputStrings()) {			
		    	addCheckSum (avOutputString.getBytes());
			}
		}
	}
	
	public void addCheckSum (byte returnVal[]){
		
	}

	public void  buildAnalogControlString (Analog device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildAudioControlString (Audio device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildAVControlString (AV device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildLightString (LightFascade device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildSensorControlString (Sensor device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void  buildAlarmControlString (Alarm device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildAlertControlString (Alert  device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildPulseOutputControlString (PulseOutput  device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildCameraControlString (Camera  device, CommandInterface command, ReturnWrapper returnWrapper){
	}
	
	public void buildToggleOutputControlString (ToggleSwitch  device, CommandInterface command, ReturnWrapper returnWrapper){
	}

	public String getAppendToSentStrings() {
		return appendToSentStrings;
	}

	public void setAppendToSentStrings(String endString) {
		this.appendToSentStrings = endString;
	}
	
	
}
