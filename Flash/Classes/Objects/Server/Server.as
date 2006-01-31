class Objects.Server.Server extends Objects.BaseElement {
	private var description:String;
	private var controls:Objects.Server.Controls;
	private var devices:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var device in devices){
			tempKeys = tempKeys.concat(devices[device].getKeys());
		}
		tempKeys = tempKeys.concat(controls.getKeys());
		return tempKeys;
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
		serverNode.appendChild(controls.toXML());
		for (var device in devices) {
			serverNode.appendChild(devices[device].toXML());
		}
		return serverNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Server");
		newNode.object = this;
		newNode.appendChild(controls.toTree());
		for (var device in devices) {
			newNode.appendChild(devices[device].toTree());
		}
		return newNode;
	}
	public function getName():String {
		return "Server";
	}
	public function getData():Object {
		return new Object({description:description, devices:devices});
	}
	public function setData(newData:Object) {
		description = newData.description;
		//Process device changes....
		var newDevices = new Array();
		for (var index in newData.devices) {
			var found = false;
			for (var device in devices) {
				if ((devices[device].description == newData.devices[index].description) && (devices[device].device_type == newData.devices[index].device_type)) {
					found = true;
				}
			}
			if (found == false) {
				newDevices.push({description:newData.devices[index].description, device_type:newData.devices[index].device_type});
			}
		}
		var deletedDevices = new Array();
		for (var device in devices) {
			var found = false;
			for (var index in newData.devices) {
				if ((devices[device].description == newData.devices[index].description) && (devices[device].device_type == newData.devices[index].device_type)) {
					found = true;
				}
			}
			if (found == false) {
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
				devices.push(newPelco);
				break;
			case "OREGON" :
				var newOregon = new Objects.Server.Oregon();
				newOregon.setXML(newNode);
				devices.push(newOregon);
				break;
			case "IR_LEARNER" :
				var newIR = new Objects.Server.IR_Learner();
				newIR.setXML(newNode);
				devices.push(newIR);
				break;
			case "TUTONDO" :
				var newTutondo = new Objects.Server.Tutondo();
				newTutondo.setXML(newNode);
				devices.push(newTutondo);
				break;
			case "KRAMER" :
				var newKramer = new Objects.Server.Kramer();
				newKramer.setXML(newNode);
				devices.push(newKramer);
				break;
			case "HAL" :
				var newHal = new Objects.Server.Hal();
				newHal.setXML(newNode);
				devices.push(newHal);
				break;
			case "CBUS" :
				var newCBus = new Objects.Server.CBus();
				newCBus.setXML(newNode);
				devices.push(newCBus);
				break;
			case "DYNALITE" :
				var newDynalite = new Objects.Server.Dynalite();
				newDynalite.setXML(newNode);
				devices.push(newDynalite);
				break;
			case "GC100" :
				var newGC100 = new Objects.Server.GC100();
				newGC100.setXML(newNode);
				devices.push(newGC100);
				break;
			case "RAW_CONNECTION" :
				var newRaw = new Objects.Server.Raw_Connection();
				newRaw.setXML(newNode);
				devices.push(newRaw);
				break;
			case "COMFORT" :
				var newComfort = new Objects.Server.Comfort();
				newComfort.setXML(newNode);
				devices.push(newComfort);
				break;
			}
		}
	}
	public function setXML(newData:XMLNode):Void {
		controls = new Objects.Server.Controls();
		devices = new Array();
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
						devices.push(newPelco);
						break;
					case "OREGON" :
						var newOregon = new Objects.Server.Oregon();
						newOregon.setXML(newData.childNodes[child]);
						devices.push(newOregon);
						break;
					case "IR_LEARNER" :
						var newIR = new Objects.Server.IR_Learner();
						newIR.setXML(newData.childNodes[child]);
						devices.push(newIR);
						break;
					case "TUTONDO" :
						var newTutondo = new Objects.Server.Tutondo();
						newTutondo.setXML(newData.childNodes[child]);
						devices.push(newTutondo);
						break;
					case "KRAMER" :
						var newKramer = new Objects.Server.Kramer();
						newKramer.setXML(newData.childNodes[child]);
						devices.push(newKramer);
						break;
					case "HAL" :
						var newHal = new Objects.Server.Hal();
						newHal.setXML(newData.childNodes[child]);
						devices.push(newHal);
						break;
					case "CBUS" :
						var newCBus = new Objects.Server.CBus();
						newCBus.setXML(newData.childNodes[child]);
						devices.push(newCBus);
						break;
					case "DYNALITE" :
						var newDynalite = new Objects.Server.Dynalite();
						newDynalite.setXML(newData.childNodes[child]);
						devices.push(newDynalite);
						break;
					case "GC100" :
						var newGC100 = new Objects.Server.GC100();
						newGC100.setXML(newData.childNodes[child]);
						devices.push(newGC100);
						break;
					case "RAW_CONNECTION" :
						var newRaw = new Objects.Server.Raw_Connection();
						newRaw.setXML(newData.childNodes[child]);
						devices.push(newRaw);
						break;
					case "COMFORT" :
						var newComfort = new Objects.Server.Comfort();
						newComfort.setXML(newData.childNodes[child]);
						devices.push(newComfort);
						break;
					}
					break;
				case "CONTROLS" :
					controls.setXML(newData.childNodes[child]);
					break;
				case "DESC" :
					description = newData.childNodes[child].firstChild;
					break;
				case "JROBIN" :
					break;
				}
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting CONFIG");
		}
	}
}
