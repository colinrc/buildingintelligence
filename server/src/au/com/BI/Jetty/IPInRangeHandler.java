package au.com.BI.Jetty;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jetty.security.ConstraintSecurityHandler;
import org.eclipse.jetty.security.MappedLoginService;
import org.eclipse.jetty.server.Authentication;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.Response;
import org.eclipse.jetty.server.UserIdentity;
import org.eclipse.jetty.server.UserIdentity.Scope;

import au.com.BI.Config.Security;
import au.com.BI.Config.Security.IPType;


public class IPInRangeHandler extends ConstraintSecurityHandler {
	
	
	public Security security;
	protected IPType ipType = IPType.FullFunction;
	protected MappedLoginService.Anonymous anonFullUser;

    
	public IPInRangeHandler() {
		anonFullUser = new MappedLoginService.Anonymous();
		

	}
	
    public void handle(String pathInContext, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {        
     	
		if (ipType == IPType.FullFunction) {
			if (security.iPInRange(request.getRemoteAddr(), IPType.FullFunction))  {
        	 	baseRequest.setHandled(true);
				baseRequest.setAuthentication(Authentication.UNAUTHENTICATED);
			} 
		} 
		
		if (ipType == IPType.PostOnly) {
			baseRequest.setHandled(true);
			if (security.iPInRange(request.getRemoteAddr(), IPType.PostOnly))  {
				baseRequest.setAuthentication(Authentication.NOT_CHECKED);
			} else {
				response.sendError(Response.SC_FORBIDDEN, "!role");
			}
		} 
		super.handle(pathInContext, baseRequest, request, response);
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
