package au.com.BI.simulator.conf;

import org.jdom.*;
import java.util.List;

public class ControlFactory {

	   
	public ControlFactory() {
	}
	
	private static ControlFactory _singleton = null;
	
	public static ControlFactory getInstance() {
		if (_singleton == null) {
			_singleton = new ControlFactory();
		}
		return (_singleton);
	}

	
	public Control createControl (Element controlXML) {
		Control control = new Control();
		String name = controlXML.getChildText("name");
		control.setTitle(name);
		
		String protocol = controlXML.getChildText("protocol");
		String subProtocol = controlXML.getAttributeValue("protocol_detail");
		control.setGroupType(protocol, subProtocol);

		String type = controlXML.getChildText("type");
		control.setDisplayType(type);

		switch (control.getDisplayType()) {
			case BUTTONS: case SLIDER: case SLIDER_RAW:
				String key = controlXML.getChildText("key");
				control.setKey(key);

			case BUTTONS_RAW:
				String on = controlXML.getChildText("key_on");
				String off = controlXML.getChildText("key_off");
				control.setKeyOn(on);
				control.setKeyOff(off);

			case CONTROLS:
				List keys = controlXML.getChildren("type");
			    for(Element keyElm : keys) {
			    		String value = keyElm.getAttributeValue("value");
			    		String label = keyElm.getAttributeValue("label");
			    		control.addControlKeyPair (value,label);
			    } 
				
			case NONE:

		}

		String displayTypeStr = controlXML.getChildText("display_type");
		if (displayTypeStr != null){

			control.setDisplayType(displayTypeStr);
		}
		
		return control;
	}
}
