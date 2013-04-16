class Objects.Server.Customs extends Objects.BaseElement {
	private var container:String;
	private var customs:Array;
	var treeNode:XMLNode;			
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var custom in customs){
			tempKeys.push(customs[custom].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var custom in customs) {
			if ((customs[custom].active != "Y") && (customs[custom].active != "N")) {
				flag = "error";
				appendValidationMsg("Active Flag is invalid");
			}
			
			if (customs[custom].active =="Y"){
				if ((customs[custom].name == undefined) || (customs[custom].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((customs[custom].command == undefined) || (customs[custom].command == "")) {
					flag = "warning";
					appendValidationMsg("Command is empty");
				}
				if ((customs[custom].regex!= "Y") && (customs[custom].regex != "N")) {
					flag = "error";
					appendValidationMsg("Key is RegEx. is invalid");
				}
				if ((customs[custom].key == undefined) || (customs[custom].key == "")) {
					flag = "error";
					appendValidationMsg("Input Number is empty");
				}
				
				if ((customs[custom].display_name == undefined) || (customs[custom].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}
				else {
					if (_global.isKeyUsed(customs[custom].display_name) == false) {
						flag = "error";
						appendValidationMsg(customs[custom].display_name+" key is not used");
					}
				}
				
				if ((customs[custom].extra == undefined) || (customs[custom].extra == "")) {
					flag = "warning";
					appendValidationMsg("Extra is not used");
				}
				
				if (_global.advanced == true) {
					if ((customs[custom].power == undefined) || (customs[custom].power == "")) {
						flag = "empty";
						appendValidationMsg("Power is empty");
					}
					if ((customs[custom].extra2 == undefined) || (customs[custom].extra2 == "")) {
						flag = "empty";
						appendValidationMsg("Extra2 is empty");
					}
					if ((customs[custom].extra3 == undefined) || (customs[custom].extra3 == "")) {
						flag = "empty";
						appendValidationMsg("Extra3 is empty");
					}
					if ((customs[custom].extra4 == undefined) || (customs[custom].extra4 == "")) {
						flag = "empty";
						appendValidationMsg("Extra4 is empty");
					}
					if ((customs[custom].extra5 == undefined) || (customs[custom].extra5 == "")) {
						flag = "empty";
						appendValidationMsg("Extra5 is empty");
					}
				}
			} else {
				flag = "empty";
				appendValidationMsg("Custom Inputs is not Active");
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
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "Customs";
	}
	public function getName():String {
		return "Custom Inputs";
	}
	public function getData():Object {
		return {customs:customs, dataObject:this};
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
