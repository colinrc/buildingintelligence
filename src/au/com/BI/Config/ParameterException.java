package au.com.BI.Config;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class ParameterException extends Exception{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1166793973353914312L;

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