package au.com.BI.Command;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class UnknownCommandException extends Exception{

	/**
	 * 
	 */
	private static final long serialVersionUID = 5015606659183333627L;

	public UnknownCommandException(){

	}

	/**
	 * @param message
	 * 
	 */
	public UnknownCommandException(String message){
		super (message);
	}

	public UnknownCommandException(String message, Throwable cause){
		super (message, cause);
	}
	
}