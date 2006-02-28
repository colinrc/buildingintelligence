class Objects.Server.CBusTemperatureSensors extends Objects.BaseElement {
	private var container:String;
	private var sensors:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var sensor in sensors) {
			tempKeys.push(sensors[sensor].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var sensor in sensors) {
			if ((sensors[sensor].attributes["ACTIVE"] != "Y") && (sensors[sensor].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((sensors[sensor].attributes["KEY"] == undefined) || (sensors[sensor].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((sensors[sensor].attributes["NAME"] == undefined) || (sensors[sensor].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((sensors[sensor].attributes["DISPLAY_NAME"] == undefined) || (sensors[sensor].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.cbustemperaturesensors";
	}
	public function toXML():XMLNode {
		var sensorsNode = new XMLNode(1, container);
		for (var sensor in sensors) {
			var newSensor = new XMLNode(1, "TEMPERATURE");
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
			sensorsNode.appendChild(newSensor);
		}
		return sensorsNode;
	}
	public function getName():String {
		return "Temperatures";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		_global.workflow.addNode("CBusTemperatures", newNode);
		return newNode;
	}
	public function setData(newData:Object) {
		sensors = newData.sensors;
	}
	public function getData():Object {
		return new Object({sensors:sensors});
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
			sensors.push(newSensor);
		}
	}
}
