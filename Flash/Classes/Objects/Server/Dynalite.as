class Objects.Server.Dynalite extends Objects.BaseElement {
	private var type:String = "DYNALITE";
	private var name:String;
	private var display_name:String;
	private var active:String;
	private var irs:Objects.Server.IRs;
	private var lights:Objects.Server.DynaliteLights;
	private var contacts:Objects.Server.ContactClosures;
	private var catalogues:Objects.Server.Catalogues;
	private var connection:XMLNode;
	private var parameters:XMLNode;
	public function isValid():Boolean {
		var flag = true;
		if ((name == undefined) || (name == "")) {
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
	public function getForm():String {
		return "forms.project.device.head";
	}
	public function toXML():XMLNode {
		var newDevice = new XMLNode(1, "DEVICE");
		newDevice.attributes["NAME"] = name;
		newDevice.attributes["DISPLAY_NAME"] = display_name;
		newDevice.attributes["ACTIVE"] = active;
		newDevice.appendChild(connection);
		newDevice.appendChild(parameters);
		var newDynalite = new XMLNode(1, type);
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
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		return newDevice;
	}
	public function getName():String {
		return type+" : "+display_name;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(lights.toTree());
		newNode.appendChild(contacts.toTree());
		newNode.appendChild(irs.toTree());
		newNode.appendChild(catalogues.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({name:name, display_name:display_name, active:active, connection:connection, parameters:parameters});
	}
	public function setData(newData:Object) {
		name = newData.name;
		display_name = newData.display_name;
		active = newData.active;
		connection = newData.connection;
		parameters = newData.parameters;
	}
	public function setXML(newData:XMLNode):Void {
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1, "Catalogues");
		irs = new Objects.Server.IRs();
		lights = new Objects.Server.DynaliteLights();
		contacts = new Objects.Server.ContactClosures();
		if (newData.nodeName == "DEVICE") {
			name = newData.attributes["NAME"];
			display_name = newData.attributes["DISPLAY_NAME"];
			active = newData.attributes["ACTIVE"];
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
