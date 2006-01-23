/*
 * Created on Feb 16, 2004
 *
 */
package au.com.BI.simulator.conf;
import java.util.*;


import java.io.*;
import org.jdom.*;
import org.jdom.input.*;
import java.util.logging.*; 

/**
 * @author Colin Canfield
 *
 */

public class Config {
	public Logger logger;

	protected ArrayList controls;
	protected ControlFactory controlFactory;	
	protected boolean hexOnly = false;

	public Config() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());

		controlFactory = new ControlFactory() ;		
		
		controls = new ArrayList (10);
	}



	public boolean readConfig(String fileName)
			throws ConfigError {
		// Create an instance of the tester and test
		try {
			SAXBuilder builder = null;
			controls.clear();

			builder = new SAXBuilder();
			Document doc = builder.build(fileName);
			Element theConfig = doc.getRootElement();
			
			Element log = theConfig.getChild("log");
			String hexOnlyStr = log.getAttributeValue("hexOnly");
			if (hexOnlyStr.equals("Y")) 
				this.setHexOnly(true);
			else
				this.setHexOnly(false);

			List controlList = theConfig.getChildren("control");
			Iterator eachControl = controlList.iterator();
			while (eachControl.hasNext()) {
				Element controlElement = (Element) eachControl.next();
					Control newControl = controlFactory.createControl(controlElement);
					controls.add(newControl);
			}
			return true;
		}
		catch (JDOMException e) {
			throw new ConfigError(e);
		} catch (IOException e) {
			throw new ConfigError(e);
		}
	}

	public boolean isHexOnly() {
		return hexOnly;
	}

	public void setHexOnly(boolean hexOnly) {
		this.hexOnly = hexOnly;
	}
	
}
