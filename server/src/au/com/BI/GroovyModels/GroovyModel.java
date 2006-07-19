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
import au.com.BI.Comms.CommsFail;
import au.com.BI.Lights.LightFascade;
import au.com.BI.PulseOutput.PulseOutput;
import au.com.BI.Sensors.Sensor;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.BaseModel;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import java.util.logging.*;
/**
 * @author colin
 * @todo Add startup,poling, ETX ,logging and  processing instructions from the device.
 */
public class GroovyModel extends BaseModel implements DeviceModel {
	protected String appendToSentStrings = "";
	
	public GroovyModel (){
		super();
	}
	
	public void doOutputItem(CommandInterface command) throws CommsFail {
		byte outputArray[] = null;
		
		DeviceType device = configHelper.getOutputItem(command.getKey());
		try {
			switch (device.getDeviceType()){
					case DeviceType.ANALOGUE: 
						logger.log (Level.INFO, "A command for an analog device was issued from " + device.getName());
						outputArray = buildAnalogControlString ((Analog)device,command);
						break;
				
					case DeviceType.AUDIO: 
						logger.log (Level.INFO, "A command for an Audio device was issued from " + device.getName());
						outputArray = buildAudioControlString ((Audio)device,command);
						break;
						
					case DeviceType.AV: 
						logger.log (Level.INFO, "A command for an AV device was issued from " + device.getName());
						outputArray = buildAVControlString ((AV)device,command);
						break;
						
					case DeviceType.LIGHT: 
						logger.log (Level.INFO, "A command for a Lighting device was issued from " + device.getName()+ " for the model " + this.getName());
						outputArray = buildLightString ((LightFascade)device,command);
						break;
						
					case DeviceType.SENSOR: 
						logger.log (Level.INFO, "A command for a Sensor device was issued from " + device.getName());
						outputArray = buildSensorControlString ((Sensor)device,command);
						break;
						
					case DeviceType.ALARM: 
						logger.log (Level.INFO, "A command for an Alarm  was issued from " + device.getName());
						outputArray = buildAlarmControlString ((Alarm)device,command);
						break;
						
					case DeviceType.ALERT: 
						logger.log (Level.INFO, "A command for an Alert device was issued from " + device.getName());
						outputArray = buildAlertControlString ((Alert)device,command);
						break;
						
					case DeviceType.PULSE_OUTPUT: 
						logger.log (Level.INFO, "A command for a Pulse Output  was issued from " + device.getName());
						outputArray = buildPulseOutputControlString ((PulseOutput)device,command);
						break;
						
					case DeviceType.CAMERA: 
						logger.log (Level.INFO, "A command for a Camera device was issued from " + device.getName() + " for the model " + this.getName());
						outputArray = buildCameraControlString ((Camera)device,command);
						break;
						
					case DeviceType.TOGGLE_OUTPUT: 
						logger.log (Level.INFO, "A command for an Output Toggle device was issued from " + device.getName() + " for the model " + this.getName());
						outputArray = buildToggleOutputControlString ((ToggleSwitch)device,command);
						break;
			}
		} catch (ClassCastException ex){
			logger.log(Level.SEVERE,"An internal error has occured, please contact your integrator " + ex.getMessage());
		}
			
		if (outputArray != null){
			addCheckSum (outputArray);
		}
		if (logger.isLoggable(Level.FINE)){
			logger.log(Level.FINE,"Sending a command to the device controlled by " + this.getName() + " " + new String(outputArray));
		}
		comms.sendString(outputArray + this.getAppendToSentStrings());
	}
	
	public void addCheckSum (byte outputArray[]){
		
	}

	public byte[] buildAnalogControlString (Analog device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildAudioControlString (Audio device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildAVControlString (AV device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildLightString (LightFascade device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildSensorControlString (Sensor device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildAlarmControlString (Alarm device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildAlertControlString (Alert  device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildPulseOutputControlString (PulseOutput  device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildCameraControlString (Camera  device, CommandInterface command){
		return "".getBytes();
	}
	
	public byte[] buildToggleOutputControlString (ToggleSwitch  device, CommandInterface command){
		return "".getBytes();
	}

	public String getAppendToSentStrings() {
		return appendToSentStrings;
	}

	public void setAppendToSentStrings(String endString) {
		this.appendToSentStrings = endString;
	}
	
	
}
