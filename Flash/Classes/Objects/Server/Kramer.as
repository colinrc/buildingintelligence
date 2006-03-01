class Objects.Server.Kramer extends Objects.Server.Device {
	private var audiovideos:Objects.Server.AudioVideos;
	private var inputs:Objects.Server.Catalogue;
	private var avinputs:Objects.Server.Catalogue;	
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
		if (!audiovideos.isValid()) {
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
		newDevice.appendChild(inputs.toXML());
		newDevice.appendChild(avinputs.toXML());
		var newKramer = new XMLNode(1,device_type);
		var tempAudioVideos = audiovideos.toXML();
		for (var child in tempAudioVideos.childNodes){
			newKramer.appendChild(tempAudioVideos.childNodes[child]);
		}
		newDevice.appendChild(newKramer);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		if(_global.advanced){
			newNode.appendChild(inputs.toTree());
			newNode.appendChild(avinputs.toTree());			
		}				
		newNode.appendChild(audiovideos.toTree());
		newNode.object = this;
		_global.workflow.addNode("Kramer",newNode);
		return newNode;
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		inputs = new Objects.Server.Catalogue();
		var newInputs = new XMLNode(1,"CATALOGUE");
		newInputs.attributes["NAME"] = "Kramer Audio Inputs";
		inputs.setXML(newInputs);
		avinputs = new Objects.Server.Catalogue();		
		var newFunctions = new XMLNode(1, "CATALOGUE");
		newFunctions.attributes["NAME"] = "Kramer AV Inputs";
		avinputs.setXML(newFunctions);		
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
					parameters = newData.childNodes[child];
					break;
				case "CATALOGUE" :
					if(newData.childNodes[child].attributes["NAME"] == "Kramer Audio Inputs"){
						inputs.setXML(newData.childNodes[child]);
					} else if(newData.childNodes[child].attributes["NAME"] == "Kramer AV Inputs"){
						avinputs.setXML(newData.childNodes[child]);						
					}
					break;
				case "KRAMER":
					audiovideos.setXML(newData.childNodes[child]);
					break;
				}
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
