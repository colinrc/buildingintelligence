class Objects.Server.Controls extends Objects.BaseElement {
	private var messages:XMLNode;
	private var variables:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var variable in variables.childNodes){
			tempKeys.push(variables.childNodes[variable].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var child in messages.childNodes) {
			if ((messages.childNodes[child].attributes["NAME"] == undefined) || (messages.childNodes[child].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((messages.childNodes[child].attributes["VALUE"] == undefined) || (messages.childNodes[child].attributes["VALUE"] == "")) {
				flag = false;
			}
		}
		for (var child in variables.childNodes) {
			if ((variables.childNodes[child].attributes["NAME"] == undefined) || (variables.childNodes[child].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((variables.childNodes[child].attributes["DISPLAY_NAME"] == undefined) || (variables.childNodes[child].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
			if ((variables.childNodes[child].attributes["ACTIVE"] != "Y") && (variables.childNodes[child].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.controls";
	}
	public function toXML():XMLNode {
		var newControls = new XMLNode(1, "CONTROLS");
		newControls.appendChild(messages);
		newControls.appendChild(variables);
		return newControls;
	}
	public function getName():String {
		return "Controls";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Controls");
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({messages:messages, variables:variables});
	}
	public function setData(newData:Object):Void {
		messages = newData.messages;
		variables = newData.variables;
	}
	public function setXML(newData:XMLNode):Void {
		messages = new XMLNode();
		variables = new XMLNode();
		if (newData.nodeName == "CONTROLS") {
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "CALENDAR_MESSAGES" :
					messages = newData.childNodes[child].cloneNode(true);
					break;
				case "VARIABLES" :
					variables = newData.childNodes[child].cloneNode(true);
					break;
				}
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting CONTROLS");
		}
	}
}
