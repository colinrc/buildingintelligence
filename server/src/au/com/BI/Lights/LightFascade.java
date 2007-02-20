/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Lights;
import au.com.BI.Util.*;
import au.com.BI.X10.*;
import au.com.BI.CBUS.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Dynalite.*;
import java.util.*;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 * @see au.com.BI.Util.DeviceType;
 *
*/

public class LightFascade implements  DeviceType,CBUSDevice,LightDevice,DynaliteDevice {
	protected BaseDevice light = null;
	protected String deviceName;
	protected boolean generateDimmerVals = false;

	public LightFascade (String name, int deviceType,String deviceName){
		if (deviceName == null)
			this.deviceName = "";
		else
			this.deviceName = deviceName;

		if (deviceType == DeviceType.COMFORT_LIGHT_X10 || deviceType == DeviceType.COMFORT_LIGHT_X10_UNITCODE)
			light = new X10(name, deviceType);

		if (deviceType == DeviceType.LIGHT_CBUS ){
			this.setMax("255");
			light = new CBUS(name,deviceType);
		}
	
		if (deviceType == DeviceType.LIGHT_DYNALITE ){
			light = new Dynalite(name, deviceType);
		}
		if (deviceType == DeviceType.LIGHT_DYNALITE_AREA ){
			light = new LightArea(name, deviceType);
		}
		if (light == null) {
			light = new Light(name, deviceType);
		}

	}
	
