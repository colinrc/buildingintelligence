package au.com.BI.Config;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
@SuppressWarnings("serial")
public class TooManyClientsException extends Exception{

	public TooManyClientsException(){

	}

	/**
	 * @param message
	 * 
	 */
	public TooManyClientsException(String message){
		super (message);
	}

	public TooManyClientsException(String message, Throwable cause){
		super (message, cause);
	}
	
}