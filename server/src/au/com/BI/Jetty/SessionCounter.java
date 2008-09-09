/**
 * 
 */
package au.com.BI.Jetty;


import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.*;

import javax.servlet.http.*;

import au.com.BI.Messaging.AddressBook;


/** Listener that keeps track of the number of sessions

 * that the Web application is currently using and has

 * ever used in its life cycle.

 */

public class SessionCounter implements HttpSessionListener  {

	private Integer currentSessionCount = 0;

	private ServletContext context = null;
	Logger logger;
	AddressBook addressBook;
	
	public SessionCounter () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public void sessionCreated(HttpSessionEvent event) {
        HttpSession session = event.getSession();

		if (context == null) {
			storeInServletContext(event);
		}
	}

	public void sessionDestroyed(HttpSessionEvent event) {

        HttpSession session = event.getSession();
        String user = (String)session.getAttribute ("User");
        if (addressBook.isUserConnected(user)){
        	Long oldID = (Long)session.getAttribute("ID");
        	Long currentID = addressBook.getIDFromUser(user);
        	if (currentID.equals(oldID)){
        		// The user has not logged in again, this should occur from a time out
    	        addressBook.userDisconnect(user);

        	}
	        logger.log (Level.FINE, "Session closed for web user " + user);
        } else {
        	logger.log (Level.FINE,"Session close was attempted however the user " + user + " is not logged in.");
        }
		synchronized (currentSessionCount){
			currentSessionCount--;
		}
	}

	/** The number of sessions currently in memory. */

	public int getCurrentSessionCount() {
		return (currentSessionCount);
	}
	
	public int incrementCount() {
		synchronized (currentSessionCount){
			currentSessionCount++;
		}
		return currentSessionCount;
	}

	private void storeInServletContext(HttpSessionEvent event) {
		HttpSession session = event.getSession();
		context = session.getServletContext();
		context.setAttribute("sessionCounter", this);
	}

	public AddressBook getAddressBook() {
		return addressBook;
	}

	public void setAddressBook(AddressBook addressBook) {
		this.addressBook = addressBook;
	}

}