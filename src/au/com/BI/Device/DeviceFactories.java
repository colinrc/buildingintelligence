/**
 * 
 */
package au.com.BI.Device;

import au.com.BI.AV.AVFactory;
import au.com.BI.Alert.AlertFactory;
import au.com.BI.Analog.AnalogFactory;
import au.com.BI.Audio.AudioFactory;
import au.com.BI.Camera.CameraFactory;
import au.com.BI.Counter.CounterFactory;
import au.com.BI.CustomConnect.CustomConnectFactory;
import au.com.BI.CustomInput.CustomInputFactory;
import au.com.BI.IR.IRFactory;
import au.com.BI.Label.LabelFactory;
import au.com.BI.Lights.LightFactory;
import au.com.BI.MultiMedia.AutonomicHome.Device.WindowsMediaExtenderFactory;
import au.com.BI.PulseOutput.PulseOutputFactory;
import au.com.BI.Pump.PumpFactory;
import au.com.BI.Heater.HeaterFactory;
import au.com.BI.Raw.RawFactory;
import au.com.BI.SMS.SMSFactory;
import au.com.BI.Sensors.SensorFactory;
import au.com.BI.Thermostat.ThermostatFactory;
import au.com.BI.ToggleSwitch.ToggleSwitchFactory;
import au.com.BI.Unit.UnitFactory;
import au.com.BI.Util.DeviceModel;
import au.com.BI.VirtualOutput.VirtualOutputFactory;

/**
 * @author colin
 *
 */
public class DeviceFactories {
	
	public LightFactory lightFactory;		
	public SensorFactory sensorFactory;		
	public SMSFactory smsFactory;		
	public ToggleSwitchFactory toggleSwitchFactory;		
	public CustomConnectFactory customConnectFactory;
	public AVFactory aVFactory;		
	public AudioFactory audioFactory;		
	public PulseOutputFactory pulseOutputFactory;		
	public VirtualOutputFactory virtualOutputFactory;		
	public CameraFactory cameraFactory;		
	public LabelFactory labelFactory;
	public CustomInputFactory customInputFactory;		
	public CounterFactory counterFactory;		
	public AlertFactory alertFactory;		
	public RawFactory rawFactory;		
	public AnalogFactory analogFactory;		
	public PumpFactory pumpFactory;		
	public HeaterFactory heaterFactory;		
	public UnitFactory unitFactory;		
	public IRFactory iRFactory;
	public ThermostatFactory thermostatFactory;
	public WindowsMediaExtenderFactory windowsMediaExtenderFactory;
	
	public DeviceFactories () {
		lightFactory = new LightFactory() ;

		this.setSensorFactory ( SensorFactory.getInstance()) ;		
		this.setToggleSwitchFactory ( ToggleSwitchFactory.getInstance()) ;		
		this.setAVFactory(AVFactory.getInstance()) ;		
		this.setAudioFactory(AudioFactory.getInstance());		
		this.setPulseOutputFactory(PulseOutputFactory.getInstance());		
		this.setVirtualOutputFactory ( VirtualOutputFactory.getInstance());	
		this.setCameraFactory ( CameraFactory.getInstance());		
		this.setCustomInputFactory ( CustomInputFactory.getInstance());		
		this.setCounterFactory (  CounterFactory.getInstance());	
		this.setAlertFactory (AlertFactory.getInstance());		
		this.setRawFactory (RawFactory.getInstance());		
		this.setAnalogFactory ( AnalogFactory.getInstance());		
		this.setPumpFactory ( PumpFactory.getInstance());	
		this.setHeaterFactory ( HeaterFactory.getInstance());	
		this.setIRFactory (IRFactory.getInstance());		
		this.setSmsFactory(SMSFactory.getInstance());
		this.setLabelFactory (LabelFactory.getInstance());
		this.setCustomConnectFactory(CustomConnectFactory.getInstance());
		this.setThermostatFactory(ThermostatFactory.getInstance());
		this.setUnitFactory(UnitFactory.getInstance());
		this.setWindowsMediaExtenderFactory(WindowsMediaExtenderFactory.getInstance());
	}
	
