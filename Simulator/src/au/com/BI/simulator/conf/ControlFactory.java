package au.com.BI.simulator.conf;

import org.jdom.*;
import org.jdom.input.*;
import java.util.logging.*;


public class ControlFactory {
	public ControlFactory() {
		
	}
	
	public Control createControl (Element controlXML) {
		Control control = new Control();
		String name = controlXML.getChildText("name");
		control.setTitle(name);
		
		String protocol = controlXML.getChildText("protocol");
		String subProtocol = controlXML.getAttributeValue("protocol_detail");
		control.setGroupType(protocol, subProtocol);

		return control;
	}
}
