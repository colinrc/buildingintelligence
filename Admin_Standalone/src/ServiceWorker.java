/*
 * Created on Jan 23, 2005
 * @Author Colin Canfield
 */

public class ServiceWorker extends SwingWorker {

	private String message;

	/**
	 * @param message The message to set.
	 */
	public void setMessage(String message) {
		this.message = message;
	}

	public Object construct() {
		return null;
	}

}