	/**
	 * @return Returns if the device represents an area instead of a channel
	 */
	public boolean isAreaDevice( ) {
		if (light.getDeviceType() == DeviceType.LIGHT_CBUS ){
			return ((CBUSDevice)light).isAreaDevice();
		}
	
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			return false;
		}
		
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE_AREA ){
			return true;
		}

		return false;
	}

	/**
	 * @return Returns if the device represents an area instead of a channel
	 */
	public void setAreaDevice( boolean areaFlag) {
		if (light.getDeviceType() == DeviceType.LIGHT_CBUS ){
			((CBUS)light).setAreaDevice(areaFlag);
		}
	
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			((DynaliteDevice)light).setAreaDevice(areaFlag);
		}
	}

	public LightFascade (String name, int deviceType, String outputKey,String deviceName){
		this (name,deviceType,deviceName);
		light.setOutputKey(outputKey);
	}
	
	public boolean supportsLevelMMI () {
		if (light.getDeviceType() == DeviceType.LIGHT_CBUS && !((CBUSDevice)light).isRelay()) 
			return ((CBUSDevice)light).supportsLevelMMI();
		else 
			return false;
	}

	public boolean keepStateForStartup () {
		if (light.getDeviceType() == DeviceType.TOGGLE_OUTPUT  ||
				light.getDeviceType() == DeviceType.LIGHT_CBUS )
			return false;
		else
			return true;
	}
	/**
	 * @return Returns the rawCodes.
	 */
	public final Map getRawCodes() {
		return light.getRawCodes();
	}
	/**
	 * @param rawCodes The rawCodes to set.
	 */
	public final void setRawCodes(Map rawCodes) {
		light.setRawCodes (rawCodes);
	}
	public void setKey (String originalKey) {
		light.setKey (originalKey);
		try {
			if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE) 
				((DynaliteDevice)light).setChannel(Integer.parseInt(originalKey,16));
		} catch (NumberFormatException ex) {
		}
	}
	public String getKey (){
		return light.getKey();
	}

	public int getChannel () {
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE) 
			return ((DynaliteDevice)light).getChannel();
		else
			return 0;
	}

	/**
	 * @return Returns the x10HouseCode.
	 */
	public String getX10HouseCode() {
		return ((X10)light).getX10HouseCode();
	}
	/**
	 * @param houseCode The x10HouseCode to set.
	 */
	public void setX10HouseCode(String houseCode) {
		((X10)light).setX10HouseCode(houseCode);
	}

	public int getDeviceType () {
		return light.getDeviceType();
	}

	/**
	 * Builds a display command
	 * @return The command
	 * @see LightCommand
	 */
	public CommandInterface buildDisplayCommand () {
		return light.buildDisplayCommand ();
	}

	public final String getName () {
		return light.getName();
	}

	public String getCommand (){
		return light.getCommand();
	}

	public void setChannel (int channel) {
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE) 
			((DynaliteDevice)light).setChannel(channel);
		
	}
	/**
	 * @return Returns the outputKey.
	 */
	public final String getOutputKey()
	{
		return light.getOutputKey();
	}

	/**
	 * @param outputKey The outputKey to set.
	 */
	public final void setOutputKey(String outputKey)
	{
		light.setOutputKey(outputKey);
	}


	/**
	 * @param command The command to set.
	 */
	public final void setCommand(String command)
	{
		light.setCommand(command);
	}

	/**
	 * @param deviceType The deviceType to set.
	 */
	public final void setDeviceType(int deviceType)
	{
		this.setDeviceType (deviceType);
	}

	/**
	 * @param name The name to set.
	 */
	public final void setName(String name)
	{
		this.setName(name);
	}

	/**
	 * Return the client display command for the light.
	 * For a light this is the same as the interpretted command
	 */
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}

	/**
	 * @return Returns the applicationCode.
	 */
	public String getApplicationCode() {
		return ((CBUSDevice)light).getApplicationCode();
	}

	
	public void setRelay(String relay) {
		boolean relayVal = false;
		if (relay == null || relay.equals("N"))
			relayVal = false;
		else
			relayVal = true;
				
		if (light.getDeviceType() == DeviceType.LIGHT_CBUS ){
			((CBUS)light).setRelay(relayVal);
		}
	
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE  || light.getDeviceType() == DeviceType.LIGHT_DYNALITE_AREA){
			((Dynalite)light).setRelay(relayVal);
		}

	}
	
	/**
	 * @return Returns the relay value
	 */
	public boolean  isRelay() {
		return ((LightDevice)light).isRelay();
	}
	/**
	 * @param areaCode The areaCode to set.
	 */
	public void setAreaCode(String areaCode) {
		if (light.getDeviceType() != DeviceType.LIGHT_DYNALITE) return;
		String localCode = areaCode;
		if (localCode == null) localCode = "01";
		if (localCode.length() == 1) localCode = "0" + localCode;
		((DynaliteDevice)light).setAreaCode(localCode);
	}
	/**
	 * @param areaCode The areaCode to get.
	 */
	public String getAreaCode() {
		if (light.getDeviceType() != DeviceType.LIGHT_DYNALITE) return "";
		return ((DynaliteDevice)light).getAreaCode();
	}
	/**
	 * @param applicationCode The applicationCode to set.
	 */
	public void setApplicationCode(String applicationCode) {
		if (light.getDeviceType() != DeviceType.LIGHT_CBUS) return;
		String localCode = applicationCode;
		if (localCode == null) localCode = "38";
		if (localCode.length() == 1) localCode = "0" + localCode;
		((CBUSDevice)light).setApplicationCode(localCode);
	}
	/**
	 * @param max The Maximum level that will be sent by the device (usually 100 or 255)
	 */
	public void setMax(String max) {
		if (light != null && light.getDeviceType() == DeviceType.LIGHT_CBUS){
			int maxLevel = 100;
			if (max != null) {
				try {
					maxLevel = Integer.parseInt(max);
				} catch (NumberFormatException ex) {
					maxLevel = 100;
				}
			}
			((LightDevice)light).setMax(maxLevel);
		}
	}

	public int getMax () {
			return ((LightDevice)light).getMax();
	}

	public void setMax (int max) {
		 ((LightDevice)light).setMax(max);
	}
	
	public String getMaxStr () {
		return Integer.toString(((LightDevice)light).getMax());
	}

	public void setGroupName (String groupName) {
		light.setGroupName(groupName);
	}

	public String getGroupName () {
		return light.getGroupName();
	}

	public boolean isContinueAfterMatch () {
	    return false;
	}
	
	public String getBLA() {
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			return ((Dynalite)light).getBLA();
		}
		
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE_AREA ){
			return ((Dynalite)light).getBLA();
		}
		
		return "";
	}
	
	public void setBLA(String bLA){
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			((Dynalite)light).setBLA(bLA);
		}
		
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE_AREA ){
			((LightArea)light).setBLA(bLA);
		}
		
	}
	
	
	public int listensToLinkArea (int linkOffset) {
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			return ((Dynalite)light).listensToLinkArea ( linkOffset);
		}		
		return 255;
	}

	public boolean isLinked() {
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			return ((Dynalite)light).isLinked ( );
		}		
		return false;
	}

	public void incLinkCount() {
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			((Dynalite)light).incLinkCount ( );
		}		
	}

	public void decLinkCount() {
		if (light.getDeviceType() == DeviceType.LIGHT_DYNALITE ){
			((Dynalite)light).decLinkCount ( );
		}		
	}

	public boolean isGenerateDimmerVals() {
		if (light.getDeviceType() == DeviceType.LIGHT_CBUS ){
			return ((CBUS)light).isGenerateDimmerVals();
		}
		return false;
	}

	public void  setGenerateDimmerVals(boolean generateDimmerVals) {
		if (light.getDeviceType() == DeviceType.LIGHT_CBUS ){
			 ((CBUS)light).setGenerateDimmerVals(generateDimmerVals);
		}
	}

}
