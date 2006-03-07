class Objects.Server.Pelco extends Objects.Server.Device {
	private var cameras:Objects.Server.Cameras;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(cameras.getKeys());
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
		if (!cameras.isValid()) {
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
		var newParameters = new XMLNode(1,"PARAMETERS");
		for(var parameter in parameters){
			newParameters.appendChild(parameters[parameter]);
		}
		newDevice.appendChild(newParameters);
		var newPelco = new XMLNode(1,device_type);
		var tempCameras = cameras.toXML();
		for (var child in tempCameras.childNodes){
			newPelco.appendChild(tempCameras.childNodes[child]);
		}
		newDevice.appendChild(newPelco);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(cameras.toTree());
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "Pelco";
	}	
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";
		parameters = new Array();
		cameras = new Objects.Server.Cameras();
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
				case "PELCO" :
					cameras.setXML(newData.childNodes[child]);
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
