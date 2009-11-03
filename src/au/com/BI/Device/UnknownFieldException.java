package au.com.BI.Device;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
@SuppressWarnings("serial")
public class UnknownFieldException extends Exception{

	public UnknownFieldException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public UnknownFieldException(String message){
		super (message);
	}

	public UnknownFieldException(String message, Throwable cause){
		super (message, cause);
	}
	
}