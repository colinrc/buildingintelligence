package au.com.BI.Command;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class UnknownCommandException extends Exception{

	public UnknownCommandException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
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