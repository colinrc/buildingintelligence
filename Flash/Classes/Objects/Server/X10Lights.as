class Objects.Server.X10Lights extends Objects.BaseElement {
	private var container:String;
	private var lights:Array;
	private var treeNode:XMLNode;	
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var light in lights) {
			tempKeys.push(lights[light].display_name);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var light in lights) {
			if ((lights[light].attributes["ACTIVE"] != "Y") && (lights[light].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((lights[light].attributes["KEY"] == undefined) || (lights[light].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((lights[light].attributes["NAME"] == undefined) || (lights[light].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((lights[light].attributes["DISPLAY_NAME"] == undefined) || (lights[light].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.x10lights";
	}
	public function toXML():XMLNode {
		var lightsNode = new XMLNode(1, container);
		for (var light in lights) {
			var lightNode = new XMLNode(1, "LIGHT_X10");
			if (lights[light].name != "") {
				lightNode.attributes["NAME"] = lights[light].name;
			}
			if (lights[light].key != "") {
				lightNode.attributes["KEY"] = lights[light].key;
			}
			if (lights[light].display_name != "") {
				lightNode.attributes["DISPLAY_NAME"] = lights[light].display_name;
			}
			if (lights[light].active != "") {
				lightNode.attributes["ACTIVE"] = lights[light].active;
			}
			if (lights[light].power != "") {
				lightNode.attributes["POWER_RATING"] = lights[light].power;
			}
			if (lights[light].x10 != "") {
				lightNode.attributes["X10HOUSE_CODE"] = lights[light].x10;
			}
			lightsNode.appendChild(lightNode);
		}
		return lightsNode;
	}
	public function getName():String {
		return "X10 Lights";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "X10Lights";
	}			
	public function getData():Object {
		return {lights:lights, dataObject:this};
	}
	public function setData(newData:Object):Void {
		lights = newData.lights;
	}
	public function setXML(newData:XMLNode):Void {
		lights = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newLight = new Object();
			newLight.name = "";
			newLight.key = "";
			newLight.display_name = "";
			newLight.power = "";
			newLight.active = "Y";
			newLight.x10 = "";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newLight.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newLight.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newLight.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newLight.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newLight.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["X10HOUSE_CODE"] != undefined) {
				newLight.x10 = newData.childNodes[child].attributes["X10HOUSE_CODE"];
			}
			lights.push(newLight);
		}
	}
}
