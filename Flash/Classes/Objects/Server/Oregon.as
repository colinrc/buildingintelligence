class Objects.Server.Oregon extends Objects.Server.Device {
	private var sensors:Objects.Server.CBusSensors;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(sensors.getKeys());
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if((device_type == undefined)||(device_type=="")){
			flag = false;
		}
		if((active!="Y")&&(active!="N")){
			flag = false;
		}
		if(!sensors.isValid()){
			flag = false;
		}
		if (!catalogues.isValid()) {
			flag = false;
		}
		//need to isValid connection and parameters
		return flag;
	}
	public function toXML():XMLNode {	
		var newDevice = new XMLNode(1,"DEVICE");
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
		for(var child in tempCatalogues.childNodes){
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newOregon = new XMLNode(1,device_type);
		var tempSensors = sensors.toXML();
		for(var child in tempSensors.childNodes){
		newOregon.appendChild(tempSensors.childNodes[child]);
		}
		newDevice.appendChild(newOregon);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(catalogues.toTree());
		newNode.appendChild(sensors.toTree());
		newNode.object = this;
		return newNode;
	}
	public function setXML(newData:XMLNode):Void{
		device_type = "";
		description ="";
		active = "Y";		
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1,"Catalogues");
		sensors = new Objects.Server.CBusSensors();
		if(newData.nodeName == "DEVICE"){
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
			for(var child in newData.childNodes){
				switch(newData.childNodes[child].nodeName){
					case "OREGON":
					sensors.setXML(newData.childNodes[child]);
					break;
					case "CONNECTION":
					connection = newData.childNodes[child];
					break;
					case "PARAMETERS":
					parameters = newData.childNodes[child];
					break;
					case "CATALOGUE":
					tempCatalogues.appendChild(newData.childNodes[child]);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
		}
		else{
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}