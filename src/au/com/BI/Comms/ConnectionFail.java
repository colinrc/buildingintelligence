package au.com.BI.Comms;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class ConnectionFail extends Exception{

	/**
	 * 
	 */
	private static final long serialVersionUID = 359677372997470162L;

	public ConnectionFail(){

	}

	/**
	 * @param message customized message
	 * 
	 */
	public ConnectionFail(String message){
		super (message);
	}

	/**
	 * @param message Customized message
	 * @param cause The exception that originally caused the error
	 * 
	 */
	public ConnectionFail(String message,Throwable cause){
		super (message,cause);
	}
}