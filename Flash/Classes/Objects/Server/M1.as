class Objects.Server.M1 extends Objects.Server.Device {
	private var device_type:String;
	private var description:String;
	private var active:String;
	private var contacts:Objects.Server.ContactClosures;
	private var toggle_outputs:Objects.Server.Toggles;
	private var sensors: Objects.Server.M1Sensors;

	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(contacts.getKeys());
		tempKeys = tempKeys.concat(toggle_outputs.getKeys());
		tempKeys = tempKeys.concat(sensors.getKeys());
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
					flag = "warning";
					appendValidationMsg("Description is invalid");
				}
				if ((device_type == undefined) || (device_type == "")) {
					flag = "error";
					appendValidationMsg("Device Type is invalid");
				}
				var newFlag:String;				
				newFlag = getHighestFlagValue(flag, contacts.isValid());
				newFlag = getHighestFlagValue(flag, toggle_outputs.isValid());
				newFlag = getHighestFlagValue(flag, sensors.isValid());
				if (newFlag != "ok") {
					appendValidationMsg("M1 is invalid");
				}
				flag = getHighestFlagValue(flag, newFlag);
				
				if (connection.firstChild.nodeName == "IP") {
					if ((connection.firstChild.attributes["IP_ADDRESS"] == "") || (connection.firstChild.attributes["IP_ADDRESS"] ==undefined)) {
						flag = "error";
						appendValidationMsg("Connection Address is invalid");
					}
					if ((connection.firstChild.attributes["PORT"] == "") || (connection.firstChild.attributes["PORT"] ==undefined)) {
						flag = "error";
						appendValidationMsg("Connection Port is invalid");
					}
				}
				else{
					//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
					if ((connection.firstChild.attributes["PORT"] == "") || (connection.firstChild.attributes["PORT"] ==undefined)) {
						flag = "error";
						appendValidationMsg("Connection Port is invalid");
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
					appendValidationMsg("M1 is not active");
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
		var newM1 = new XMLNode(1, device_type);
		var tempToggleOutputs = toggle_outputs.toXML();
		for(var child in tempToggleOutputs.childNodes){
			newM1.appendChild(tempToggleOutputs.childNodes[child]);
		}
		var tempContacts = contacts.toXML();
		for (var child in tempContacts.childNodes) {
			newM1.appendChild(tempContacts.childNodes[child]);
		}
		var tempSensors = sensors.toXML();
		for (var child in tempSensors.childNodes) {
			newM1.appendChild(tempSensors.childNodes[child]);
		}
		newDevice.appendChild(newM1);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(contacts.toTree());
		newNode.appendChild(toggle_outputs.toTree());
		newNode.appendChild(sensors.toTree());
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "M1";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
		contacts = new Objects.Server.ContactClosures();
		sensors = new Objects.Server.M1Sensors();
		toggle_outputs = new Objects.Server.Toggles("TOGGLE_OUTPUT");
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
				case "M1" :
					var tempContacts = new XMLNode(1, "contact closures");
					var tempToggleOutputs = new XMLNode(1,device_type);
					var tempSensors = new XMLNode(1,"sensors");
					var tempNode = newData.childNodes[child];
					for (var M1Device in tempNode.childNodes) {
						switch (tempNode.childNodes[M1Device].nodeName) {
						case "CONTACT_CLOSURE" :
							tempContacts.appendChild(tempNode.childNodes[M1Device]);
							break;
						case "TOGGLE_OUTPUT":
							tempToggleOutputs.appendChild(tempNode.childNodes[M1Device]);
							break;
						case "TOGGLE_OUTPUT":
							tempSensors.appendChild(tempNode.childNodes[M1Device]);
							break;
						}
					}
					contacts.setXML(tempContacts);
					toggle_outputs.setXML(tempToggleOutputs);
					sensors.setXML(tempSensors);
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
