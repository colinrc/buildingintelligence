package au.com.BI.Comms;




/**
 * Holds Strng representations of error events that have been received 
 * from the physical devices
 * @author Colin Canfield
 * @version 1.0
 * @updated 28-Jan-2004 08:54:55 PM
 */
public class ErrorReceiveEvent extends Exception{
	String message;

	public ErrorReceiveEvent(Throwable cause)
	{
		super (cause);
	}

	public ErrorReceiveEvent(String message,Throwable cause)
	{
		super (message,cause);
	}
	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public void setMessage(java.lang.Object src,String message)
	{
		this.message = message;
	}

}