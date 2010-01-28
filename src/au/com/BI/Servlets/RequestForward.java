/**
 * 
 */
package au.com.BI.Servlets;


import org.eclipse.jetty.servlets.*;


import java.net.MalformedURLException;
import java.util.Map;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.UnavailableException;
import org.eclipse.jetty.http.HttpURI;
import org.eclipse.jetty.util.log.Log;
import org.eclipse.jetty.util.log.Logger;


/**
 * @author colin
 * Based on the AsyncProxyServlet source from the Jetty distribution
 * 
 * Transparent Proxy. This convenience extension to ProxyServlet configures the servlet as a transparent proxy. The servlet is configured with init parameter:

ProxyTo - a URI like http://host:80/context to which the request is proxied.
Prefix - a URI prefix that is striped from the start of the forwarded URI.
For example, if a request was received at /foo/bar and the ProxyTo was 
http://host:80/context and the Prefix was /foo, then the request would be proxied to http://host:80/context/bar
 * 
 */
public class RequestForward extends ProxyServlet
{
/** 
 * Based on Transparent Proxy distributed as a Jetty Sample 
 * 
 */

         Map <String,String>forwards;
	         
         public RequestForward()
         {    
         }


         public RequestForward(Map <String,String>forwards)
         {    
        	 this.forwards = forwards;
         }
         
         
         @SuppressWarnings("unchecked")
		@Override
         public void init(ServletConfig config) throws ServletException
         {
        	 forwards = (Map<String,String>)config.getServletContext().getAttribute("forwards");
        	 
             super.init(config);
         }

         @Override
         protected HttpURI proxyHttpURI(final String scheme, final String serverName, int serverPort, final String uri) throws MalformedURLException
         {
        	 for (String _prefix: forwards.keySet()){
        		 if (uri.startsWith(_prefix)){
        			 return new HttpURI(forwards.get(_prefix)+uri.substring(_prefix.length()));
        		 }
        	 }
             return new HttpURI(uri);   
         }
 

         /* (non-Javadoc)
          * @see javax.servlet.Servlet#getServletInfo()
          */
         public String getServletInfo()
         {
        	 return "Request Forward";
         }

         /* (non-Javadoc)
          * @see javax.servlet.Servlet#destroy()
          */
         public void destroy()	
         {

         }


}

