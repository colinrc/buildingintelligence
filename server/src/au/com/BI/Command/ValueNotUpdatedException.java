package au.com.BI.Command;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class ValueNotUpdatedException extends Exception{

	public ValueNotUpdatedException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
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