/*
 * Created on Feb 8, 2004
 *
 */
package au.com.BI.AWTHarness;

import java.util.logging.*;
import javax.swing.*;

/**
 * @author Colin Canfield
 *
 **/
public class LogHandler extends Handler
{
	protected JTextArea logPane;
	protected int numberItems = 0;
	protected String pausedLogs = "";
	protected boolean pausing = false;
	protected JScrollBar logPaneScroller;
	
	public LogHandler (AWTHarness harness) {
		logPane = harness.getLogPane ();
		logPaneScroller = harness.scrollPaneIn.getVerticalScrollBar();
	}
	
	public void publish(LogRecord logRecord) {
		if (pausing) {
			synchronized (pausedLogs) {
				pausedLogs += logRecord.getLevel() + ":";
				pausedLogs += logRecord.getSourceClassName() + ":";
				pausedLogs += logRecord.getSourceMethodName() + ":";
				pausedLogs += "<" + logRecord.getMessage().trim() + ">\n";
				numberItems ++;
			}
		}
		else{
			if (numberItems > 1000)  {
				String theText = logPane.getText();
				logPane.setText(theText.substring( theText.length() - 10000 )); 
				// random point to provide continuity for event viewer
				numberItems = 0;
			}
			
			logPane.append(logRecord.getLevel() + ":");
			logPane.append(
					logRecord.getSourceClassName() + ":");
			logPane.append(
					logRecord.getSourceMethodName() + ":");
			logPane.append(
					"<" + logRecord.getMessage().trim() + ">\n");
			logPane.setCaretPosition(logPane.getDocument().getLength()-1);
			numberItems++;
		}

	}
	public void flush() {}
	public void close() {} 
	
	public void pauseLogging () {
		pausing = true;
		synchronized (pausedLogs) {
			pausedLogs = "";
		}
	}

	public void resumeLogging () {
		pausing = false;
		synchronized (pausedLogs) {
			logPane.append (pausedLogs);
			logPane.setCaretPosition(logPane.getDocument().getLength()-1);
			pausedLogs = "";
		}
	}

}
