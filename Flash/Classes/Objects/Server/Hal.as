class Objects.Server.Hal extends Objects.Server.Device {
	private var audiovideos:Objects.Server.AudioVideos;
	private var inputs:Objects.Server.Catalogue;
	private var functions:Objects.Server.Catalogue;		
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(audiovideos.getKeys());
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
		var newParameter = new XMLNode(1,"ITEM");
		newParameter.attributes["NAME"] = "INPUTS";
		newParameter.attributes["VALUE"] = "HAL Inputs";
		newParameters.appendChild(newParameter);
		newParameter = new XMLNode(1,"ITEM");
		newParameter.attributes["NAME"] = "FUNCTIONS";
		newParameter.attributes["VALUE"] = "HAL Functions";
		newParameters.appendChild(newParameter);		
		newDevice.appendChild(newParameters);
		newDevice.appendChild(inputs.toXML());
		newDevice.appendChild(functions.toXML());		
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newHal = new XMLNode(1,device_type);
		var tempAudioVideos = audiovideos.toXML();
		for (var child in tempAudioVideos.childNodes){
			newHal.appendChild(tempAudioVideos.childNodes[child]);
		}
		newDevice.appendChild(newHal);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(inputs.toTree());
		newNode.appendChild(functions.toTree());			
		newNode.appendChild(audiovideos.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getKey():String {
		return "Hal";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";
		parameters = new Array();		
		inputs = new Objects.Server.Catalogue();
		var newInputs = new XMLNode(1,"CATALOGUE");
		newInputs.attributes["NAME"] = "HAL Inputs";
		inputs.setXML(newInputs);
		functions = new Objects.Server.Catalogue();		
		var newFunctions = new XMLNode(1, "CATALOGUE");
		newFunctions.attributes["NAME"] = "HAL Functions";
		functions.setXML(newFunctions);				
		audiovideos = new Objects.Server.AudioVideos();
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
						if((newData.childNodes[child].childNodes[parameter].attributes["NAME"] != "INPUTS")&&(newData.childNodes[child].childNodes[parameter].attributes["NAME"] != "FUNCTIONS")){						
							parameters.push(newData.childNodes[child].childNodes[parameter]);
						}
					}
					break;
				case "CATALOGUE" :
					if(newData.childNodes[child].attributes["NAME"] == "HAL Inputs"){
						inputs.setXML(newData.childNodes[child]);
					} else if(newData.childNodes[child].attributes["NAME"] == "HAL Functions"){
						functions.setXML(newData.childNodes[child]);						
					}
					break;
				case "HAL":
					audiovideos.setXML(newData.childNodes[child]);
					break;
				}
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
