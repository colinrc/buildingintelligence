package au.com.BI.Jetty;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
@SuppressWarnings("serial")
public class JettyException extends Exception{

	public JettyException(){

	}

	/**
	 * @param message
	 * 
	 */
	public JettyException(String message){
		super (message);
	}

	public JettyException(String message, Throwable cause){
		super (message, cause);
	}
	
}