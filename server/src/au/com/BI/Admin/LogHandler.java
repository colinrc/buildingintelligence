/*
 * Created on Feb 8, 2004
 *
 */
package au.com.BI.Admin;

import java.io.OutputStream;
import java.util.logging.*;
import java.util.Vector;
import java.util.Iterator;
import java.util.Calendar;

/**
 * @author Colin Canfield
 *
 **/
public class LogHandler extends StreamHandler
{

	OutputStream logOutput;
	private boolean buffering = false;
	private boolean sentBuffer = false;
	private Vector <LogRecord>startupLogBuffer;
	private Calendar endOfRecording;

	/**
	 * @param outputStream
	 * @param formatter
	 */
	public LogHandler(BIFormatter formatter) {
		super.setFormatter(new BIFormatter());
		buffering = true;
		startupLogBuffer = new Vector <LogRecord>(1000);
		endOfRecording = Calendar.getInstance();
		
		endOfRecording.add(Calendar.MINUTE,3); 
		// 3 minutes after bootup messages are buffered until a log stream comes along
	}
	
	public void setOutputStream (OutputStream outputStream) throws SecurityException {
	    this.logOutput = outputStream;
	    super.setOutputStream (outputStream);
	    if (!sentBuffer) {
	    	buffering = false;
	    	sentBuffer = true;
	    	Iterator eachRecord = startupLogBuffer.iterator();
	    	while (eachRecord.hasNext()) {
	    		LogRecord nextRecord = (LogRecord)eachRecord.next();
	    		publish(nextRecord);
	    	}
	    	startupLogBuffer.clear();
	    }
	    
	}
	
	public void publish(LogRecord logRecord) {
		if (buffering) {
			startupLogBuffer.add (logRecord);
			if (Calendar.getInstance().after(endOfRecording)) {
				buffering = false;
			}
			
		} else {
			super.publish (logRecord);
			super.flush();
		}
	}
}
