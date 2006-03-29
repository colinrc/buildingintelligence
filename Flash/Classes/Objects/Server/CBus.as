class Objects.Server.CBus extends Objects.Server.Device {
	private var sensors:Objects.Server.CBusSensors;
	private var temperatureSensors:Objects.Server.CBusTemperatureSensors;
	private var lights:Objects.Server.CBusLights;
	private var relays:Objects.Server.CBusRelays;
	var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(sensors.getKeys());
		tempKeys = tempKeys.concat(lights.getKeys());
		tempKeys = tempKeys.concat(relays.getKeys());
		tempKeys = tempKeys.concat(temperatureSensors.getKeys());		
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if ((device_type == undefined) || (device_type == "")) {
			flag = false;
		}
		if ((description == undefined) || (description == "")) {
			flag = false;
		}		
		if ((active != "Y") && (active != "N")) {
			flag = false;
		}
		if (!sensors.isValid()) {
			flag = false;
		}
		if (!lights.isValid()) {
			flag = false;
		}
		if (!relays.isValid()) {
			flag = false;
		}
		if (!temperatureSensors.isValid()) {
			flag = false;
		}		
		//need to isValid connection and parameters 
		return flag;
	}
	public function toXML():XMLNode {
		var newDevice = new XMLNode(1, "DEVICE");
		if(device_type != ""){
			newDevice.attributes["DEVICE_TYPE"] = device_type;
		}
		if(description != ""){
			newDevice.attributes["DESCRIPTION"] = description;
		}
		if(active != "") {
			newDevice.attributes["ACTIVE"] = active;
		}
		newDevice.appendChild(connection);
		var newParameters = new XMLNode(1,"PARAMETERS");
		for(var parameter in parameters){
			newParameters.appendChild(parameters[parameter]);
		}
		newDevice.appendChild(newParameters);
		var newCBus = new XMLNode(1, device_type);
		var tempSensors = sensors.toXML();
		for (var child in tempSensors.childNodes) {
			newCBus.appendChild(tempSensors.childNodes[child]);
		}
		var tempLights = lights.toXML();
		for (var child in tempLights.childNodes) {
			newCBus.appendChild(tempLights.childNodes[child]);
		}
		var tempRelays = relays.toXML();
		for (var child in tempRelays.childNodes) {
			newCBus.appendChild(tempRelays.childNodes[child]);
		}
		var tempTemperatureSensors = temperatureSensors.toXML();
		for (var child in tempTemperatureSensors.childNodes) {
			newCBus.appendChild(tempTemperatureSensors.childNodes[child]);
		}		
		newDevice.appendChild(newCBus);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(lights.toTree());
		newNode.appendChild(relays.toTree());
		if(_global.advanced){		
			newNode.appendChild(sensors.toTree());		
			newNode.appendChild(temperatureSensors.toTree());
		}
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "CBus";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
		sensors = new Objects.Server.CBusSensors();
		lights = new Objects.Server.CBusLights();
		relays = new Objects.Server.CBusRelays();
		temperatureSensors = new Objects.Server.CBusTemperatureSensors();
		if (newData.nodeName == "DEVICE") {
			if(newData.attributes["NAME"]!=undefined){
				device_type = newData.attributes["NAME"];
			}
			if(newData.attributes["DEVICE_TYPE"]!=undefined){
				device_type = newData.attributes["DEVICE_TYPE"];
			}
			if(newData.attributes["DISPLAY_NAME"]!=undefined){			
				description = newData.attributes["DISPLAY_NAME"];
			}
			if(newData.attributes["DESCRIPTION"]!=undefined){			
				description = newData.attributes["DESCRIPTION"];
			}			
			if(newData.attributes["ACTIVE"]!=undefined){			
				active = newData.attributes["ACTIVE"];
			}
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "CBUS" :
					var tempSensors = new XMLNode(1, "sensors");
					var tempLights = new XMLNode(1, "lights");
					var tempRelays = new XMLNode (1, "relays");
					var tempTemperatureSensors = new XMLNode(1,"temperatureSensors");
					var tempNode = newData.childNodes[child];
					for (var cbusDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[cbusDevice].nodeName) {
						case "LIGHT_CBUS" :
							if(tempNode.childNodes[cbusDevice].attributes["RELAY"] == "Y"){
								tempRelays.appendChild(tempNode.childNodes[cbusDevice]);
							}
							else{					
								tempLights.appendChild(tempNode.childNodes[cbusDevice]);
							}
							break;
						case "SENSOR" :
							tempSensors.appendChild(tempNode.childNodes[cbusDevice]);
							break;
						case "TEMPERATURE":
							tempTemperatureSensors.appendChild(tempNode.childNodes[cbusDevice]);
							break;
						}
					}
					sensors.setXML(tempSensors);
					lights.setXML(tempLights);
					relays.setXML(tempRelays);
					temperatureSensors.setXML(tempTemperatureSensors);
					break;
				case "CONNECTION" :
					connection = newData.childNodes[child];
					break;
				case "PARAMETERS" :
					for(var parameter in newData.childNodes[child].childNodes){
						parameters.push(newData.childNodes[child].childNodes[parameter]);
					}
					break;
				}
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
