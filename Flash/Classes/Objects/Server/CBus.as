class Objects.Server.CBus extends Objects.Server.Device {
	private var sensors:Objects.Server.CBusSensors;
	private var lights:Objects.Server.CBusLights;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(sensors.getKeys());
		tempKeys = tempKeys.concat(lights.getKeys());
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
		if (!catalogues.isValid()) {
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
		newDevice.appendChild(parameters);
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newCBus = new XMLNode(1, device_type);
		var tempSensors = sensors.toXML();
		for (var child in tempSensors.childNodes) {
			newCBus.appendChild(tempSensors.childNodes[child]);
		}
		var tempLights = lights.toXML();
		for (var child in tempLights.childNodes) {
			newCBus.appendChild(tempLights.childNodes[child]);
		}
		newDevice.appendChild(newCBus);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(catalogues.toTree());		
		newNode.appendChild(sensors.toTree());
		newNode.appendChild(lights.toTree());
		newNode.object = this;
		_global.workflow.addNode("CBus",newNode);
		return newNode;
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1, "Catalogues");
		sensors = new Objects.Server.CBusSensors();
		lights = new Objects.Server.CBusLights();
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
					var tempNode = newData.childNodes[child];
					for (var cbusDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[cbusDevice].nodeName) {
						case "LIGHT_CBUS" :
							tempLights.appendChild(tempNode.childNodes[cbusDevice]);
							break;
						case "SENSOR" :
							tempSensors.appendChild(tempNode.childNodes[cbusDevice]);
							break;
						}
					}
					sensors.setXML(tempSensors);
					lights.setXML(tempLights);
					break;
				case "CONNECTION" :
					connection = newData.childNodes[child];
					break;
				case "PARAMETERS" :
					parameters = newData.childNodes[child];
					break;
				case "CATALOGUE" :
					tempCatalogues.appendChild(newData.childNodes[child]);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
