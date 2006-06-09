class Objects.Server.M1Sensors extends Objects.BaseElement {
	private var container:String;
	private var sensors:Array;
	private var treeNode:XMLNode;	
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var sensor in sensors) {
			tempKeys.push(sensors[sensor].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var sensor in sensors) {
			if ((sensors[sensor].active != "Y") && (sensors[sensor].active != "N")) {
				flag = "error";
				appendValidationMsg("Active is invalid");
			}
			else {
				if (sensors[sensor].active =="Y"){
					if ((sensors[sensor].key == undefined) || (sensors[sensor].key == "")) {
						flag = "error";
						appendValidationMsg("Input/Output no. is empty");
					}
					if ((sensors[sensor].name == undefined) || (sensors[sensor].name == "")) {
						flag = "error";
						appendValidationMsg("Description is empty");
					}
					if ((sensors[sensor].display_name == undefined) || (sensors[sensor].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyUsed(sensors[sensor].display_name) == false) {
							flag = "error";
							appendValidationMsg(sensors[sensor].display_name+" key is not used");
						}
					}
					if ((sensors[sensor].group == undefined) || (sensors[sensor].group == "")) {
						flag = "error";
						appendValidationMsg("Group is empty");
					}
					if ((sensors[sensor].units == undefined) || (sensors[sensor].units == "")) {
						flag = "error";
						appendValidationMsg("Units is empty");
					}
				}
				else {
					if (sensors[sensor].active =="N"){
						flag = "empty";
						appendValidationMsg("M1 Sensors is not active");
					}
				}
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.m1sensors";
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
			if (sensors[sensor].group != "") {
				newSensor.attributes["GROUP"] = sensors[sensor].group;
			}
			if (sensors[sensor].units != "") {
				newSensor.attributes["UNITS"] = sensors[sensor].units;
			}
			sensorsNode.appendChild(newSensor);
		}
		return sensorsNode;
	}
	public function getName():String {
		return "Sensors";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "M1Sensors";
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
			newSensor.group = "";
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
			if (newData.childNodes[child].attributes["GROUP"] != undefined) {
				newSensor.group = newData.childNodes[child].attributes["GROUP"];
			}
			if (newData.childNodes[child].attributes["UNITS"] != undefined) {
				newSensor.units = newData.childNodes[child].attributes["UNITS"];
			}
			sensors.push(newSensor);
		}
	}
}