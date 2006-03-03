class Objects.Server.CBusRelays extends Objects.BaseElement {
	private var container:String;
	private var relays:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var relay in relays) {
			tempKeys.push(relays[relay].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var relay in relays) {
			if ((relays[relay].attributes["ACTIVE"] != "Y") && (relays[relay].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((relays[relay].attributes["KEY"] == undefined) || (relays[relay].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((relays[relay].attributes["CHANNEL"] == undefined) || (relays[relay].attributes["CHANNEL"] == "")) {
				flag = false;
			}
			if ((relays[relay].attributes["NAME"] == undefined) || (relays[relay].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((relays[relay].attributes["DISPLAY_NAME"] == undefined) || (relays[relay].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
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
		_global.workflow.addNode("CBusRelays", newNode);
		return newNode;
	}
	public function setData(newData:Object) {
		relays = newData.relays;
	}
	public function getData():Object {
		return {relays:relays};
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
