/*
 * Created on Feb 8, 2004
 *
 */
package au.com.BI.Flash;

import java.io.OutputStream;
import java.util.logging.*;


/**
 * @author Colin Canfield
 *
 **/
public class BroadcastHandler extends StreamHandler
{

	OutputStream logOutput;
	protected FlashControlListener flashControlListener = null;

	/**
	 * @param outputStream
	 * @param formatter
	 */
	public BroadcastHandler(BroadcastFormatter formatter) {
			super.setFormatter(formatter);
	}

	
	public void publish(LogRecord logRecord) {
		if (logRecord == null)
			return;

		if (logRecord.getLevel().intValue() >= this.getLevel().intValue()){
			String buffer = this.getFormatter().format(logRecord);
			flashControlListener.sendToAllClients(buffer,0);
		}
	}


	public FlashControlListener getFlashControlListener() {
		return flashControlListener;
	}


	public void setFlashControlListener(FlashControlListener flashControlListener) {
		this.flashControlListener = flashControlListener;
	}
}
