package au.com.BI.simulator.conf;

import org.jdom.*;
import java.util.List;
import au.com.BI.simulator.util.Utility;

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
		String subProtocol = controlXML.getChildText("protocol_detail");
		control.setGroupType(protocol, subProtocol);

		Element typeXML = controlXML.getChild("type");
		String type = typeXML.getAttributeValue("value");
		control.setDisplayType(type);

		switch (control.getDisplayType()) {
		    case BUTTONS: case SLIDER: case SLIDER_RAW: 
				String key = typeXML.getChildText("key");
				control.setKey(key);
				break;
				
		    case DLT:
				String dlt_key = typeXML.getChildText("key");
				control.setKey(dlt_key);
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
			    		String parseString = Utility.parseString (value);
			    		control.addControlKeyPair (label,parseString);
			    }
			    break;
			    
		    case AV:
			    String av_key = typeXML.getChildText("key");
			    control.setKey(av_key);

			    List<Element> srcs = (List<Element>)typeXML.getChildren("src");
			    for(Element keyElm : srcs) {
			    		String value = keyElm.getText();
			    		String label = keyElm.getAttributeValue("label");
			    		String parseString = Utility.parseString (value);
			    		control.addControlKeyPair (label,parseString);
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
