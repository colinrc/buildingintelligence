package au.com.BI.Comms;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class CommsFail extends RuntimeException{

	/**
	 * 
	 */
	private static final long serialVersionUID = 292821338705949768L;

	public CommsFail(){

	}

	/**
	 * @param message
	 * 
	 */
	public CommsFail(String message){
		super (message);
	}

	public CommsFail(String message, Throwable cause){
		super (message, cause);
	}
	
}