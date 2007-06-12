class Objects.Server.CustomConnectInStrings extends Objects.BaseElement {
	private var container:String;
	private var customs:Array;
	var treeNode:XMLNode;			
	public function getKeys():Array{
		var tempKeys = new Array();
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		/*for (var custom in customs) {
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
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.custominstrings";
	}
	public function toXML():XMLNode {
		var customsNode = new XMLNode(1, "CUSTOM_CONNECTION");
		for (var custom in customs) {
			var newCustom = new XMLNode(1, "INSTRING");
			if (customs[custom].name != "") {
				newCustom.attributes["NAME"] = customs[custom].name;
			}
			if (customs[custom].to_match != "") {
				newCustom.attributes["TO_MATCH"] = customs[custom].to_match;
			}
			if (customs[custom].key != "") {
				newCustom.attributes["KEY"] = customs[custom].key;
			}
			if (customs[custom].command != "") {
				newCustom.attributes["COMMAND"] = customs[custom].command;
			}
			if (customs[custom].extra != "") {
				newCustom.attributes["EXTRA"] = customs[custom].extra;
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
		return "CustomsInStrings";
	}
	public function getName():String {
		return "Custom In Strings";
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
			newCustom.to_match = "";
			newCustom.key = "";
			newCustom.command = "";
			newCustom.extra = "";		
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newCustom.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["TO_MATCH"] != undefined) {
				newCustom.to_match = newData.childNodes[child].attributes["TO_MATCH"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newCustom.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["COMMAND"] != undefined) {
				newCustom.command = newData.childNodes[child].attributes["COMMAND"];
			}
			if (newData.childNodes[child].attributes["EXTRA"] != undefined) {
				newCustom.extra = newData.childNodes[child].attributes["EXTRA"];
			}
			customs.push(newCustom);
		}
	}
}
