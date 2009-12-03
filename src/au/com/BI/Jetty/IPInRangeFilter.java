package au.com.BI.Jetty;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import org.eclipse.jetty.server.Authentication;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.Response;
import org.eclipse.jetty.server.UserIdentity;

import au.com.BI.Config.Security;
import au.com.BI.Config.Security.IPType;
import org.eclipse.jetty.security.SecurityHandler;

public class IPInRangeFilter  implements Filter {

	public Security security;
	protected IPType ipType = IPType.FullFunction;
	protected ServletContext servletContext;
	
	public void destroy() {
		// TODO Auto-generated method stub
		
	}

	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {
		// TODO Auto-generated method stub
		
		if (servletContext.getContextPath().endsWith("favicon.ico")) {
			 return this. Authentication.NOT_CHECKED;
		}
		
		if (ipType == IPType.FullFunction) {
			if (security.iPInRange(request.getRemoteAddr(), IPType.FullFunction))  {
				 return Authentication.NOT_CHECKED;
				 } else {
				return super.validateRequest(  request,  response,mandatory);
			}
		} 
		
		if (ipType == IPType.PostOnly) {
			if (security.iPInRange(request.getRemoteAddr(), IPType.PostOnly))  {
				 return Authentication.NOT_CHECKED;
			} else {
				return	null;
			}
		} 
		
	}

	public void init(FilterConfig config) throws ServletException {
		servletContext = config.getServletContext();
		security = (Security)servletContext.getAttribute("Security");
		ipType = (IPType)servletContext.getAttribute("IPType");
		
	}

}
