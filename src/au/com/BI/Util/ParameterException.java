package au.com.BI.Util;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class ParameterException extends Exception{

	public ParameterException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public ParameterException(String message){
		super (message);
	}

	public ParameterException(String message, Throwable cause){
		super (message, cause);
	}
	
}