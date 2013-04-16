package au.com.BI.MultiMedia.SlimServer.Device;

import au.com.BI.Device.DeviceType;
import au.com.BI.Util.BaseDevice;

/**
 * Represents a squeeze box (http://www.slimdevices.com).
 * @author David Cummins
 *
 */
public class SqueezeBox extends BaseDevice implements DeviceType {

	public SqueezeBox() {
		super();
	}
	
	public SqueezeBox(String name, int deviceType, String outputKey) {
		super(name, deviceType, outputKey);
	}
	
	public SqueezeBox(String name, int deviceType) {
		super(name, deviceType);
	}

	public boolean keepStateForStartup() {
		return false;
	}
}
