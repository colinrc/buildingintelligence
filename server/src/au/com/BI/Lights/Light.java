/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Lights;
import au.com.BI.Util.*;
import au.com.BI.Command.*;


/**
 * @author Colin Canfield
 *
 **/
public class Light extends BaseDevice implements LightDevice
{
	protected String relay;

	protected int max = 255;
	
	public Light (String name, int deviceType){
		this.name = name;
		this.deviceType = deviceType;
		this.command = "";
		this.outputKey = "";

	}
	
	/**
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		LightCommand lightCommand = new LightCommand ();
		lightCommand.setDisplayName(getOutputKey());
		return lightCommand;
	}

	public void setRelay(String relay) {
		this.relay = relay;
	}

	public String getRelay() {
		return relay;
	}
	
	public int getMax() {
		return max;
	}

	public void setMax(int max) {
		this.max = max;
	}


}
