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

	protected List<Control> controls;
	protected ControlFactory controlFactory;	

	public Config() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());

		controlFactory = ControlFactory.getInstance() ;		
		setFactory (controlFactory);
		controls = new ArrayList<Control>();
	}

	public void setFactory (ControlFactory controlFactory){
		this.controlFactory = controlFactory;
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

			List<Element> controlList = theConfig.getChildren("control");
			for (Element controlElement: controlList){
				try {
					Control newControl = controlFactory.createControl(controlElement);
					controls.add(newControl);
				} catch (NullPointerException ex){
					logger.log (Level.WARNING,"Failed to add control " + ex.getMessage()); 
				}
			}
			return true;
		}
		catch (JDOMException e) {
			throw new ConfigError(e);
		} catch (IOException e) {
			throw new ConfigError(e);
		}
	}

	public List<Control> getControls() {
		return controls;
	}

	public void setControls(List<Control> controls) {
		this.controls = controls;
	}
	
}
