package au.com.BI.Jetty;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class IPConfigException extends Exception{

	public IPConfigException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public IPConfigException(String message){
		super (message);
	}

	public IPConfigException(String message, Throwable cause){
		super (message, cause);
	}
	
}