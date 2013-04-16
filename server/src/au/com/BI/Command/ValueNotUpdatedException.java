package au.com.BI.Command;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class ValueNotUpdatedException extends Exception{

	/**
	 * 
	 */
	private static final long serialVersionUID = -3628316996495402089L;

	public ValueNotUpdatedException(){

	}

	/**
	 * @param message
	 * 
	 */
	public ValueNotUpdatedException(String message){
		super (message);
	}

	public ValueNotUpdatedException(String message, Throwable cause){
		super (message, cause);
	}
	
}