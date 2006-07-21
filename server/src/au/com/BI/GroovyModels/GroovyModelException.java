package au.com.BI.GroovyModels;



/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */
public class GroovyModelException extends Exception{

	public GroovyModelException(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message
	 * 
	 */
	public GroovyModelException(String message){
		super (message);
	}

	public GroovyModelException(String message, Throwable cause){
		super (message, cause);
	}
	
}