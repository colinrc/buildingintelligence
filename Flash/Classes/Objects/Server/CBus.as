class Objects.Server.CBus extends Objects.Server.Device {
	private var sensors:Objects.Server.CBusSensors;
	private var temperatureSensors:Objects.Server.CBusTemperatureSensors;
	private var lights:Objects.Server.CBusLights;
	private var relays:Objects.Server.CBusRelays;
	private var labelNames:Objects.Server.Catalogue;
	private var labels:Objects.Server.CBusLabels;
	var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(sensors.getKeys());
		tempKeys = tempKeys.concat(lights.getKeys());
		tempKeys = tempKeys.concat(relays.getKeys());
		tempKeys = tempKeys.concat(temperatureSensors.getKeys());		
		tempKeys = tempKeys.concat(labels.getKeys());		
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (active == "Y"){
			if ((description == undefined) || (description == "")) {
				flag = "empty";
				appendValidationMsg("Description is empty");
			}		
			if ((device_type == undefined) || (device_type == "")) {
				flag = "error";
				appendValidationMsg("Device Type is invalid");
			}
			if (connection.firstChild.nodeName == "IP") {
				if ((connection.firstChild.attributes["IP_ADDRESS"] == "") || (connection.firstChild.attributes["IP_ADDRESS"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Address is empty");
				}
				else if (_global.isValidIP(connection.firstChild.attributes["IP_ADDRESS"])==false) {
					flag = "error";
					appendValidationMsg("Connection IP Address is invalid");
				}
				if ((connection.firstChild.attributes["PORT"] == "") || (connection.firstChild.attributes["PORT"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Port is empty");
				}
			}
			else{
				//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
				if ((connection.firstChild.attributes["PORT"] == "") || (connection.firstChild.attributes["PORT"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Port is empty");
				}
				if ((connection.firstChild.attributes["FLOW"] == "") || (connection.firstChild.attributes["FLOW"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Flow is invalid");
				}
				if ((connection.firstChild.attributes["DATA_BITS"] == "") || (connection.firstChild.attributes["DATA_BITS"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Data Bits is invalid");
				}
				if ((connection.firstChild.attributes["STOP_BITS"] == "") || (connection.firstChild.attributes["STOP_BITS"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Stop Bits is invalid");
				}
				if ((connection.firstChild.attributes["SUPPORTS_CD"] == "") || (connection.firstChild.attributes["SUPPORTS_CD"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Supports CD is invalid");
				}
				if ((connection.firstChild.attributes["PARITY"] == "") || (connection.firstChild.attributes["PARITY"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Parity is invalid");
				}
				if ((connection.firstChild.attributes["BAUD"] == "") || (connection.firstChild.attributes["BAUD"] ==undefined)) {
					flag = "error";
					appendValidationMsg("Connection Baud is invalid");
				}
			}
			
			//flag = getHighestFlagValue(flag, sensors.isValid());
			//flag = getHighestFlagValue(flag, lights.isValid());
			//flag = getHighestFlagValue(flag, relays.isValid());
			//flag = getHighestFlagValue(flag, temperatureSensors.isValid());
			//need to isValid connection and parameters 
			
			//appendValidationMsg("CBUS is invalid");
		}
		else{
			flag = "empty";
			appendValidationMsg("CBUS is not Active");
		}
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
		var newParameter = new XMLNode(1,"ITEM");
		newParameter.attributes["NAME"] = "LABELS";
		newParameter.attributes["VALUE"] = "Button Labels";
		newParameters.appendChild(newParameter);		
		newDevice.appendChild(newParameters);
		newDevice.appendChild(labelNames.toXML());
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
		var tempLabels = labels.toXML();
		for(var child in tempLabels.childNodes){
			newCBus.appendChild(tempLabels.childNodes[child]);
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
		newNode.appendChild(labelNames.toTree());
		newNode.appendChild(labels.toTree());
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
		//var newLabelNames = new XMLNode(1, "CATALOGUE");
		//newLabelNames.attributes["NAME"] = "Button Labels";
		//labelNames = new Objects.Server.Catalogue();
		//labelNames.setXML(newLabelNames);		
		temperatureSensors = new Objects.Server.CBusTemperatureSensors();
		//labels = new Objects.Server.CBusLabels();
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
					var tempLabels = new XMLNode(1,"labels");
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
						case "LABEL":
							tempLabels.appendChild(tempNode.childNodes[cbusDevice]);
							break;
						}
					}
					sensors.setXML(tempSensors);
					lights.setXML(tempLights);
					relays.setXML(tempRelays);
					temperatureSensors.setXML(tempTemperatureSensors);
					labels.setXML(tempLabels);
					break;
				case "CATALOGUE" :
					if(newData.childNodes[child].attributes["NAME"] == "Button Labels"){
						labelNames.setXML(newData.childNodes[child]);
					}
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
