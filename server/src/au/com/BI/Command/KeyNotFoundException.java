package au.com.BI.Command;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class KeyNotFoundException extends Exception{

	public KeyNotFoundException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public KeyNotFoundException(String message){
		super (message);
	}

	public KeyNotFoundException(String message, Throwable cause){
		super (message, cause);
	}
	
}