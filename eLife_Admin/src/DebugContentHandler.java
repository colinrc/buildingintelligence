/*
 * Created on Jan 17, 2005
 */
import org.xml.sax.*;
import org.xml.sax.helpers.DefaultHandler;
import javax.swing.*;

import java.util.logging.*;
import java.util.Date;
import java.util.Vector;

public class DebugContentHandler extends DefaultHandler implements ContentHandler {
	
	private eLife_Admin eLife;
	private Logger logger;
	protected boolean inError = false;
	protected Vector iRActions = null;
	protected Vector iRDevices = null;
	
	public DebugContentHandler () {
		logger = Logger.getLogger ("Log");
		iRActions = new Vector ();
		iRDevices = new Vector ();
		}

	/**
	 * @param life The eLife to set.
	 */
	public void setELife(eLife_Admin eLife) {
		this.eLife = eLife;
	}
	

	public void characters(char[] ch, int start, int length)
			throws SAXException {
	
		String errorString = new String (ch);
		logger.log (Level.WARNING,"Error " + errorString);
		eLife.showMessage (errorString,JOptionPane.ERROR_MESSAGE);
	}
	
	private class DisplayLine implements Runnable {
		private String message;
		private String time;
		private String src;
		private String level;
		private eLife_Admin eLife;
		private LogPanel logPanel;
		
		public DisplayLine(String message, String time, String src, String level, eLife_Admin eLife) {
			this.src = src;
			this.time = time;
			this.message = message;
			this.level = level;
			if (level == null)
				this.level = "";
			else 
				this.level = level;
			this.eLife = eLife;
			logPanel = eLife.getLogViewer();
		}

        public void run() {
			if (this.level.startsWith("W") || this.level.startsWith ("S")) {
        			logPanel.addReceivedMessage(time, level, src, message ,true);
			}
			else { 
				logPanel.addReceivedMessage(time, level, src, message,false);
			}
        }
	}

	public void endElement (String namespaceURI, String localName, String qName) {
		if (qName.equals("DEBUG_PACKAGES")) {
			synchronized (eLife) {
				eLife.getDebugLevelsPanel().validateMenus();
			}
		}
		if (qName.equals("IR_ACTION_LIST")) {
			synchronized (eLife) {
				eLife.getIRPanel().updateActionList(iRActions);
			}
		}
		if (qName.equals("IR_DEVICE_LIST")) {
			synchronized (eLife) {
				eLife.getIRPanel().updateDeviceList(iRDevices);
			}
		}
	}
	
	public void startElement(String namespaceURI,
            String localName,
            String qName,
            Attributes atts)
     throws SAXException {
		inError = false;
		if (qName.equals("LOG")) {
			String src = atts.getValue("SRC");
			String level = atts.getValue("LEVEL");
			String message = atts.getValue("MSG");
			String time = atts.getValue("TIME");
			DisplayLine displayLine = new DisplayLine (message,time,src,level,eLife);
			SwingUtilities.invokeLater(displayLine);
		}
		if (qName.equals("connected")) {
			String configFile = atts.getValue("config");
			String launchTimeStr = atts.getValue("launched");
			Date launchTime;
			
			try {
				long launchTimeLong = Long.parseLong(launchTimeStr);
				launchTime = new Date(launchTimeLong);
			} catch (NumberFormatException ex) {
				launchTime = new Date();
			}
			synchronized (eLife) {
				eLife.getControlsPanel().setConnectionMessage(configFile,launchTime);
			}
		}
		
		if (qName.equals("DEBUG_PACKAGES")) {
			synchronized (eLife) {
				eLife.getDebugLevelsPanel().clearDebugMenus();
			}
		}
		if (qName.equals("IR_LEARNT")) {
			synchronized (eLife) {
				eLife.getIRPanel().setIRLearn(true);
				String result = atts.getValue( "RESULT");
				eLife.getIRPanel().updateSystemStatus(result);
				if (!result.startsWith ("Success")) {
					eLife.showMessage(result,JOptionPane.ERROR_MESSAGE);
					
				} else {
					eLife.getIRPanel().nextInstruction();
				}
			}
		}
		if (qName.equals("IR_CHANGED")) {
			synchronized (eLife) {
				eLife.getIRPanel().setIRLearn(true);
				String result = atts.getValue( "RESULT");
				eLife.getIRPanel().updateSystemStatus(result);

			}
		}
		if (qName.equals("IR_CONFIG")) {
			synchronized (eLife) {
				eLife.getIRPanel().setIRLearn(true);
				String result = atts.getValue( "RESULT");
				eLife.getIRPanel().updateSystemStatus(result);
			}
		}
		if (qName.equals("IR_ACTION_LIST")) {
			iRActions = new Vector ();
		}
		if (qName.equals("IR_DEVICE_LIST")) {
			iRDevices = new Vector ();
		}
		if (qName.equals("IR_ACTION_ITEM")) {
			String name = atts.getValue ("NAME");
			iRActions.add(name);
		}
		if (qName.equals("IR_DEVICE_ITEM")) {
			String name = atts.getValue ("NAME");
			iRDevices.add(name);
		}
		if (qName.equals("ERROR")) {
			inError = true;
		}

		if (qName.equals("DEBUG_MENU")) {
			String shortName = atts.getValue("SHORTNAME");
			String packageName = atts.getValue("PACKAGENAME");
			String level = atts.getValue("LEVEL");
			synchronized (eLife) {
				eLife.getDebugLevelsPanel().addDebugMenu(shortName,packageName,level);
			}
		}
	}
}
