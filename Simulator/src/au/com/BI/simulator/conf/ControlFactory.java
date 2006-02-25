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

	
	public Control createControl (Element controlXML) throws NullPointerException {
		Control control = new Control();
		String name = controlXML.getChildText("name");
		control.setTitle(name);
		
		String protocol = controlXML.getChildText("protocol");
		String subProtocol = controlXML.getAttributeValue("protocol_detail");
		control.setGroupType(protocol, subProtocol);

		Element typeXML = controlXML.getChild("type");
		String type = typeXML.getAttributeValue("value");
		control.setDisplayType(type);

		switch (control.getDisplayType()) {
			case BUTTONS: case SLIDER: case SLIDER_RAW:
				String key = typeXML.getChildText("key");
				control.setKey(key);
				break;

			case BUTTONS_RAW:
				String on = typeXML.getChildText("key_on");
				String off = typeXML.getChildText("key_off");
				control.setKeyOn(on);
				control.setKeyOff(off);
				break;

			case CONTROLS:
				List<Element> keys = (List<Element>)typeXML.getChildren("key");
			    for(Element keyElm : keys) {
			    		String value = keyElm.getText();
			    		String label = keyElm.getAttributeValue("label");
			    		control.addControlKeyPair (value,label);
			    }
			    break;
				
			case NONE:

		}

		String displayTypeStr = controlXML.getChildText("display_type");
		if (displayTypeStr != null){

			control.setDisplayType(displayTypeStr);
		}
		
		return control;
	}
}
