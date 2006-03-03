class Objects.Server.Customs extends Objects.BaseElement {
	private var container:String;
	private var customs:Array;
		public function getKeys():Array{
		var tempKeys = new Array();
		for(var custom in customs){
			tempKeys.push(customs[custom].display_name);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var custom in customs) {
			if ((customs[custom].attributes["ACTIVE"] != "Y") && (customs[custom].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((customs[custom].attributes["KEY_IS_REGEX"] != "Y") && (customs[custom].attributes["KEY_IS_REGEX"] != "N")) {
				flag = false;
			}
			if ((customs[custom].attributes["KEY"] == undefined) || (customs[custom].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((customs[custom].attributes["NAME"] == undefined) || (customs[custom].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((customs[custom].attributes["DISPLAY_NAME"] == undefined) || (customs[custom].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
			if ((customs[custom].attributes["COMMAND"] == undefined) || (customs[custom].attributes["COMMAND"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.custom";
	}
	public function toXML():XMLNode {
		var customsNode = new XMLNode(1, container);
		for (var custom in customs) {
			var newCustom = new XMLNode(1, "CUSTOM_INPUT");
			if (customs[custom].name != "") {
				newCustom.attributes["NAME"] = customs[custom].name;
			}
			if (customs[custom].display_name != "") {
				newCustom.attributes["DISPLAY_NAME"] = customs[custom].display_name;
			}
			if (customs[custom].key != "") {
				newCustom.attributes["KEY"] = customs[custom].key;
			}
			if (customs[custom].active != "") {
				newCustom.attributes["ACTIVE"] = customs[custom].active;
			}
			if (customs[custom].command != "") {
				newCustom.attributes["COMMAND"] = customs[custom].command;
			}
			if (customs[custom].power != "") {
				newCustom.attributes["POWER_RATING"] = customs[custom].power;
			}
			if (customs[custom].regex != "") {
				newCustom.attributes["KEY_IS_REGEX"] = customs[custom].regex;
			}
			if (customs[custom].extra != "") {
				newCustom.attributes["EXTRA"] = customs[custom].extra;
			}
			if (customs[custom].extra2 != "") {
				newCustom.attributes["EXTRA2"] = customs[custom].extra2;
			}
			if (customs[custom].extra3 != "") {
				newCustom.attributes["EXTRA3"] = customs[custom].extra3;
			}
			if (customs[custom].extra4 != "") {
				newCustom.attributes["EXTRA4"] = customs[custom].extra4;
			}
			if (customs[custom].extra5 != "") {
				newCustom.attributes["EXTRA5"] = customs[custom].extra5;
			}			
			customsNode.appendChild(newCustom);
		}
		return customsNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("Customs",newNode);
		return newNode;
	}
	public function getName():String {
		return "Custom Inputs";
	}
	public function getData():Object {
		return new Object({customs:customs});
	}
	public function setData(newData:Object){
		customs = newData.customs;
	}
	public function setXML(newData:XMLNode):Void {
		customs = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newCustom = new Object();
			newCustom.name = "";
			newCustom.display_name = "";
			newCustom.key = "";
			newCustom.active = "Y";
			newCustom.command = "";
			newCustom.power = "";
			newCustom.regex = "Y";
			newCustom.extra = "";
			newCustom.extra2 = "";
			newCustom.extra3 = "";
			newCustom.extra4 = "";
			newCustom.extra5 = "";			
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newCustom.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newCustom.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newCustom.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newCustom.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["COMMAND"] != undefined) {
				newCustom.command = newData.childNodes[child].attributes["COMMAND"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newCustom.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			if (newData.childNodes[child].attributes["KEY_IS_REGEX"] != undefined) {
				newCustom.regex = newData.childNodes[child].attributes["KEY_IS_REGEX"];
			}
			if (newData.childNodes[child].attributes["EXTRA"] != undefined) {
				newCustom.extra = newData.childNodes[child].attributes["EXTRA"];
			}
			if (newData.childNodes[child].attributes["EXTRA2"] != undefined) {
				newCustom.extra2 = newData.childNodes[child].attributes["EXTRA2"];
			}
			if (newData.childNodes[child].attributes["EXTRA3"] != undefined) {
				newCustom.extra3 = newData.childNodes[child].attributes["EXTRA3"];
			}
			if (newData.childNodes[child].attributes["EXTRA4"] != undefined) {
				newCustom.extra4 = newData.childNodes[child].attributes["EXTRA4"];
			}
			if (newData.childNodes[child].attributes["EXTRA5"] != undefined) {
				newCustom.extra5 = newData.childNodes[child].attributes["EXTRA5"];
			}			
			customs.push(newCustom);
		}
	}
}
