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
 */
public class RequestForward extends ProxyServlet
{
/** 
 * Based on Transparent Proxy distributed as a Jetty Sample 
 * 
 */

         String _prefix;
         String _proxyTo;
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
             if (config.getInitParameter("ProxyTo")!=null)
                 _proxyTo=config.getInitParameter("ProxyTo");
             if (config.getInitParameter("Prefix")!=null)
                 _prefix=config.getInitParameter("Prefix");
             if (_proxyTo==null)
                 throw new UnavailableException("No ProxyTo");
             super.init(config);
             _log.info(_name+" @ "+(_prefix==null?"-":_prefix)+ " to "+_proxyTo);
         }

         @Override
         protected HttpURI proxyHttpURI(final String scheme, final String serverName, int serverPort, final String uri) throws MalformedURLException
         {
             if (_prefix!=null && !uri.startsWith(_prefix))
                 return null;
 
             if (_prefix!=null)
                 return new HttpURI(_proxyTo+uri.substring(_prefix.length()));
             return new HttpURI(_proxyTo+uri);
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

