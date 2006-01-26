package au.com.BI.Calendar;

public class CalendarException extends Exception {


	/**
	 * 
	 */
	private static final long serialVersionUID = 9051875790614738423L;

	public CalendarException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public CalendarException(String message){
		super (message);
	}

	public CalendarException(String message, Throwable cause){
		super (message, cause);
	}
	
}