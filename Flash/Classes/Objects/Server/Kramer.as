﻿class Objects.Server.Kramer extends Objects.Server.Device {
	private var audiovideos:Objects.Server.AudioVideos;
	private var inputs:Objects.Server.Catalogue;
	private var avinputs:Objects.Server.Catalogue;	
	private var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(audiovideos.getKeys());
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		if ((device_type == undefined) || (device_type == "")) {
			flag = "error";
		}
		if ((active != "Y") && (active != "N")) {
			flag = "error";
		}
		if (!audiovideos.isValid()) {
			flag = "error";
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
		newParameter.attributes["NAME"] = "AV_INPUTS";		
		newParameter.attributes["VALUE"] = "Kramer AV Inputs";
		newParameters.appendChild(newParameter);
		newParameter = new XMLNode(1,"ITEM");
		newParameter.attributes["NAME"] = "AUDIO_INPUTS";		
		newParameter.attributes["VALUE"] = "Kramer Audio Inputs";
		newParameters.appendChild(newParameter);		
		newParameters.appendChild(newParameter);		
		newDevice.appendChild(newParameters);
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
		newNode.appendChild(inputs.toTree());
		newNode.appendChild(avinputs.toTree());			
		newNode.appendChild(audiovideos.toTree());
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "Kramer";
	}	
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
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
					for(var parameter in newData.childNodes[child].childNodes){
						if((newData.childNodes[child].childNodes[parameter].attributes["NAME"] != "AUDIO_INPUTS")&&(newData.childNodes[child].childNodes[parameter].attributes["NAME"] != "AV_INPUTS")){						
							parameters.push(newData.childNodes[child].childNodes[parameter]);
						}
					}
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
