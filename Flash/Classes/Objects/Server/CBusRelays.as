class Objects.Server.CBusRelays extends Objects.BaseElement {
	private var container:String;
	private var relays:Array;
	var treeNode:XMLNode;			
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var relay in relays) {
			tempKeys.push(relays[relay].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var relay in relays) {
			if ((relays[relay].active != "Y") && (relays[relay].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			
			if (relays[relay].active =="Y"){
				if ((relays[relay].power == undefined) || (relays[relay].power == "")) {
					flag = "empty";
					appendValidationMsg("Power Rating is empty");
				}
				if ((relays[relay].key == undefined) || (relays[relay].key == "")) {
					flag = "error";
					appendValidationMsg("Group Addr.(key) is invalid");
				} else {
					if (_global.isKeyUsed(relays[relay].key) == false) {
						flag = "error";
						appendValidationMsg(relays[relay].key+" key is not being used");
					}
				}
				if ((relays[relay].application == undefined) || (relays[relay].application == "")) {
					flag = "error";
					appendValidationMsg("App. is invalid");
				}
				if ((relays[relay].name == undefined) || (relays[relay].name == "")) {
					flag = "error";
					appendValidationMsg("Description is invalid");
				}
				if ((relays[relay].display_name == undefined) || (relays[relay].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("CBUS Dimmers is not Active");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.cbusrelays";
	}
	public function toXML():XMLNode {
		var relaysNode = new XMLNode(1, container);
		for (var relay in relays) {
			var newRelay = new XMLNode(1, "LIGHT_CBUS");
			if (relays[relay].name != "") {
				newRelay.attributes["NAME"] = relays[relay].name;
			}
			if (relays[relay].display_name != "") {
				newRelay.attributes["DISPLAY_NAME"] = relays[relay].display_name;
			}
			if (relays[relay].key != "") {
				newRelay.attributes["KEY"] = relays[relay].key;
			}
			if (relays[relay].active != "") {
				newRelay.attributes["ACTIVE"] = relays[relay].active;
			}
			if (relays[relay].power != "") {
				newRelay.attributes["POWER_RATING"] = relays[relay].power;
			}
			newRelay.attributes["RELAY"] = "Y";
			
			if (relays[relay].application != "") {
				newRelay.attributes["CBUS_APPLICATION"] = relays[relay].application;
			}
			relaysNode.appendChild(newRelay);
		}
		return relaysNode;
	}
	public function getName():String {
		if(container == "COMFORT"){
			return "CBus Relays";
		} else{
			return "Relays";
		}		
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "CBusRelays";
	}
	public function setData(newData:Object) {
		relays = newData.relays;
	}
	public function getData():Object {
		return {relays:relays, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		relays = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newRelay = new Object();
			newRelay.name = "";
			newRelay.display_name = "";
			newRelay.key = "";
			newRelay.active = "Y";
			newRelay.power = "";
			newRelay.application = "38";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newRelay.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newRelay.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newRelay.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newRelay.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newRelay.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			if (newData.childNodes[child].attributes["CBUS_APPLICATION"] != undefined) {
				newRelay.application = newData.childNodes[child].attributes["CBUS_APPLICATION"];
			}
			relays.push(newRelay);
		}
	}
}
