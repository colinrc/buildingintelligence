﻿class Objects.Server.DynaliteLights extends Objects.BaseElement {
	private var container:String;
	private var lights:Array;
	private var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var light in lights){
			tempKeys.push(lights[light].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var light in lights) {
			if ((lights[light].active != "Y") && (lights[light].aactive != "N")) {
				flag = "error";
				appendValidationMsg("Active Flag is invalid");
			} 
			else {
				if (lights[light].active =="Y"){
					if (_global.advanced ==true) {
						if ((lights[light].power == undefined) || (lights[light].power == "")) {
							flag = "warning";
							appendValidationMsg("Power Rating is invalid");
						}
						if ((lights[light].bla == undefined) || (lights[light].bla == "")) {
							flag = "warning";
							appendValidationMsg("Base Link is invalid");
						}
					}
					if ((lights[light].name == undefined) || (lights[light].name == "")) {
						flag = "warning";
						appendValidationMsg("Description is invalid");
					}
					if ((lights[light].area == undefined) || (lights[light].area == "")) {
						flag = "error";
						appendValidationMsg("Area is invalid");
					}
					if ((lights[light].key == undefined) || (lights[light].key == "")) {
						flag = "error";
						appendValidationMsg("Dynalite Code is invalid");
					}
					if ((lights[light].display_name == undefined) || (lights[light].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyUsed(lights[light].display_name) == false) {
							flag = "error";
							appendValidationMsg(lights[light].display_name+" key is not used");
						}
					}
				}
				else {
					if (lights[light].active =="N"){
						flag = "empty";
						appendValidationMsg("Dynalite Dimmers is not active");
					}
				}
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.dynalitelights";
	}
	public function toXML():XMLNode {
		var lightsNode = new XMLNode(1, container);
		for (var light in lights) {
			var newLight = new XMLNode(1, "LIGHT_DYNALITE");
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
			if (lights[light].area != "") {
				newLight.attributes["AREA"] = lights[light].area;
			}
			if (lights[light].power != "") {
				newLight.attributes["POWER_RATING"] = lights[light].power;
			}
			if (lights[light].bla != "") {
				newLight.attributes["BLA"] = lights[light].bla;
			}
			newLight.attributes["RELAY"] = "N";
			lightsNode.appendChild(newLight);
		}
		return lightsNode;
	}
	public function getName():String {
		return "Dimmers";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "DynaliteLights";
	}
	public function setData(newData:Object){
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
			newLight.bla = "";
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
			if (newData.childNodes[child].attributes["AREA"] != undefined) {
				newLight.area = newData.childNodes[child].attributes["AREA"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newLight.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			if (newData.childNodes[child].attributes["BLA"] != undefined) {
				newLight.bla = newData.childNodes[child].attributes["BLA"];
			}
			lights.push(newLight);
		}
	}
}
