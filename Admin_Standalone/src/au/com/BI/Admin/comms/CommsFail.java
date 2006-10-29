package au.com.BI.Admin.comms;
/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class CommsFail extends Exception{

	public CommsFail(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public CommsFail(String message){
		super (message);
	}

	public CommsFail(String message, Throwable cause){
		super (message, cause);
	}
	
}