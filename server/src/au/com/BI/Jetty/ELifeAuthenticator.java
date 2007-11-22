/**
 * 
 */
package au.com.BI.Jetty;

import java.io.IOException;
import java.security.Principal;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Set;

import org.mortbay.jetty.Request;
import org.mortbay.jetty.Response;
import org.mortbay.jetty.security.Authenticator;
import org.mortbay.jetty.security.BasicAuthenticator;
import org.mortbay.jetty.security.SecurityHandler;
import org.mortbay.jetty.security.UserRealm;

/**
 * @author colin
 *
 */
public class ELifeAuthenticator extends BasicAuthenticator  implements Authenticator {

	HashMap <String,Boolean> allowedIPs;
	
	public  ELifeAuthenticator ()  {
		allowedIPs = new HashMap<String,Boolean>();
		// allowedIPs.put ("127.0.0.1",true);
	}

	public Principal authenticate(UserRealm realm, String pathInContext,
			Request request, Response response) throws IOException {
		String callingIP = request.getRemoteAddr();
		
		if (allowedIPs.containsKey( callingIP))  {
			return SecurityHandler.__NOBODY;
		} else {
			return super.authenticate(  realm,  pathInContext, request,  response);
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
