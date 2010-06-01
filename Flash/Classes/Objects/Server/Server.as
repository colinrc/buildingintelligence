﻿class Objects.Server.Server extends Objects.BaseElement {
	private var description:String;
	private var controls:Objects.Server.Controls;
	private var settings:Objects.Server.Settings;
	private var macros:Objects.Server.Macros;
	private var scripts:Objects.Server.Scripts;
	private var devices:Array;
	private var treeNode:XMLNode;
	private var JROBIN:XMLNode;
	private var clients:Array;
	public function Server(){
		description = "";
		devices = new Array();
		controls = new Objects.Server.Controls();
		settings = new Objects.Server.Settings();
		macros = new Objects.Server.Macros();
		scripts = new Objects.Server.Scripts();
		clients = new Array();
		/**Append default client device here*/		
		var new_client = new Objects.Client.Client();
		new_client.setXML(_global.default_client_xml.firstChild);
		//mdm.Dialogs.prompt(_global.default_client_xml);
		JROBIN = null;
		new_client.description = "Client-1";
		new_client.id = _global.formDepth++;
		clients.push(new_client);		
	}
	public function deleteSelf(){
		treeNode.removeNode();
	}			
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var device in devices){
			tempKeys = tempKeys.concat(devices[device].getKeys());
		}
		tempKeys = tempKeys.concat(controls.getKeys());
		//mdm.Dialogs.prompt(controls.getKeys());
		tempKeys = tempKeys.sort();
		var keys = new Array();
		var lastKey:String;
		for(var tempKey in tempKeys){
			if(tempKeys[tempKey] != lastKey){
				keys.push(tempKeys[tempKey]);
				lastKey = tempKeys[tempKey];
				//What if not in order
			}
		}
		return keys;
	}
	public function vaildateKeys():Array{
		var keys = new Array();
		return keys;
	}
	
	public function isValid():String {
		var flag = "ok";
		flag = getHighestFlagValue(flag, controls.isValid());
		for (var device in devices) {
			flag = getHighestFlagValue(flag, devices[device].isValid());
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.server";
	}
	public function toXML():XMLNode {
		var serverNode = new XMLNode(1, "CONFIG");
		var descriptionNode = new XMLNode(1, "DESC");
		descriptionNode.appendChild(new XMLNode(3, description));
		serverNode.appendChild(descriptionNode);
		var controlNode = new XMLNode(1,"CONTROLS");
		controlNode.appendChild(controls.toXML());
		controlNode.appendChild(settings.toXML());
		serverNode.appendChild(controlNode);
		if (JROBIN != null)
			serverNode.appendChild(JROBIN);
		for (var device in devices) {
			serverNode.appendChild(devices[device].toXML());
		}
		return serverNode;
	}
	public function getMacros():Array{
		return macros.getMacros();
	}
	public function getScripts():XMLNode{
		return scripts.toXML();
	}
	public function toProject():XMLNode {
		var serverNode = new XMLNode(1, "CONFIG");
		var descriptionNode = new XMLNode(1, "DESC");
		descriptionNode.appendChild(new XMLNode(3, description));
		serverNode.appendChild(descriptionNode);
		var controlNode = new XMLNode(1,"CONTROLS");
		controlNode.appendChild(controls.toXML());
		controlNode.appendChild(settings.toXML());
		serverNode.appendChild(controlNode);
		serverNode.appendChild(macros.toXML());
		//serverNode.appendChild(scripts.toXML());
		serverNode.appendChild(JROBIN);
		for (var device in devices) {
			serverNode.appendChild(devices[device].toXML());
		}
		for (var client in clients) {
			serverNode.appendChild(clients[client].toXML());
		}		
		return serverNode;
	}	
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Server_Design");
		newNode.object = this;
		if(_global.advanced){
			newNode.appendChild(controls.toTree());
			newNode.appendChild(settings.toTree());			
		}
		newNode.appendChild(macros.toTree());
		//newNode.appendChild(scripts.toTree());
		for (var device in devices) {
			newNode.appendChild(devices[device].toTree());
		}
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Server";
	}	
	public function getName():String {
		return "Server Design";
	}
	public function getData():Object {
		return {description:description, devices:devices, dataObject:this};
	}
	public function getClients():Array{
		return clients;
	}
	public function setClients(newData:Object){
		/*Close the left node, if nodes are added while node is open graphical glitches occur*/
		_global.left_tree.setIsOpen(treeNode, false);		
		//Process client list changes....
		/*Create an array to store new clients*/
		var newClients = new Array();
		/*For each client in incoming object*/
		for (var index in newData.clients) {
			/*If a client object in incoming object does not have unique id*/
			if (newData.clients[index].id == undefined) {
				/*Assign object new unique id*/
				newData.clients[index].id = _global.formDepth++;
				/*Append new client to new client list*/
				newClients.push({description:newData.clients[index].description,id:newData.clients[index].id});
			}
		}
		/* Find all clients that have been removed */
		for (var client in clients) {
			/*Prime flag to false*/
			var found = false;
			/*For each client in incoming object*/
			for (var index in newData.clients) {
				/*If client id exists*/
				if (clients[client].id == newData.clients[index].id) {
					/*Update description*/
					clients[client].description = newData.clients[index].description;
					found = true;
				}
			}
			/*If existing client is not a member of incoming object*/
			if (found == false) {
				/*Delete client*/
				clients[client].deleteSelf();
				/*Remove reference*/
				clients.splice(parseInt(client), 1);
			}
		}
		for (var newClient in newClients) {
			/*Add new Clients*/
			/*Reference Vanilla Object*/
			var new_client = new Objects.Client.Client();		
			new_client.setXML(_global.default_client_xml.firstChild);
			new_client.description = newClients[newClient].description;
			new_client.id = newClients[newClient].id;
			//Append global tree
			_global.designTree_xml.appendChild(new_client.toTree());
			clients.push(new_client);
		}
		_global.left_tree.setIsOpen(treeNode, true);		
	}
	public function setData(newData:Object) {
		_global.left_tree.setIsOpen(treeNode, false);		
		description = newData.description;
		//Process device changes....
		var newDevices = new Array();
		for (var index in newData.devices) {
			if (newData.devices[index].id == undefined) {
				newDevices.push({description:newData.devices[index].description, device_type:newData.devices[index].device_type});
			}
		}
		for (var device in devices) {
			var found = false;
			for (var index in newData.devices) {
				if (devices[device].id == newData.devices[index].id) {
					if(devices[device].device_type == newData.devices[index].device_type){
						devices[device].description = newData.devices[index].description;
						found = true;
					} else{
						newDevices.push({description:newData.devices[index].description, device_type:newData.devices[index].device_type});
					}
				}
			}
			if (found == false) {
				devices[device].deleteSelf();
				devices.splice(parseInt(device), 1);
			}
		}
		for (var newDevice in newDevices) {
			var newNode = new XMLNode(1, "DEVICE");
			newNode.attributes["DESCRIPTION"] = newDevices[newDevice].description;
			newNode.attributes["DEVICE_TYPE"] = newDevices[newDevice].device_type;
			newNode.attributes["ACTIVE"] = "N";
			var newDevice = new XMLNode(1,newDevices[newDevice].device_type);
			newNode.appendChild(newDevice);
			switch (newNode.attributes["DEVICE_TYPE"]) {
			case "PELCO" :
				var newPelco = new Objects.Server.Pelco();
				newPelco.setXML(newNode);
				newPelco.id = _global.formDepth++;
				newPelco.active = "Y";
				treeNode.appendChild(newPelco.toTree());				
				devices.push(newPelco);
				break;
			case "OREGON" :
				var newOregon = new Objects.Server.Oregon();
				newOregon.setXML(newNode);
				newOregon.id = _global.formDepth++;
				newOregon.active = "Y";				
				treeNode.appendChild(newOregon.toTree());
				devices.push(newOregon);
				break;
			case "IR_LEARNER" :
				var newIR = new Objects.Server.IR_Learner();
				newIR.setXML(newNode);
				newIR.id = _global.formDepth++;
				newIR.active = "Y";				
				treeNode.appendChild(newIR.toTree());
				devices.push(newIR);
				break;
			case "TUTONDO" :
				var newTutondo = new Objects.Server.Tutondo();
				newTutondo.setXML(newNode);
				newTutondo.id = _global.formDepth++;
				newTutondo.active = "Y";				
				treeNode.appendChild(newTutondo.toTree());				
				devices.push(newTutondo);
				break;
			case "KRAMER" :
				var newKramer = new Objects.Server.Kramer();
				newKramer.setXML(newNode);
				newKramer.id = _global.formDepth++;
				newKramer.active = "Y";				
				treeNode.appendChild(newKramer.toTree());				
				devices.push(newKramer);
				break;
			case "HAL" :
				var newHal = new Objects.Server.Hal();
				newHal.setXML(newNode);
				newHal.id = _global.formDepth++;
				newHal.active = "Y";				
				treeNode.appendChild(newHal.toTree());				
				devices.push(newHal);
				break;
			case "CBUS" :
				var newCBus = new Objects.Server.CBus();
				newCBus.setXML(newNode);
				newCBus.id = _global.formDepth++;
				newCBus.active = "Y";				
				treeNode.appendChild(newCBus.toTree());				
				devices.push(newCBus);
				break;
			case "NUVO" :
				var newNuvo = new Objects.Server.Nuvo();
				newNuvo.setXML(newNode);
				newNuvo.id = _global.formDepth++;				
				newNuvo.active = "Y";				
				treeNode.appendChild(newNuvo.toTree());
				devices.push(newNuvo);
				break;
			case "SIGN_VIDEO" :
				var newSignVideo = new Objects.Server.SignVideo();
				newSignVideo.setXML(newNode);
				newSignVideo.id = _global.formDepth++;				
				newSignVideo.active = "Y";				
				treeNode.appendChild(newSignVideo.toTree());
				devices.push(newSignVideo);
				break;
			case "DYNALITE" :
				var newDynalite = new Objects.Server.Dynalite();
				newDynalite.setXML(newNode);
				newDynalite.id = _global.formDepth++;				
				newDynalite.active = "Y";				
				treeNode.appendChild(newDynalite.toTree());
				devices.push(newDynalite);
				break;
			case "DMX" :
				var newDMX = new Objects.Server.DMX();
				newDMX.setXML(newNode);
				newDMX.id = _global.formDepth++;				
				newDMX.active = "Y";				
				treeNode.appendChild(newDMX.toTree());
				devices.push(newDMX);
				break;
			case "GC100" :
				var newGC100 = new Objects.Server.GC100();
				newGC100.setXML(newNode);
				newGC100.id = _global.formDepth++;
				newGC100.active = "Y";				
				treeNode.appendChild(newGC100.toTree());
				devices.push(newGC100);
				break;
			case "RAW_CONNECTION" :
				var newRaw = new Objects.Server.Raw_Connection();
				newRaw.setXML(newNode);
				newRaw.id = _global.formDepth++;				
				newRaw.active = "Y";				
				treeNode.appendChild(newRaw.toTree());		
				devices.push(newRaw);
				break;
			case "M1" :
				var newM1 = new Objects.Server.M1();
				newM1.setXML(newNode);
				newM1.id = _global.formDepth++;								
				newM1.active = "Y";				
				treeNode.appendChild(newM1.toTree());
				devices.push(newM1);
				break;
			case "COMFORT" :
				var newComfort = new Objects.Server.Comfort();
				newComfort.setXML(_global.comfort_XML.firstChild);
				//newComfort.setXML(newNode);
				newComfort.id = _global.formDepth++;								
				newComfort.active = "Y";				
				treeNode.appendChild(newComfort.toTree());
				devices.push(newComfort);
				break;
			case "CUSTOM_CONNECT":
				var newCustomConnect = new Objects.Server.CustomConnect();
				newCustomConnect.setXML(newNode);
				newCustomConnect.id = _global.formDepth++;								
				newCustomConnect.active = "Y";				
				treeNode.appendChild(newCustomConnect.toTree());
				devices.push(newCustomConnect);
				break;
			case "JANDI":
				var newJandy = new Objects.Server.Jandy();
				newJandy.setXML(_global.jandy_XML.firstChild);
				//newJandy.setXML(newNode);
				newJandy.id = _global.formDepth++;								
				newJandy.active = "Y";				
				treeNode.appendChild(newJandy.toTree());
				devices.push(newJandy);
				break;
				}
			}
		_global.left_tree.setIsOpen(treeNode, true);		
	}
	public function setXML(newData:XMLNode):Void {
		controls = new Objects.Server.Controls();
		settings = new Objects.Server.Settings();
		macros = new Objects.Server.Macros();
		scripts = new Objects.Server.Scripts();
		devices = new Array();
		clients = new Array();
		description = "";
		if (newData.nodeName == "CONFIG") {
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "DEVICE" :
				if(newData.childNodes[child].attributes["NAME"] != undefined){
					var device_type = newData.childNodes[child].attributes["NAME"];										
				}
				if(newData.childNodes[child].attributes["DEVICE_TYPE"] != undefined){
					var device_type = newData.childNodes[child].attributes["DEVICE_TYPE"];					
				}				
					switch (device_type) {
					case "PELCO" :
						var newPelco = new Objects.Server.Pelco();
						newPelco.setXML(newData.childNodes[child]);
						newPelco.id = _global.formDepth++;
						newPelco.active = "Y";						
						devices.push(newPelco);
						break;
					case "OREGON_SCIENTIFIC":
						newData.childNodes[child].attributes["DEVICE_TYPE"] = "OREGON";
					case "OREGON" :
						var newOregon = new Objects.Server.Oregon();
						newOregon.setXML(newData.childNodes[child]);
						newOregon.id = _global.formDepth++;
						newOregon.active = "Y";						
						devices.push(newOregon);
						break;
					case "IR_LEARNER" :
						var newIR = new Objects.Server.IR_Learner();
						newIR.setXML(newData.childNodes[child]);
						newIR.id = _global.formDepth++;
						newIR.active = "Y";						
						devices.push(newIR);
						break;
					case "TUTONDO" :
						var newTutondo = new Objects.Server.Tutondo();
						newTutondo.setXML(newData.childNodes[child]);
						newTutondo.id = _global.formDepth++;
						newTutondo.active = "Y";						
						devices.push(newTutondo);
						break;
					case "KRAMER" :
						var newKramer = new Objects.Server.Kramer();
						newKramer.setXML(newData.childNodes[child]);
						newKramer.id = _global.formDepth++;
						newKramer.active = "Y";						
						devices.push(newKramer);
						break;
					case "HAL" :
						var newHal = new Objects.Server.Hal();
						newHal.setXML(newData.childNodes[child]);
						newHal.id = _global.formDepth++;
						newHal.active = "Y";						
						devices.push(newHal);
						break;
					case "CBUS" :
						var newCBus = new Objects.Server.CBus();
						newCBus.setXML(newData.childNodes[child]);
						newCBus.id = _global.formDepth++;
						newCBus.active = "Y";						
						devices.push(newCBus);
						break;
					case "DYNALITE" :
						var newDynalite = new Objects.Server.Dynalite();
						newDynalite.setXML(newData.childNodes[child]);
						newDynalite.id = _global.formDepth++;
						newDynalite.active = "Y";						
						devices.push(newDynalite);
						break;
					case "DMX" :
						var newDMX = new Objects.Server.DMX();
						newDMX.setXML(newData.childNodes[child]);
						newDMX.id = _global.formDepth++;
						newDMX.active = "Y";						
						devices.push(newDMX);
						break;
					case "GC100" :
						var newGC100 = new Objects.Server.GC100();
						newGC100.setXML(newData.childNodes[child]);
						newGC100.id = _global.formDepth++;
						newGC100.active = "Y";						
						devices.push(newGC100);
						break;
					case "NUVO" :
						var newNuvo = new Objects.Server.Nuvo();
						newNuvo.setXML(newData.childNodes[child]);
						newNuvo.id = _global.formDepth++;
						newNuvo.active = "Y";						
						devices.push(newNuvo);
						break;
					case "SIGN_VIDEO" :
						var newSignVideo = new Objects.Server.SignVideo();
						newSignVideo.setXML(newData.childNodes[child]);
						newSignVideo.id = _global.formDepth++;
						newSignVideo.active = "Y";						
						devices.push(newSignVideo);
						break;
					case "M1":
						var newM1 = new Objects.Server.M1();
						newM1.setXML(newData.childNodes[child]);
						newM1.id = _global.formDepth++;						
						newM1.active = "Y";						
						devices.push(newM1);
						break;					
					case "RAW_CONNECTION" :
						var newRaw = new Objects.Server.Raw_Connection();
						newRaw.setXML(newData.childNodes[child]);
						newRaw.id = _global.formDepth++;						
						newRaw.active = "Y";						
						devices.push(newRaw);
						break;
					case "COMFORT" :
						var newComfort = new Objects.Server.Comfort();
						newComfort.setXML(newData.childNodes[child]);
						newComfort.id = _global.formDepth++;
						newComfort.active = "Y";						
						devices.push(newComfort);
						break;
					case "CUSTOM_CONNECT":
						var newCustomConnect = new Objects.Server.CustomConnect();
						newCustomConnect.setXML(newData.childNodes[child]);
						newCustomConnect.id = _global.formDepth++;
						newCustomConnect.active = "Y";		
						devices.push(newCustomConnect);
						break;
					case "JANDI":
						var newJandy = new Objects.Server.Jandy();
						newJandy.setXML(newData.childNodes[child]);
						newJandy.id = _global.formDepth++;
						newJandy.active = "Y";		
						devices.push(newJandy);
						break;
					}
					break;
				case "CONTROLS" :
					for(var index in newData.childNodes[child].childNodes){
						switch(newData.childNodes[child].childNodes[index].nodeName){
							case "VARIABLES":
								controls.setXML(newData.childNodes[child].childNodes[index]);
							break;
							case "CALENDAR_MESSAGES":						
								settings.setXML(newData.childNodes[child].childNodes[index]);
							break;						
						}
					}
					break;
				case "DESC" :
					description = newData.childNodes[child].firstChild;
					break;
				case "JROBIN" :
					JROBIN = newData.childNodes[child];
					break;
				case "application":
					var newClient = new Objects.Client.Client();
					newClient.setXML(newData.childNodes[child]);
					newClient.id = _global.formDepth++;
					clients.push(newClient);
					break;
				case "MACROS":
					macros.setXML(newData.childNodes[child]);
					break;
				case "SCRIPT_STATUS":
					scripts.setXML(newData.childNodes[child]);
					break;
				}
			}
		} else {
			mdm.Dialogs.prompt("ERROR, found node "+newData.nodeName+", expecting CONFIG");
			mdm.Dialogs.prompt(newData.toString());
		}
	}
}
