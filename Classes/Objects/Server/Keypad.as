﻿class Objects.Server.Keypad extends Objects.BaseElement {
	private var container:String;
	private var keypads:Array;
	var treeNode:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var keypad in keypads){
			tempKeys.push(keypads[keypad].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var keypad in keypads) {
			if ((keypads[keypad].active != "Y") && (keypads[keypad].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			if ((keypads[keypad].display_name == undefined) || (keypads[keypad].display_name == "")) {
				flag = "error";
				appendValidationMsg("Key is invalid");
			} else {
				if (_global.isKeyUsed(keypads[keypad].display_name) == false) {
					flag = "error";
					appendValidationMsg(keypads[keypad].display_name+" key is not being used");
				}
			}
			/*if ((keypads[keypad].key == undefined) || (keypads[keypad].key == "")) {
				flag = "error";
				appendValidationMsg("Input no. is empty");
			}*/
			if ((keypads[keypad].name == undefined) || (keypads[keypad].name == "")) {
				flag = "empty";
				appendValidationMsg("Description is empty");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.keypad";
	}
	public function toXML():XMLNode {
		var keypadsNode = new XMLNode(1, container);
		for (var keypad in keypads) {
			var newKeypad = new XMLNode(1, "KEYPAD");
			if (keypads[keypad].key != "") {
				newKeypad.attributes["KEY"] = parseInt(keypads[keypad].key).toString(16);
			}
			if (keypads[keypad].name != "") {
				newKeypad.attributes["NAME"] = keypads[keypad].name;
			}
			if (keypads[keypad].active != "") {
				newKeypad.attributes["ACTIVE"] = keypads[keypad].active;
			}
			if (keypads[keypad].display_name != "") {
				newKeypad.attributes["DISPLAY_NAME"] = keypads[keypad].display_name;
			}
			keypadsNode.appendChild(newKeypad);
		}
		return keypadsNode;
	}
	public function getName():String {
		return "Keypad";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;	
		return newNode;
	}
	public function getKey():String {
		return "Keypad";
	}	
	public function getData():Object {
		return {keypads:keypads, dataObject:this};
	}
	public function setData(newData:Object){
		keypads = newData.keypads;
	}
	public function setXML(newData:XMLNode):Void {
		keypads = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newKeypad = new Object();
			newKeypad.key = "";
			newKeypad.name = "";
			newKeypad.display_name = "";
			newKeypad.active = "Y";			
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newKeypad.key = parseInt(newData.childNodes[child].attributes["KEY"],16);
			}
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newKeypad.name = newData.childNodes[child].attributes["NAME"];
			}	
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newKeypad.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newKeypad.active = newData.childNodes[child].attributes["ACTIVE"];
			}			
			keypads.push(newKeypad);
		}
	}
}
