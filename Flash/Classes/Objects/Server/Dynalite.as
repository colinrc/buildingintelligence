class Objects.Server.Dynalite extends Objects.Server.Device {
	private var device_type:String;
	private var description:String;
	private var active:String;
	private var irs:Objects.Server.DynaliteIRs;
	private var lights:Objects.Server.DynaliteLights;
	private var relays:Objects.Server.DynaliteRelays;
	private var lightAreas:Objects.Server.DynaliteLightAreas;	
	private var contacts:Objects.Server.ContactClosures;
	private var alarms:Objects.Server.Alarms
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(lights.getKeys());
		tempKeys = tempKeys.concat(relays.getKeys());
		tempKeys = tempKeys.concat(contacts.getKeys());
		tempKeys = tempKeys.concat(irs.getKeys());
		tempKeys = tempKeys.concat(lightAreas.getKeys());
		tempKeys = tempKeys.concat(alarms.getKeys());
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
		if (!alarms.isValid()) {
			flag = false;
		}
		if (!lightAreas.isValid()) {
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
		var newDynalite = new XMLNode(1, device_type);
		var tempIRs = irs.toXML();
		for (var child in tempIRs.childNodes) {
			newDynalite.appendChild(tempIRs.childNodes[child]);
		}
		var tempLights = lights.toXML();
		for (var child in tempLights.childNodes) {
			newDynalite.appendChild(tempLights.childNodes[child]);
		}
		var tempRelays = relays.toXML();
		for (var child in tempRelays.childNodes) {
			newDynalite.appendChild(tempRelays.childNodes[child]);
		}		
		var tempContacts = contacts.toXML();
		for (var child in tempContacts.childNodes) {
			newDynalite.appendChild(tempContacts.childNodes[child]);
		}
		var tempLightAreas = lightAreas.toXML();
		for (var child in tempLightAreas.childNodes) {
			newDynalite.appendChild(tempLightAreas.childNodes[child]);
		}		
		var tempAlarms = alarms.toXML();
		for (var child in tempAlarms.childNodes) {
			newDynalite.appendChild(tempAlarms.childNodes[child]);
		}
		newDevice.appendChild(newDynalite);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(lights.toTree());
		newNode.appendChild(relays.toTree());
		newNode.appendChild(contacts.toTree());
		newNode.appendChild(lightAreas.toTree());
		if(_global.advanced){		
			newNode.appendChild(irs.toTree());		
			newNode.appendChild(alarms.toTree());
		}
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "Dynalite";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
		irs = new Objects.Server.DynaliteIRs();
		lights = new Objects.Server.DynaliteLights();
		relays = new Objects.Server.DynaliteRelays();
		lightAreas = new Objects.Server.DynaliteLightAreas();
		contacts = new Objects.Server.ContactClosures();
		alarms = new Objects.Server.Alarms();
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
					var tempLightAreas = new XMLNode(1,"light areas");
					var tempRelays = new XMLNode(1,"relays");
					var tempAlarms = new XMLNode(1,"alarms");
					var tempNode = newData.childNodes[child];
					for (var dynaliteDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[dynaliteDevice].nodeName) {
						case "LIGHT_DYNALITE" :
							if(tempNode.childNodes[dynaliteDevice].attributes["RELAY"] == "Y"){
								tempRelays.appendChild(tempNode.childNodes[dynaliteDevice]);								
							} else {
								tempLights.appendChild(tempNode.childNodes[dynaliteDevice]);
							}
							break;
						case "IR" :
							tempIRs.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						case "CONTACT_CLOSURE" :
							tempContacts.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						case "LIGHT_DYNALITE_AREA" :
							tempLightAreas.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						case "ALARM":
							tempAlarms.appendChild(tempNode.childNodes[dynaliteDevice]);
							break;
						}
					}
					relays.setXML(tempRelays);
					irs.setXML(tempIRs);
					lights.setXML(tempLights);
					contacts.setXML(tempContacts);
					lightAreas.setXML(tempLightAreas);
					alarms.setXML(tempAlarms);
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
