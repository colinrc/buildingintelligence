package au.com.BI.Jetty;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jetty.security.ConstraintSecurityHandler;
import org.eclipse.jetty.security.SecurityHandler;
import org.eclipse.jetty.server.Authentication;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.Response;
import org.eclipse.jetty.server.UserIdentity;

import au.com.BI.Config.Security;
import au.com.BI.Config.Security.IPType;


public class IPInRangeHandler extends ConstraintSecurityHandler {
	
	
	public Security security;
	protected IPType ipType = IPType.FullFunction;
	
    public void handle(String pathInContext, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
         final Handler handler=getHandler();
         
         if (handler==null)
             return;
         
     	if (!baseRequest.isHandled())
    	{
    		response.sendError(Response.SC_FORBIDDEN);
    	 	baseRequest.setHandled(true);
    	}
     	
		if (ipType == IPType.FullFunction) {
			if (security.iPInRange(request.getRemoteAddr(), IPType.FullFunction))  {
        	 	baseRequest.setHandled(true);
				baseRequest.setAuthentication(Authentication.NOT_CHECKED);
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
    
	@Override
	protected boolean checkUserDataPermissions(String arg0, Request arg1,
			Response arg2, Object arg3) throws IOException {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	protected boolean checkWebResourcePermissions(String arg0, Request arg1,
			Response arg2, Object arg3, UserIdentity arg4) throws IOException {
		// TODO Auto-generated method stub
		return false;
	}

	protected boolean isAuthMandatory(Request arg0, Response arg1, Object arg2) {
		return false;
	}

	@Override
	protected Object prepareConstraintInfo(String arg0, Request arg1) {
		// TODO Auto-generated method stub
		return null;
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
