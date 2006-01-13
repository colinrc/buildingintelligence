class Objects.Server.Raw_Connection extends Objects.BaseElement {
	private var type:String = "RAW_CONNECTION";
	private var name:String;
	private var display_name:String;
	private var active:String;
	private var catalogues:Objects.Server.Catalogues;
	private var customs:Objects.Server.Customs;
	private var raw_items:Objects.Server.Raw_Items;
	private var raw_interfaces:Objects.Server.Raw_Interfaces;
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
		if (!customs.isValid()) {
			flag = false;
		}
		if(!raw_items.isValid()){
			flag = false;
		}
		if(!customs.isValid()){
			flag = false;
		}
		if(!raw_interfaces.isValid()){
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
		var newRawConnection = new XMLNode(1, type);
		var tempCustoms = customs.toXML();
		for(var child in tempCustoms.childNodes){
			newRawConnection.appendChild(tempCustoms.childNodes[child]);
		}
		var tempRaw_Items = raw_items.toXML();
		for(var child in tempRaw_Items.childNodes){
			newRawConnection.appendChild(tempRaw_Items.childNodes[child]);
		}
		var tempRaw_Interfaces = raw_interfaces.toXML();
		for(var child in tempRaw_Interfaces.childNodes){
			newRawConnection.appendChild(tempRaw_Interfaces.childNodes[child]);
		}
		newDevice.appendChild(newRawConnection);
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Raw Connection");
		newNode.appendChild(customs.toTree());
		newNode.appendChild(raw_items.toTree());
		newNode.appendChild(raw_interfaces.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return type+": "+display_name;
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
		raw_items = new Objects.Server.Raw_Items();
		raw_interfaces = new Objects.Server.Raw_Interfaces();
		customs = new Objects.Server.Customs();
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1, "Catalogues");
		if (newData.nodeName == "DEVICE") {
			name = newData.attributes["NAME"];
			display_name = newData.attributes["DISPLAY_NAME"];
			active = newData.attributes["ACTIVE"];
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "CONNECTION" :
					connection = newData.childNodes[child];
					break;
				case "PARAMETERS" :
					parameters = newData.childNodes[child];
					break;
				case "CATALOGUE" :
					tempCatalogues.appendChild(newData.childNodes[child]);
					break;
				case "RAW_CONNECTION" :
					var tempNode = newData.childNodes[child];
					var tempCustomInputs = new XMLNode(1, type);
					var tempRawItems = new XMLNode(1, type);
					var tempRawInterfaces = new XMLNode(1,type);
					for (var rawDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[rawDevice].nodeName) {
						case "CUSTOM_INPUT" :
							tempCustomInputs.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "RAW_ITEMS" :
							tempRawItems.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "RAW_INTERFACE" :
							tempRawInterfaces.appendChild(tempNode.childNodes[rawDevice]);
							break;
						}
					}
					customs.setXML(tempCustomInputs);
					raw_items.setXML(tempRawItems);
					raw_interfaces.setXML(tempRawInterfaces);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
