/**
 * 
 */
package au.com.BI.Util;

/**
 * @author colin
 *
 */
public class SimplifiedModelPoll extends Thread {

	protected volatile boolean polling = false;
	protected SimplifiedModel model = null;
	protected long delay = 5000L;
	

	public void run() {
		polling = true;
			while (polling) {
				model.doPoll();

				try {
					if (polling) sleep(delay );
				} catch (InterruptedException e) {
					polling = false;
				}
			}

	}
	
	public boolean isPolling() {
		return polling;
	}
	
	public void setPolling(boolean polling) {
		this.polling = polling;
	}
	
	public SimplifiedModel getModel() {
		return model;
	}
	
	public void setModel(SimplifiedModel model) {
		this.model = model;
	}

	public long getDelay() {
		return delay;
	}

	public void setDelay(long delay) {
		this.delay = delay;
	}

}
