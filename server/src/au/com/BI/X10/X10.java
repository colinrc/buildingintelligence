/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.X10;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Lights.*;

/**
 * @author Colin Canfield
 *
 **/
public class X10 extends BaseDevice implements LightDevice 
{

	protected String X10HouseCode="";
	protected boolean relay= false;
	
	public X10 () {
		super();
	}
	
	public int getMax () {
		return 0;
	}
	
	public void setMax (int max){}
	
	public X10 (String name, int deviceType){
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
		X10Command x10Command = new X10Command ();
		x10Command.setDisplayName(getOutputKey());
		return x10Command;
	}
	

	/**
	 * @return Returns the x10HouseCode.
	 */
	public String getX10HouseCode() {
		return X10HouseCode;
	}
	/**
	 * @param houseCode The x10HouseCode to set.
	 */
	public void setX10HouseCode(String houseCode) {
		X10HouseCode = houseCode;
	}

	public boolean isRelay() {
		return relay;
	}

	public void setRelay(boolean relay) {
		this.relay = relay;
	}


}
