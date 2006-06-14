class Objects.Server.Raw_Connection extends Objects.Server.Device {
	private var customs:Objects.Server.Customs;
	private var raw_interfaces:Objects.Server.Raw_Interfaces;
	private var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(customs.getKeys());
		tempKeys = tempKeys.concat(raw_interfaces.getKeys());
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
		var newRawConnection = new XMLNode(1, device_type);
		var tempCustoms = customs.toXML();
		for(var child in tempCustoms.childNodes){
			newRawConnection.appendChild(tempCustoms.childNodes[child]);
		}
		var tempRaw_Interfaces = raw_interfaces.toXML();
		for(var child in tempRaw_Interfaces.childNodes){
			newRawConnection.appendChild(tempRaw_Interfaces.childNodes[child]);
		}
		newDevice.appendChild(newRawConnection);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Raw Connection");
		newNode.appendChild(catalogues.toTree());
		newNode.appendChild(customs.toTree());
		newNode.appendChild(raw_interfaces.toTree());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Raw_Connection";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
		raw_interfaces = new Objects.Server.Raw_Interfaces();
		customs = new Objects.Server.Customs();
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
				case "RAW_CONNECTION" :
					var tempNode = newData.childNodes[child];
					var tempCustomInputs = new XMLNode(1, device_type);
					var tempRawInterfaces = new XMLNode(1,device_type);
					for (var rawDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[rawDevice].nodeName) {
						case "CUSTOM_INPUT" :
							tempCustomInputs.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "RAW_INTERFACE" :
							tempRawInterfaces.appendChild(tempNode.childNodes[rawDevice]);
							break;
						}
					}
					customs.setXML(tempCustomInputs);
					raw_interfaces.setXML(tempRawInterfaces);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
			raw_interfaces.catalogues = catalogues;			
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
