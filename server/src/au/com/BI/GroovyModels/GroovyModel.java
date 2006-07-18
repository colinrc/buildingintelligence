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
import au.com.BI.Util.BaseModel;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;

/**
 * @author colin
 *
 */
public class GroovyModel extends BaseModel implements DeviceModel {
	
	public void doOutputItem(CommandInterface command) throws CommsFail {
		byte outputArray[] = null;
		
		DeviceType device = configHelper.getOutputItem(command.getDisplayName());
		
			switch (device.getDeviceType()){
					case DeviceType.ANALOGUE: 
						outputArray = buildAnalogControlString ((Analog)device,command);
						break;
				
					case DeviceType.AUDIO: 
						outputArray = buildAudioControlString ((Audio)device,command);
						break;
						
					case DeviceType.AV: 
						outputArray = buildAVControlString ((AV)device,command);
						break;
						
					case DeviceType.LIGHT: 
						outputArray = buildLightString ((LightFascade)device,command);
						break;
						
					case DeviceType.SENSOR: 
						outputArray = buildSensorControlString ((Sensor)device,command);
						break;
						
					case DeviceType.ALARM: 
						outputArray = buildAlarmControlString ((Alarm)device,command);
						break;
						
					case DeviceType.ALERT: 
						outputArray = buildAlertControlString ((Alert)device,command);
						break;
						
					case DeviceType.PULSE_OUTPUT: 
						outputArray = buildPulseOutputControlString ((PulseOutput)device,command);
						break;
						
					case DeviceType.CAMERA: 
						outputArray = buildCameraControlString ((Camera)device,command);
						break;
			}
			
			if (outputArray != null){
				addCheckSum (outputArray);
			}
			comms.sendString(outputArray);
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
}
