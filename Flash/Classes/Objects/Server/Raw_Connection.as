class Objects.Server.Raw_Connection extends Objects.Server.Device {
	private var customs:Objects.Server.Customs;
	private var raw_interfaces:Objects.Server.Raw_Interfaces;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(customs.getKeys());
		tempKeys = tempKeys.concat(raw_interfaces.getKeys());
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if ((device_type == undefined) || (device_type == "")) {
			flag = false;
		}
		if ((active != "Y") && (active != "N")) {
			flag = false;
		}
		if (!customs.isValid()) {
			flag = false;
		}
		if(!customs.isValid()){
			flag = false;
		}
		if(!raw_interfaces.isValid()){
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
		return newNode;
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
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
					parameters = newData.childNodes[child];
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
