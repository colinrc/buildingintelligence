package au.com.BI.Servlets;


@SuppressWarnings("serial")
public class CommandFail extends Exception{

	private String errorCode ="";
	
	public CommandFail(){

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @param message customized message
	 * 
	 */
	public CommandFail(String errorCode, String message){
		super (message);
		this.errorCode = errorCode;
	}
	
	/**
	 * @param message customized message
	 * 
	 */
	public CommandFail(String message){
		super (message);
	}

	/**
	 * @param message Customized message
	 * @param cause The exception that originally caused the error
	 * 
	 */
	public CommandFail(String message,Throwable cause){
		super (message,cause);
	}

	public CommandFail(String errorCode, String message,Throwable cause){
		super (message,cause);
		this.errorCode = errorCode;
	}
	
	public String getErrorCode() {
		return errorCode;
	}

	public void setErrorCode(String errorCode) {
		this.errorCode = errorCode;
	}
}