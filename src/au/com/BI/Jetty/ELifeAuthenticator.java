/**
 * 
 */
package au.com.BI.Jetty;

import java.io.IOException;
import java.security.Principal;


import org.mortbay.jetty.Request;
import org.mortbay.jetty.Response;
import org.mortbay.jetty.security.Authenticator;
import org.mortbay.jetty.security.FormAuthenticator;
import org.mortbay.jetty.security.SecurityHandler;
import org.mortbay.jetty.security.UserRealm;

import au.com.BI.Config.Security;
import au.com.BI.Config.Security.IPType;

/**
 * @author colin
 *
 */
public class ELifeAuthenticator extends FormAuthenticator  implements Authenticator {

	public Security security;
	protected IPType ipType = IPType.FullFunction;
	
	public  ELifeAuthenticator ()  {
	}

	public Principal authenticate(UserRealm realm, String pathInContext,
		Request request, Response response) throws IOException {
		String callingIP = request.getRemoteAddr();
		
		if (request.getUri().getPath().endsWith("favicon.ico")) {
			 return SecurityHandler.__NOBODY;
		}
		
		if (ipType == IPType.FullFunction) {
			if (security.iPInRange(callingIP, IPType.FullFunction))  {
				return SecurityHandler.__NOBODY;
			} else {
				return super.authenticate(  realm,  pathInContext, request,  response);
			}
		} 
		
		if (ipType == IPType.PostOnly) {
			if (security.iPInRange(callingIP, IPType.PostOnly))  {
				return SecurityHandler.__NOBODY;
			} else {
				return	null;
			}
		} 
		
		if (ipType ==IPType.Forward){
			if (security.isConnected()) {
				return SecurityHandler.__NOBODY;
			} else {
				return null;
			}
		}
		return super.authenticate(  realm,  pathInContext, request,  response);
		
	}
	
	public Security getSecurity() {
		return security;
	}

	public void setSecurity(Security security) {
		this.security = security;
	}

	public IPType getIpType() {
		return ipType;
	}

	public void setIpType(IPType ipType) {
		this.ipType = ipType;
	}

}
