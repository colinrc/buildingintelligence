class Objects.Server.Settings extends Objects.BaseElement {
	private var settings:XMLNode;
	private var treeNode:XMLNode;	
	public function isValid():Boolean {
		var flag = "ok";
		clearValidationMsg();
		for (var child in settings.childNodes) {
			if ((settings.childNodes[child].active != "Y") && (settings.childNodes[child].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			
			if (settings.childNodes[child].active =="Y"){
				if ((settings.childNodes[child].display_name == undefined) || (settings.childNodes[child].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}else {
					if (_global.isKeyUsed(settings.childNodes[child].display_name) == false) {
						flag = "error";
						appendValidationMsg(settings.childNodes[child].display_name+" key is not being used");
					}
				}
				if ((settings.childNodes[child].name == undefined) || (settings.childNodes[child].name == "")) {
					flag = "error";
					appendValidationMsg("Description is invalid");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("Settings is not Active");
			}
		}
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
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "Calendar_Settings";
	}
	public function getData():Object {
		return {settings:settings, dataObject:this};
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
