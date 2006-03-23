class Objects.Server.Server extends Objects.BaseElement {
	private var description:String;
	private var controls:Objects.Server.Controls;
	private var settings:Objects.Server.Settings;
	private var devices:Array;
	private var treeNode:XMLNode;
	private var clientDesigns:Objects.ClientDesigns;
	public function Server(){
		description = "";
		devices = new Array();
		controls = new Objects.Server.Controls();
		settings = new Objects.Server.Settings();
		clientDesigns = new Objects.ClientDesigns();
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
		tempKeys = tempKeys.sort();
		var keys = new Array();
		var lastKey:String;
		for(var tempKey in tempKeys){
			if(tempKeys[tempKey] != lastKey){
				keys.push(tempKeys[tempKey]);
				lastKey = tempKeys[tempKey];
			}
		}
		return keys;
	}
	public function isValid():Boolean {
		var flag = true;
		if (!controls.isValid()) {
			flag = false;
		}
		for (var device in devices) {
			if (!devices[device].isValid()) {
				flag = false;
			}
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
		for (var device in devices) {
			serverNode.appendChild(devices[device].toXML());
		}
		return serverNode;
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
		for (var device in devices) {
			serverNode.appendChild(devices[device].toXML());
		}
		serverNode.appendChild(clientDesigns.toXML());
		return serverNode;
	}	
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Server");
		newNode.object = this;
		if(_global.advanced){
			newNode.appendChild(controls.toTree());
			newNode.appendChild(settings.toTree());			
		}					
		for (var device in devices) {
			newNode.appendChild(devices[device].toTree());
		}
		newNode.appendChild(clientDesigns.toTree());
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Server";
	}	
	public function getName():String {
		return description;
	}
	public function getData():Object {
		return {description:description, devices:devices, dataObject:this};
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
				treeNode.appendChild(newPelco.toTree());				
				devices.push(newPelco);
				break;
			case "OREGON" :
				var newOregon = new Objects.Server.Oregon();
				newOregon.setXML(newNode);
				newOregon.id = _global.formDepth++;
				treeNode.appendChild(newOregon.toTree());
				devices.push(newOregon);
				break;
			case "IR_LEARNER" :
				var newIR = new Objects.Server.IR_Learner();
				newIR.setXML(newNode);
				newIR.id = _global.formDepth++;
				treeNode.appendChild(newIR.toTree());
				devices.push(newIR);
				break;
			case "TUTONDO" :
				var newTutondo = new Objects.Server.Tutondo();
				newTutondo.setXML(newNode);
				newTutondo.id = _global.formDepth++;
				treeNode.appendChild(newTutondo.toTree());				
				devices.push(newTutondo);
				break;
			case "KRAMER" :
				var newKramer = new Objects.Server.Kramer();
				newKramer.setXML(newNode);
				newKramer.id = _global.formDepth++;
				treeNode.appendChild(newKramer.toTree());				
				devices.push(newKramer);
				break;
			case "HAL" :
				var newHal = new Objects.Server.Hal();
				newHal.setXML(newNode);
				newHal.id = _global.formDepth++;
				treeNode.appendChild(newHal.toTree());				
				devices.push(newHal);
				break;
			case "CBUS" :
				var newCBus = new Objects.Server.CBus();
				newCBus.setXML(newNode);
				newCBus.id = _global.formDepth++;
				treeNode.appendChild(newCBus.toTree());				
				devices.push(newCBus);
				break;
			case "DYNALITE" :
				var newDynalite = new Objects.Server.Dynalite();
				newDynalite.setXML(newNode);
				newDynalite.id = _global.formDepth++;				
				treeNode.appendChild(newDynalite.toTree());
				devices.push(newDynalite);
				break;
			case "GC100" :
				var newGC100 = new Objects.Server.GC100();
				newGC100.setXML(newNode);
				newGC100.id = _global.formDepth++;
				treeNode.appendChild(newGC100.toTree());
				devices.push(newGC100);
				break;
			case "RAW_CONNECTION" :
				var newRaw = new Objects.Server.Raw_Connection();
				newRaw.setXML(newNode);
				newRaw.id = _global.formDepth++;				
				treeNode.appendChild(newRaw.toTree());		
				devices.push(newRaw);
				break;
			case "COMFORT" :
				var newComfort = new Objects.Server.Comfort();
				newComfort.setXML(newNode);
				newComfort.id = _global.formDepth++;								
				treeNode.appendChild(newComfort.toTree());
				devices.push(newComfort);
				break;
			}
		}
		_global.left_tree.setIsOpen(treeNode, true);		
	}
	public function setXML(newData:XMLNode):Void {
		controls = new Objects.Server.Controls();
		settings = new Objects.Server.Settings();
		devices = new Array();
		clientDesigns = new Objects.ClientDesigns();
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
						devices.push(newPelco);
						break;
					case "OREGON" :
						var newOregon = new Objects.Server.Oregon();
						newOregon.setXML(newData.childNodes[child]);
						newOregon.id = _global.formDepth++;
						devices.push(newOregon);
						break;
					case "IR_LEARNER" :
						var newIR = new Objects.Server.IR_Learner();
						newIR.setXML(newData.childNodes[child]);
						newIR.id = _global.formDepth++;
						devices.push(newIR);
						break;
					case "TUTONDO" :
						var newTutondo = new Objects.Server.Tutondo();
						newTutondo.setXML(newData.childNodes[child]);
						newTutondo.id = _global.formDepth++;
						devices.push(newTutondo);
						break;
					case "KRAMER" :
						var newKramer = new Objects.Server.Kramer();
						newKramer.setXML(newData.childNodes[child]);
						newKramer.id = _global.formDepth++;
						devices.push(newKramer);
						break;
					case "HAL" :
						var newHal = new Objects.Server.Hal();
						newHal.setXML(newData.childNodes[child]);
						newHal.id = _global.formDepth++;
						devices.push(newHal);
						break;
					case "CBUS" :
						var newCBus = new Objects.Server.CBus();
						newCBus.setXML(newData.childNodes[child]);
						newCBus.id = _global.formDepth++;
						devices.push(newCBus);
						break;
					case "DYNALITE" :
						var newDynalite = new Objects.Server.Dynalite();
						newDynalite.setXML(newData.childNodes[child]);
						newDynalite.id = _global.formDepth++;
						devices.push(newDynalite);
						break;
					case "GC100" :
						var newGC100 = new Objects.Server.GC100();
						newGC100.setXML(newData.childNodes[child]);
						newGC100.id = _global.formDepth++;
						devices.push(newGC100);
						break;
					case "RAW_CONNECTION" :
						var newRaw = new Objects.Server.Raw_Connection();
						newRaw.setXML(newData.childNodes[child]);
						newRaw.id = _global.formDepth++;						
						devices.push(newRaw);
						break;
					case "COMFORT" :
						var newComfort = new Objects.Server.Comfort();
						newComfort.setXML(newData.childNodes[child]);
						newComfort.id = _global.formDepth++;
						devices.push(newComfort);
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
					break;
				case "clientDesigns":
					clientDesigns.setXML(newData.childNodes[child]);
					break;
				}
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting CONFIG");
		}
	}
}
