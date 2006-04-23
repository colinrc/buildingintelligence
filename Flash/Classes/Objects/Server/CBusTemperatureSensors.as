class Objects.Server.CBusTemperatureSensors extends Objects.BaseElement {
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
		clearValidationMsg();
		for (var sensor in sensors) {
			if ((sensors[sensor].active != "Y") && (sensors[sensor].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			
			if (sensors[sensor].active =="Y"){
				if ((sensors[sensor].key == undefined) || (sensors[sensor].key == "")) {
					flag = "error";
					appendValidationMsg("Unit Addr.(key) is invalid");
				} else {
					if (_global.isKeyUsed(sensors[sensor].key) == false) {
						flag = "error";
						appendValidationMsg(sensors[sensor].key+" key is not being used");
					}
				}
				if ((sensors[sensor].name == undefined) || (sensors[sensor].name == "")) {
					flag = "error";
					appendValidationMsg("Description is invalid");
				}
				if ((sensors[sensor].display_name == undefined) || (sensors[sensor].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key(display name) is invalid");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("CBUS Temp Sensors is not Active");
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
		if(container == "COMFORT"){
			return "CBus Temperature Sensors";
		} else{
			return "Temperatures Sensors";
		}						
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "CBusTemperatures";
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
