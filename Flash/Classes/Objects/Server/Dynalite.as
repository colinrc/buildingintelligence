class Objects.Server.Dynalite extends Objects.Server.Device {
	private var device_type:String;
	private var description:String;
	private var active:String;
	private var irs:Objects.Server.IRs;
	private var lights:Objects.Server.DynaliteLights;
	private var contacts:Objects.Server.ContactClosures;
	private var catalogues:Objects.Server.Catalogues;
	private var connection:XMLNode;
	private var parameters:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(lights.getKeys());
		tempKeys = tempKeys.concat(contacts.getKeys());
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if ((device_type == undefined) || (device_type == "")) {
			flag = false;
		}
		if ((description == undefined) || (description == "")) {
			flag = false;
		}		
		if ((active != "Y") && (active != "N")) {
			flag = false;
		}
		if (!irs.isValid()) {
			flag = false;
		}
		if (!lights.isValid()) {
			flag = false;
		}
		if (!contacts.isValid()) {
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
		var newDynalite = new XMLNode(1, device_type);
		var tempIRs = irs.toXML();
		for (var child in tempIRs.childNodes) {
			newDynalite.appendChild(tempIRs.childNodes[child]);
		}
		var tempLights = lights.toXML();
		for (var child in tempLights.childNodes) {
			newDynalite.appendChild(tempLights.childNodes[child]);
		}
		var tempContacts = contacts.toXML();
		for (var child in tempContacts.childNodes) {
			newDynalite.appendChild(tempContacts.childNodes[child]);
		}
		newDevice.appendChild(newDynalite);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(catalogues.toTree());
		newNode.appendChild(lights.toTree());
		newNode.appendChild(contacts.toTree());
		newNode.appendChild(irs.toTree());
		newNode.object = this;
		_global.workflow.addNode("Dynalite",newNode);
		return newNode;
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1, "Catalogues");
		irs = new Objects.Server.IRs();
		lights = new Objects.Server.DynaliteLights();
		contacts = new Objects.Server.ContactClosures();
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
				case "DYNALITE" :
					var tempIRs = new XMLNode(1, "irs");
					var tempLights = new XMLNode(1, "lights");
					var tempContacts = new XMLNode(1, "contact closures");
					var tempNode = newData.childNodes[child];
					for (var dynaliteDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[dynaliteDevice].nodeName) {
						case "LIGHT_DYNALITE" :
							tempLights.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						case "IR" :
							tempIRs.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						case "CONTACT_CLOSURE" :
							tempContacts.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						}
					}
					irs.setXML(tempIRs);
					lights.setXML(tempLights);
					contacts.setXML(tempContacts);
					break;
				case "CONNECTION" :
					connection = newData.childNodes[child];
					break;
				case "PARAMETERS" :
					parameters = newData.childNodes[child];
					break;
				case "CATALOGUE" :
					tempCatalogues.appendChild(newData.childNodes[child]);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
