/**
 * 
 */
package au.com.BI.Jetty;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Set;

import org.mortbay.jetty.Request;
import org.mortbay.jetty.Response;
import org.mortbay.jetty.security.SecurityHandler;

/**
 * @author colin
 *
 */
public class ELifeSecurityHandler extends  SecurityHandler  {
	HashMap <String,Boolean> allowedIPs;
	
	public  ELifeSecurityHandler () {
		allowedIPs = new HashMap<String,Boolean>();
		// allowedIPs.put ("127.0.0.1",true);
	}
	
	public boolean checkSecurityConstraints(String pathInContext, Request request, Response response) {
		String callingIP = request.getRemoteAddr();
		
		if (allowedIPs.containsKey( callingIP))  {
			return true;
		} else {
			return checkSecurityConstraints( pathInContext,  request,  response); 
		}
	}

	public Set<String> getAllowedIPs() {
		return allowedIPs.keySet();
	}

	public void setAllowedIPs(LinkedList<String> allowedIPList) {
		for (String i: allowedIPList){
			allowedIPs.put(i, true);
		}
	}
	
	public void parseFile (String fileName, String pathName, String parentName) throws IPConfigException {
		
	}
	
}
