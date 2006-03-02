class Objects.Server.Settings extends Objects.BaseElement {
	private var settings:XMLNode;
	public function isValid():Boolean {
		var flag = true;
		/*for (var child in settings.childNodes) {
			if ((settings.childNodes[child].attributes["NAME"] == undefined) || (settings.childNodes[child].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((settings.childNodes[child].attributes["DISPLAY_NAME"] == undefined) || (settings.childNodes[child].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
			if ((settings.childNodes[child].attributes["ACTIVE"] != "Y") && (settings.childNodes[child].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.calendarsettings";
	}
	public function toXML():XMLNode {
		return settings;
	}
	public function getName():String {
		return "Calendar Settings";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Calendar_Settings");
		newNode.object = this;
		_global.workflow.addNode("Calendar_Settings",newNode);
		return newNode;
	}
	public function getData():Object {
		return {settings:settings};
	}
	public function setData(newData:Object):Void {
		settings = newData.settings;
	}
	public function setXML(newData:XMLNode):Void {
		settings = new XMLNode();
		if (newData.nodeName == "CALENDAR_MESSAGES") {
				settings = newData;
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting CALENDAR_MESSAGES");
		}
	}
}
