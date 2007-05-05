/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.CBUS;


/**
 * @author colinc
 *
 */
public class CBUSHelper {

	
	public String buildKey (String appCode, String groupCode, int deviceType) {
		if (groupCode.length() == 1 ) groupCode = "0" + groupCode;
		String resultKey = appCode + ":" + groupCode;
		// if (deviceType == DeviceType.LABEL) resultKey = "L:" + resultKey;
		return resultKey.toUpperCase();
	}
	
	public String buildKey (String appCode, int groupCode, int deviceType) {
		return buildKey (appCode,Integer.toHexString(groupCode), deviceType);
	}

}
