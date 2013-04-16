package au.com.BI.CustomConnect;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
@SuppressWarnings("serial")
public class CustomConnectException extends Exception{

	public CustomConnectException(){

	}

	/**
	 * @param message
	 * 
	 */
	public CustomConnectException(String message){
		super (message);
	}

	public CustomConnectException(String message, Throwable cause){
		super (message, cause);
	}
	
}