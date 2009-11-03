package au.com.BI.Device;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
@SuppressWarnings("serial")
public class FieldValueException extends Exception{

	public FieldValueException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public FieldValueException(String message){
		super (message);
	}

	public FieldValueException(String message, Throwable cause){
		super (message, cause);
	}
	
}