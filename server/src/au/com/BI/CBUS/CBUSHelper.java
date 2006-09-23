/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.CBUS;

import au.com.BI.Device.DeviceType;


/**
 * @author colinc
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class CBUSHelper {

	
	public String buildKey (String appCode, String groupCode, int deviceType) {
		if (groupCode.length() == 1 ) groupCode = "0" + groupCode;
		String resultKey = appCode + ":" + groupCode;
		if (deviceType == DeviceType.LABEL) resultKey = "L:" + resultKey;
		return resultKey.toUpperCase();
	}
	
	public String buildKey (String appCode, int groupCode, int deviceType) {
		return buildKey (appCode,Integer.toHexString(groupCode), deviceType);
	}

}
