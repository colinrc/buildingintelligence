class Objects.Server.DMX extends Objects.Server.Device {
	private var device_type:String;
	private var description:String;
	private var active:String;
	private var lights:Objects.Server.DMXLights;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(lights.getKeys());
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
				
		if ((active != "Y") && (active != "N")) {
			flag = "error";
			appendValidationMsg("Active is invalid");
		}
		else {
			if (active =="Y"){
				if ((description == undefined) || (description == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((device_type == undefined) || (device_type == "")) {
					flag = "error";
					appendValidationMsg("Device Type is invalid");
				}
				var newFlag:String;				
				newFlag = getHighestFlagValue(flag, lights.isValid());
				
				if (newFlag != "ok") {
					appendValidationMsg("Dynalite is invalid");
				}
				flag = getHighestFlagValue(flag, newFlag);
				
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
			}
			else {
				if (active =="N"){
					flag = "empty";
					appendValidationMsg("Dynalite is not active");
				}
			}
			
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
		newDevice.appendChild(newParameters);
		var newDMX = new XMLNode(1, device_type);
		var tempLights = lights.toXML();
		for (var child in tempLights.childNodes) {
			newDMX.appendChild(tempLights.childNodes[child]);
		}
		newDevice.appendChild(newDMX);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(lights.toTree());
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "DMX";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
		lights = new Objects.Server.DMXLights();
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
				case "DYNALITE" :
					var tempLights = new XMLNode(1, "lights");
					var tempNode = newData.childNodes[child];
					for (var dynaliteDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[dynaliteDevice].nodeName) {
						case "LIGHT" :
							tempLights.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						}
					}
					lights.setXML(tempLights);
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
