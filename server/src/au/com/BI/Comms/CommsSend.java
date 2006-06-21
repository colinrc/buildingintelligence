/**
 * 
 */
package au.com.BI.Comms;

import java.io.IOException;
import java.io.OutputStream;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author colin
 *
 */
public class CommsSend extends Thread implements Runnable{
	
	int interCommandInterval;
	BlockingQueue <byte[]>toSend = null;
	boolean handleEvents = true;
	protected OutputStream os = null;
	protected long lastSendTime;
	protected Logger logger;

	public CommsSend(ThreadGroup threadGroup) {
		super (threadGroup,"Comms Send");
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("Comms Sender");
		toSend = new LinkedBlockingQueue<byte[]>();
	}
	
	public void run () {
		byte[] nextMessage = null;
		assert  os!=null;
		
		while (handleEvents) {
			try {

				nextMessage = toSend.take();
	
				if (nextMessage != null){
					long currentTimeDiff = System.currentTimeMillis() - lastSendTime;
					try {
						if (currentTimeDiff < interCommandInterval){
							try {
								sleep (interCommandInterval - currentTimeDiff);
							} catch (InterruptedException e) {
	
							}
						}
						lastSendTime = System.currentTimeMillis();
						synchronized (os){
							os.write(nextMessage);
							os.flush();
						}
					} catch (IOException e) {
						logger.log (Level.FINE,"Received IO exception on communication stream " + e.getMessage());
						handleEvents = false;
						throw new CommsFail ("Error sending information",e);
					}
				}

			} catch (InterruptedException e) {

			}
			
			Thread.yield(); // give other clients a chance
		}
	}

	public OutputStream getOs() {
		return os;
	}

	public void setOs(OutputStream os) {
		this.os = os;
	}
	
	public int getInterCommandInterval() {
		return interCommandInterval;
	}


	public void setInterCommandInterval(int interCommandInterval) {
		this.interCommandInterval = interCommandInterval;
	}

	public boolean isHandleEvents() {
		return handleEvents;
	}

	public void setHandleEvents(boolean handleEvents) {
		this.handleEvents = handleEvents;
	}

}
