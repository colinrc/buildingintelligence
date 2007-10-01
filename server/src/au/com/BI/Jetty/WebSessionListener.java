/**
 * 
 */
package au.com.BI.Jetty;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.*;

/**
 * @author colin
 *
 */
public class WebSessionListener implements HttpSessionListener {
	Logger logger;
	SessionCounter sessionCounter;
	
	
	 public WebSessionListener() {
			logger = Logger.getLogger(this.getClass().getPackage().getName());
	    }

	    public void sessionCreated(HttpSessionEvent sessionEvent) {
	        HttpSession session = sessionEvent.getSession();
	        
	        String user = (String)session.getAttribute ("User");
	        
	        logger.log (Level.FINE, "Session created for web user " + user);
	    }
	    
	    public void sessionDestroyed(HttpSessionEvent sessionEvent) {

	        // Get the session that was invalidated
	        HttpSession session = sessionEvent.getSession();
	        String user = (String)session.getAttribute ("User");
	        
	        logger.log (Level.FINE, "Session closed for web user " + user);
	    }

		public SessionCounter getSessionCounter() {
			return sessionCounter;
		}

		public void setSessionCounter(SessionCounter sessionCounter) {
			this.sessionCounter = sessionCounter;
		}
}