	public void addStringAttribute ( DeviceModel deviceModel, int deviceType, String attributeName, boolean mandatory){
		switch (deviceType){
		case DeviceType.TOGGLE_OUTPUT : 
			toggleSwitchFactory.addDeviceAttribute(deviceModel, attributeName, mandatory);
			break;

		case DeviceType.PULSE_OUTPUT : 
			pulseOutputFactory.addDeviceAttribute(deviceModel, attributeName, mandatory);
			break;

		case DeviceType.LIGHT : 
			lightFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.LIGHT_CBUS : 
			lightFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.LIGHT_DYNALITE : 
			lightFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.LIGHT_DYNALITE_AREA : 
			lightFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.COMFORT_LIGHT_X10_UNITCODE : 
			lightFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.SENSOR : 
			sensorFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.TEMPERATURE : 
			sensorFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.PUMP : 
			pumpFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.TOGGLE_INPUT : 
			toggleSwitchFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.CONTACT_CLOSURE : 
			toggleSwitchFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.TOGGLE_OUTPUT_MONITOR : 
			toggleSwitchFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.COUNTER : 
			counterFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.VIRTUAL_OUTPUT : 
			virtualOutputFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.LABEL : 
			labelFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.RAW_INTERFACE : 
			rawFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.CUSTOM_INPUT : 
			customInputFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.IR : 
			iRFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.AUDIO : 
			audioFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.AV : 
			aVFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.CAMERA : 
			cameraFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.ANALOGUE : 
			analogFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.ALERT : 
			alertFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.ALARM : 
			alertFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.SMS : 
			smsFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;
			
		case DeviceType.CUSTOM_CONNECT : 
			customConnectFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.THERMOSTAT : 
			thermostatFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;
			
		case DeviceType.UNIT : 
			unitFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;

		case DeviceType.WINDOWS_MEDIA_EXTENDER : 
			windowsMediaExtenderFactory.addDeviceAttribute(deviceModel, attributeName,mandatory);
			break;
		}
	}
	
	public void setAlertFactory(AlertFactory alertFactory) {
		this.alertFactory = alertFactory;
	}

	public void setAnalogFactory(AnalogFactory analogFactory) {
		this.analogFactory = analogFactory;
	}

	public void setAudioFactory(AudioFactory audioFactory) {
		this.audioFactory = audioFactory;
	}

	public void setAVFactory(AVFactory factory) {
		aVFactory = factory;
	}

	public void setCameraFactory(CameraFactory cameraFactory) {
		this.cameraFactory = cameraFactory;
	}

	public void setCounterFactory(CounterFactory counterFactory) {
		this.counterFactory = counterFactory;
	}

	public void setCustomInputFactory(CustomInputFactory customInputFactory) {
		this.customInputFactory = customInputFactory;
	}

	public void setIRFactory(IRFactory factory) {
		iRFactory = factory;
	}

	public void setLightFactory(LightFactory lightFactory) {
		this.lightFactory = lightFactory;
	}

	public void setPulseOutputFactory(PulseOutputFactory pulseOutputFactory) {
		this.pulseOutputFactory = pulseOutputFactory;
	}

	public void setRawFactory(RawFactory rawFactory) {
		this.rawFactory = rawFactory;
	}

	public void setSensorFactory(SensorFactory sensorFactory) {
		this.sensorFactory = sensorFactory;
	}

	public void setToggleSwitchFactory(ToggleSwitchFactory toggleSwitchFactory) {
		this.toggleSwitchFactory = toggleSwitchFactory;
	}

	public void setVirtualOutputFactory(VirtualOutputFactory virtualOutputFactory) {
		this.virtualOutputFactory = virtualOutputFactory;
	}

	public CustomConnectFactory getCustomConnectFactory() {
		return customConnectFactory;
	}

	public void setCustomConnectFactory(CustomConnectFactory customConnectFactory) {
		this.customConnectFactory = customConnectFactory;
	}

	public ThermostatFactory getThermostatFactory() {
		return thermostatFactory;
	}

	public void setThermostatFactory(ThermostatFactory thermostatFactory) {
		this.thermostatFactory = thermostatFactory;
	}

	public SMSFactory getSmsFactory() {
		return smsFactory;
	}

	public void setSmsFactory(SMSFactory smsFactory) {
		this.smsFactory = smsFactory;
	}

	public LabelFactory getLabelFactory() {
		return labelFactory;
	}

	public void setLabelFactory(LabelFactory labelFactory) {
		this.labelFactory = labelFactory;
	}
	public WindowsMediaExtenderFactory getWindowsMediaExtenderFactory() {
		return windowsMediaExtenderFactory;
	}

	public void setWindowsMediaExtenderFactory(
			WindowsMediaExtenderFactory windowsMediaExtenderFactory) {
		this.windowsMediaExtenderFactory = windowsMediaExtenderFactory;
	}
	
	public PumpFactory getPumpFactory() {
		return pumpFactory;
	}

	public void setPumpFactory(PumpFactory pumpFactory) {
		this.pumpFactory = pumpFactory;
	}
	
	public void setHeaterFactory(HeaterFactory heaterFactory) {
		this.heaterFactory = heaterFactory;
	}

	public UnitFactory getUnitFactory() {
		return unitFactory;
	}

	public void setUnitFactory(UnitFactory unitFactory) {
		this.unitFactory = unitFactory;
	}
}
