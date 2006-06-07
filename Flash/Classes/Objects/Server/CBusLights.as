class Objects.Server.CBusLights extends Objects.BaseElement {
	private var container:String;
	private var lights:Array;
	var treeNode:XMLNode;			
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var light in lights) {
			tempKeys.push(lights[light].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var light in lights) {
			if ((lights[light].active != "Y") && (lights[light].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			
			if (lights[light].active =="Y"){
				if(_global.advanced){
					if ((lights[light].power == undefined) || (lights[light].power == "")) {
						flag = "empty";
						appendValidationMsg("Power Rating is empty");
					}
					if ((lights[light].application == undefined) || (lights[light].application == "")) {
						flag = "empty";
						appendValidationMsg("App. is invalid");
					}
				}
				if ((lights[light].display_name == undefined) || (lights[light].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				} else {
					if (_global.isKeyUsed(lights[light].display_name) == false) {
						flag = "error";
						appendValidationMsg(lights[light].display_name+" Key is not used");
					}
				}
				if ((lights[light].name == undefined) || (lights[light].name == "")) {
					flag = "error";
					appendValidationMsg("Description is invalid");
				}
				if ((lights[light].key == undefined) || (lights[light].key == "")) {
					flag = "error";
					appendValidationMsg("Group Addr. is invalid");
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
		return "forms.project.device.cbuslights";
	}
	public function toXML():XMLNode {
		var lightsNode = new XMLNode(1, container);
		for (var light in lights) {
			var newLight = new XMLNode(1, "LIGHT_CBUS");
			if (lights[light].name != "") {
				newLight.attributes["NAME"] = lights[light].name;
			}
			if (lights[light].display_name != "") {
				newLight.attributes["DISPLAY_NAME"] = lights[light].display_name;
			}
			if (lights[light].key != "") {
				newLight.attributes["KEY"] = lights[light].key;
			}
			if (lights[light].active != "") {
				newLight.attributes["ACTIVE"] = lights[light].active;
			}
			if (lights[light].power != "") {
				newLight.attributes["POWER_RATING"] = lights[light].power;
			}
			newLight.attributes["RELAY"] = "N";
			if (lights[light].application != "") {
				newLight.attributes["CBUS_APPLICATION"] = lights[light].application;
			}
			lightsNode.appendChild(newLight);
		}
		return lightsNode;
	}
	public function getName():String {
		if(container == "COMFORT"){
			return "CBus Dimmers";
		} else{
			return "Dimmers";
		}				
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "CBusLights";
	}
	public function setData(newData:Object) {
		lights = newData.lights;
	}
	public function getData():Object {
		return {lights:lights, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		lights = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newLight = new Object();
			newLight.name = "";
			newLight.display_name = "";
			newLight.key = "";
			newLight.active = "Y";
			newLight.power = "";
			newLight.application = "38";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newLight.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newLight.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newLight.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newLight.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newLight.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			if (newData.childNodes[child].attributes["CBUS_APPLICATION"] != undefined) {
				newLight.application = newData.childNodes[child].attributes["CBUS_APPLICATION"];
			}
			lights.push(newLight);
		}
	}
}
