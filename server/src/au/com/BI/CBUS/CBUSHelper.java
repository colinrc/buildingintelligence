/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.CBUS;


/**
 * @author colinc
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class CBUSHelper {
	public String buildKey (String appCode, String groupCode) {
		if (groupCode.length() == 1 ) groupCode = "0" + groupCode;
		String resultKey = appCode + ":" + groupCode;
		return resultKey.toUpperCase();
	}
	
	public String buildKey (String appCode, int groupCode) {
		return buildKey (appCode,Integer.toHexString(groupCode));
	}

}
