/**
 * 
 */
package au.com.BI.Jetty;

import java.io.IOException;
import java.security.Principal;


import org.mortbay.jetty.Request;
import org.mortbay.jetty.Response;
import org.mortbay.jetty.security.Authenticator;
import org.mortbay.jetty.security.BasicAuthenticator;
import org.mortbay.jetty.security.SecurityHandler;
import org.mortbay.jetty.security.UserRealm;

import au.com.BI.Config.Security;
import au.com.BI.Config.Security.IPType;

/**
 * @author colin
 *
 */
public class ELifeAuthenticator extends BasicAuthenticator  implements Authenticator {

	public Security security;
	
	public  ELifeAuthenticator ()  {
	}

	public Principal authenticate(UserRealm realm, String pathInContext,
		Request request, Response response) throws IOException {
		String callingIP = request.getRemoteAddr();
		
		if (security.iPInRange(callingIP, IPType.FullFunction))  {
			return SecurityHandler.__NOBODY;
		} else {
			return super.authenticate(  realm,  pathInContext, request,  response);
		}
	}
	
	public Security getSecurity() {
		return security;
	}

	public void setSecurity(Security security) {
		this.security = security;
	}
}
