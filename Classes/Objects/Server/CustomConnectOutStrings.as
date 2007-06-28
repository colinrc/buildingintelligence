class Objects.Server.CustomConnectOutStrings extends Objects.BaseElement {
	private var container:String;
	private var customs:Array;
	var treeNode:XMLNode;
	public function getKeys():Array {
		var tempKeys = new Array();
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		/*
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
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.customoutstrings";
	}
	public function toXML():XMLNode {
		var customsNode = new XMLNode(1, "CUSTOM_CONNECTION");
		for (var custom in customs) {
			var newCustom = new XMLNode(1, "OUTSTRING");
			if (customs[custom].if_command != "") {
				newCustom.attributes["IF_COMMAND"] = customs[custom].if_command;
			}
			if (customs[custom].if_extra != "") {
				newCustom.attributes["IF_EXTRA"] = customs[custom].if_extra;
			}
			if (customs[custom].name != "") {
				newCustom.attributes["NAME"] = customs[custom].name;
			}
			if (customs[custom].value != "") {
				newCustom.attributes["VALUE"] = customs[custom].value;
			}
			customsNode.appendChild(newCustom);
		}
		return customsNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "CustomOutStrings";
	}
	public function getName():String {
		return "Custom Out Strings";
	}
	public function getData():Object {
		return {customs:customs, dataObject:this};
	}
	public function setData(newData:Object) {
		customs = newData.customs;
	}
	public function setXML(newData:XMLNode):Void {
		customs = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newCustom = new Object();
						/*
			<OUTSTRING IF_COMMAND="volume" IF_EXTRA="%NUMBER%"  NAME="Set Volume" VALUE="AU_VOL %KEY% vol %SCALE 0 60 %"  />
			*/
			newCustom.name = "";
			newCustom.if_command = "";
			newCustom.if_extra = "";
			newCustom.value = "";

			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newCustom.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["IF_COMMAND"] != undefined) {
				newCustom.if_command = newData.childNodes[child].attributes["IF_COMMAND"];
			}
			if (newData.childNodes[child].attributes["IF_EXTRA"] != undefined) {
				newCustom.if_extra = newData.childNodes[child].attributes["IF_EXTRA"];
			}
			if (newData.childNodes[child].attributes["VALUE"] != undefined) {
				newCustom.value = newData.childNodes[child].attributes["VALUE"];
			}
			customs.push(newCustom);
		}
	}
}
