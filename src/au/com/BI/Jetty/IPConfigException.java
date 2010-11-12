package au.com.BI.Jetty;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
@SuppressWarnings("serial")
public class IPConfigException extends Exception{

	public IPConfigException(){

	}

	/**
	 * @param message
	 * 
	 */
	public IPConfigException(String message){
		super (message);
	}

	public IPConfigException(String message, Throwable cause){
		super (message, cause);
	}
	
}