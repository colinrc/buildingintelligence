﻿class Objects.Server.CBusSensors extends Objects.BaseElement {
	private var container:String;
	private var sensors:Array;
	var treeNode:XMLNode;			
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var sensor in sensors) {
			tempKeys.push(sensors[sensor].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		for (var sensor in sensors) {
			if ((sensors[sensor].attributes["ACTIVE"] != "Y") && (sensors[sensor].attributes["ACTIVE"] != "N")) {
				flag = "error";
			}
			if ((sensors[sensor].attributes["KEY"] == undefined) || (sensors[sensor].attributes["KEY"] == "")) {
				flag = "error";
			}
			if ((sensors[sensor].attributes["CHANNEL"] == undefined) || (sensors[sensor].attributes["CHANNEL"] == "")) {
				flag = "error";
			}
			if ((sensors[sensor].attributes["NAME"] == undefined) || (sensors[sensor].attributes["NAME"] == "")) {
				flag = "error";
			}
			if ((sensors[sensor].attributes["DISPLAY_NAME"] == undefined) || (sensors[sensor].attributes["DISPLAY_NAME"] == "")) {
				flag = "error";
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.cbussensors";
	}
	public function toXML():XMLNode {
		var sensorsNode = new XMLNode(1, container);
		for (var sensor in sensors) {
			var newSensor = new XMLNode(1, "SENSOR");
			if (sensors[sensor].name != "") {
				newSensor.attributes["NAME"] = sensors[sensor].name;
			}
			if (sensors[sensor].display_name != "") {
				newSensor.attributes["DISPLAY_NAME"] = sensors[sensor].display_name;
			}
			if (sensors[sensor].key != "") {
				newSensor.attributes["KEY"] = sensors[sensor].key;
			}
			if (sensors[sensor].active != "") {
				newSensor.attributes["ACTIVE"] = sensors[sensor].active;
			}
			if (sensors[sensor].channel != "") {
				newSensor.attributes["CHANNEL"] = sensors[sensor].channel;
			}
			if (sensors[sensor].application != "") {
				newSensor.attributes["CBUS_APPLICATION"] = sensors[sensor].application;
			}
			if (sensors[sensor].units != "") {
				newSensor.attributes["UNITS"] = sensors[sensor].units;
			}
			sensorsNode.appendChild(newSensor);
		}
		return sensorsNode;
	}
	public function getName():String {
		if(container == "COMFORT"){
			return "CBus Sensors";
		} else{
			return "Sensors";
		}
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "CBusSensors";
	}
	public function setData(newData:Object) {
		sensors = newData.sensors;
	}
	public function getData():Object {
		return {sensors:sensors, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		sensors = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newSensor = new Object();
			newSensor.name = "";
			newSensor.display_name = "";
			newSensor.key = "";
			newSensor.active = "Y";
			newSensor.channel = "";
			newSensor.application = "";
			newSensor.units = "";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newSensor.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newSensor.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newSensor.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newSensor.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["CHANNEL"] != undefined) {
				newSensor.channel = newData.childNodes[child].attributes["CHANNEL"];
			}
			if (newData.childNodes[child].attributes["CBUS_APPLICATION"] != undefined) {
				newSensor.application = newData.childNodes[child].attributes["CBUS_APPLICATION"];
			}
			if (newData.childNodes[child].attributes["UNITS"] != undefined) {
				newSensor.units = newData.childNodes[child].attributes["UNITS"];
			}
			sensors.push(newSensor);
		}
	}
}
