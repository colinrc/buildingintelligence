/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Camera;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Merik Karmen
 *
 **/
public class Camera extends BaseDevice implements DeviceType
{
	protected String name="";
	protected String command="";
	protected String zoom="";
	protected int zoomInt = 0;
	
	public Camera (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}

	public String getCommand () {
		return command;
	}

	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		CameraCommand alertCommand = new CameraCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}
	
	public String getZoom() {
		if (zoom == null)
			return "";
		else
			return zoom;
	}
	
	
	public int getZoomInt() {

			return zoomInt;
	}
	
	public void setZoom(String zoom) throws NumberFormatException {
		this.zoom = zoom;
		if (zoom == null){
			zoom = "";
			zoomInt = 0;
		} else {
			zoomInt = 0;
			zoomInt = Integer.parseInt(zoom,16);
		}
	}

}
