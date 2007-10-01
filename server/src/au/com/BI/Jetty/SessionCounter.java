/**
 * 
 */
package au.com.BI.Jetty;


import javax.servlet.*;

import javax.servlet.http.*;

/** Listener that keeps track of the number of sessions

 * that the Web application is currently using and has

 * ever used in its life cycle.

 */

public class SessionCounter implements HttpSessionListener  {

	private int currentSessionCount = 0;

	private ServletContext context = null;

	public void sessionCreated(HttpSessionEvent event) {

		currentSessionCount++;

		if (context == null) {
			storeInServletContext(event);
		}
	}

	public void sessionDestroyed(HttpSessionEvent event) {
		currentSessionCount--;
	}

	/** The number of sessions currently in memory. */

	public int getCurrentSessionCount() {
		return (currentSessionCount);
	}

	private void storeInServletContext(HttpSessionEvent event) {
		HttpSession session = event.getSession();
		context = session.getServletContext();
		context.setAttribute("sessionCounter", this);
	}

}