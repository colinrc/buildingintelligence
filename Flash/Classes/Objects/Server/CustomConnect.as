class Objects.Server.CustomConnect extends Objects.Server.Device {
	private var customKeys:Objects.Server.CustomConnectKeys;
	private var inStrings:Objects.Server.CustomConnectInStrings;
	private var outStrings:Objects.Server.CustomConnectOutStrings;
	private var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(customKeys.getKeys());
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
				
				for (var param in parameters) {
					if ((parameters[param].attributes["NAME"] == undefined) || (parameters[param].attributes["NAME"] == "")) {
						flag = "error";
						appendValidationMsg("Param Name is empty");
					}
					if ((parameters[param].attributes["VALUE"] == undefined) || (parameters[param].attributes["VALUE"] == "")) {
						flag = "error";
						appendValidationMsg("Param Value is empty");
					}
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
			}
			else {
				if (active =="N"){
					flag = "empty";
					appendValidationMsg("Raw Connection is not active");
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
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newCustomConnection = new XMLNode(1, device_type);
		var tempCustomKeys = customKeys.toXML();
		for(var child in tempCustomKeys.childNodes){
			newCustomConnection.appendChild(tempCustomKeys.childNodes[child]);
		}
		var tempInStrings = inStrings.toXML();
		for(var child in tempInStrings.childNodes){
			newCustomConnection.appendChild(tempInStrings.childNodes[child]);
		}
		var tempOutStrings = outStrings.toXML();
		for(var child in tempOutStrings.childNodes){
			newCustomConnection.appendChild(tempOutStrings.childNodes[child]);
		}
		newDevice.appendChild(newCustomConnection);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Custom Connect");
		newNode.appendChild(catalogues.toTree());
		newNode.appendChild(customKeys.toTree());
		newNode.appendChild(inStrings.toTree());
		newNode.appendChild(outStrings.toTree());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Custom_Connect";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
		customKeys = new Objects.Server.CustomConnectKeys();
		inStrings = new Objects.Server.CustomConnectInStrings();
		outStrings = new Objects.Server.CustomConnectOutStrings();		
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1, "Catalogues");
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
				case "CONNECTION" :
					connection = newData.childNodes[child];
					break;
				case "PARAMETERS" :
					for(var parameter in newData.childNodes[child].childNodes){
						parameters.push(newData.childNodes[child].childNodes[parameter]);
					}
					break;
				case "CATALOGUE" :
					tempCatalogues.appendChild(newData.childNodes[child]);
					break;
				case "CUSTOM_CONNECT" :
					var tempNode = newData.childNodes[child];
					var tempCustomKeys = new XMLNode(1, "CUSTOM_CONNECT");
					var tempInStrings = new XMLNode(1,"CUSTOM_CONNECT");
					var tempOutStrings = new XMLNode(1,"CUSTOM_CONNECT");
					for (var rawDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[rawDevice].nodeName) {
						case "KEY" :
							tempCustomKeys.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "INSTRING" :
							tempInStrings.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "OUTSTRING" :
							tempOutStrings.appendChild(tempNode.childNodes[rawDevice]);
							break;
						}
					}
					customKeys.setXML(tempCustomKeys);
					inStrings.setXML(tempInStrings);
					outStrings.setXML(tempOutStrings);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
//			raw_interfaces.catalogues = catalogues;			
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
