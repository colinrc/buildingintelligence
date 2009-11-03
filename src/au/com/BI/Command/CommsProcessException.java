package au.com.BI.Command;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
@SuppressWarnings("serial")
public class CommsProcessException extends Exception{

	public CommsProcessException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public CommsProcessException(String message){
		super (message);
	}

	public CommsProcessException(String message, Throwable cause){
		super (message, cause);
	}
	
}