﻿class Objects.Server.Nuvo extends Objects.Server.Device {
	private var audiovideos:Objects.Server.AudioVideos;
	private var inputs:Objects.Server.Catalogue;
	private var treeNode:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(audiovideos.getKeys());
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
					appendValidationMsg("Nuvo is not active");
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
		var newParameter = new XMLNode(1,"ITEM");
		newParameter.attributes["NAME"] = "AUDIO_INPUTS";
		newParameter.attributes["VALUE"] = "Nuvo Audio Inputs";
		newParameters.appendChild(newParameter);
		newDevice.appendChild(newParameters);
		newDevice.appendChild(inputs.toXML());
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newNuvo = new XMLNode(1,device_type);
		var tempAudioVideos = audiovideos.toXML();
		for (var child in tempAudioVideos.childNodes){
			newNuvo.appendChild(tempAudioVideos.childNodes[child]);
		}
		newDevice.appendChild(newNuvo);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(inputs.toTree());
		newNode.appendChild(audiovideos.toTree());
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "Nuvo";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";
		parameters = new Array();		
		inputs = new Objects.Server.Catalogue();
		var newInputs = new XMLNode(1,"CATALOGUE");
		newInputs.attributes["NAME"] = "Nuvo Audio Inputs";
		inputs.setXML(newInputs);
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
						if((newData.childNodes[child].childNodes[parameter].attributes["NAME"] != "AUDIO_INPUTS")){						
							parameters.push(newData.childNodes[child].childNodes[parameter]);
						}
					}
					break;
				case "CATALOGUE" :
					if(newData.childNodes[child].attributes["NAME"] == "Nuvo Audio Inputs"){
						inputs.setXML(newData.childNodes[child]);
					}
					break;
				case "NUVO":
					audiovideos.setXML(newData.childNodes[child]);
					break;
				}
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
