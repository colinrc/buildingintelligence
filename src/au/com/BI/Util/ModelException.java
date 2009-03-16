package au.com.BI.Util;


/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class ModelException extends Exception{

	public ModelException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public ModelException(String message){
		super (message);
	}

	public ModelException(String message, Throwable cause){
		super (message, cause);
	}
	
}