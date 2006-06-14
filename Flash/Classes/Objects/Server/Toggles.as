﻿class Objects.Server.Toggles extends Objects.BaseElement {
	private var container:String;
	private var toggle_type:String;
	private var toggles:Array;
	private var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var toggle in toggles){
			tempKeys.push(toggles[toggle].display_name);
		}
		return tempKeys;
	}
	public function Toggles(inToggle_type:String) {
		toggle_type = inToggle_type;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var toggle in toggles) {
			if ((toggles[toggle].active != "Y") && (toggles[toggle].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			
			if (toggles[toggle].active =="Y"){
				if ((toggles[toggle].name == undefined) || (toggles[toggle].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((toggles[toggle].display_name == undefined) || (toggles[toggle].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}else {
					if (_global.isKeyUsed(toggles[toggle].display_name) == false) {
						flag = "error";
						appendValidationMsg(toggles[toggle].display_name+" key is not being used");
					}
				}
				
				if ((toggles[toggle].key == undefined) || (toggles[toggle].key == "")) {
					flag = "error";
					appendValidationMsg("Input/Output No. is empty");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("Toggles is not Active");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.toggle";
	}
	public function toXML():XMLNode {
		var togglesNode = new XMLNode(1, container);
		for (var toggle in toggles) {
			var toggleNode = new XMLNode(1, toggle_type);
			if (toggles[toggle].name != "") {
				toggleNode.attributes["NAME"] = toggles[toggle].name;
			}
			if (toggles[toggle].key != "") {
				toggleNode.attributes["KEY"] = toggles[toggle].key;
			}
			if (toggles[toggle].display_name != "") {
				toggleNode.attributes["DISPLAY_NAME"] = toggles[toggle].display_name;
			}
			if (toggles[toggle].active != "") {
				toggleNode.attributes["ACTIVE"] = toggles[toggle].active;
			}
			if (toggles[toggle].power != "") {
				toggleNode.attributes["POWER_RATING"] = toggles[toggle].power;
			}
			togglesNode.appendChild(toggleNode);
		}
		return togglesNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "Toggles";
	}	
	public function getName():String {
		switch(toggle_type){
			case"TOGGLE_INPUT":
			return "Toggle Inputs";
			break;
			case"TOGGLE_OUTPUT":
			return "Toggle Outputs";
			break;
			case"PULSE_OUTPUT":
			return "Pulse Outputs";
			break;
		}
	}
	public function getData():Object {
		return {toggles:toggles,toggle_type:toggle_type, dataObject:this};
	}
	public function setData(newData:Object):Void{
		toggles = newData.toggles;
	}
	public function setXML(newData:XMLNode):Void {
		toggles = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newToggle = new Object();
			newToggle.name = "";
			newToggle.key = "";
			newToggle.display_name = "";
			newToggle.power = "";
			newToggle.active = "Y";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newToggle.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newToggle.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newToggle.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newToggle.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newToggle.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			toggles.push(newToggle);
		}
	}
}
