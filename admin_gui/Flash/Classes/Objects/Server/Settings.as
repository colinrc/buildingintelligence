﻿class Objects.Server.Settings extends Objects.BaseElement {
	private var settings:XMLNode;
	private var treeNode:XMLNode;	
	public function isValid():Boolean {
		var flag = "ok";
		clearValidationMsg();
		
		var autoClose:Boolean = false;
		var iconSet:Boolean = false;
		for (var child in settings.childNodes) {
			if (settings.childNodes[child].attributes["NAME"] == "AUTOCLOSE") {
				autoClose = true;
			}
			if (settings.childNodes[child].attributes["NAME"] == "ICON") {
				iconSet = true;
			}
		}
		if (autoClose == false) {
			flag = "error";
			appendValidationMsg("Autoclose is empty");
		}
		if (iconSet == false) {
			flag = "error";
			appendValidationMsg("Icon is empty");
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
