class Objects.Server.Comfort extends Objects.Server.Device {
	private var counters:Objects.Server.Counters;
	private var customs:Objects.Server.Customs;
	private var raw_interfaces:Objects.Server.Raw_Interfaces;
	private var toggle_monitors:Objects.Server.Monitors;
	private var cbus_lights:Objects.Server.CBusLights;
	private var cbus_relays:Objects.Server.CBusRelays;			
	private var x10_lights:Objects.Server.X10Lights;
	private var pulse_outputs:Objects.Server.Toggles;
	private var toggle_inputs:Objects.Server.Toggles;
	private var toggle_outputs:Objects.Server.Toggles;
	private var alarms:Objects.Server.Alarms;
	private var alerts:Objects.Server.Alerts;
	private var analogues:Objects.Server.Analogues;
	private var door_ids:Objects.Server.Catalogue;
	private var comfort_users:Objects.Server.Catalogue;
	var treeNode:XMLNode;			
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(counters.getKeys());
		tempKeys = tempKeys.concat(customs.getKeys());
		tempKeys = tempKeys.concat(raw_interfaces.getKeys());
		tempKeys = tempKeys.concat(toggle_monitors.getKeys());
		tempKeys = tempKeys.concat(cbus_lights.getKeys());
		tempKeys = tempKeys.concat(cbus_relays.getKeys());
		tempKeys = tempKeys.concat(x10_lights.getKeys());
		tempKeys = tempKeys.concat(pulse_outputs.getKeys());
		tempKeys = tempKeys.concat(toggle_inputs.getKeys());
		tempKeys = tempKeys.concat(toggle_outputs.getKeys());
		tempKeys = tempKeys.concat(alarms.getKeys());
		tempKeys = tempKeys.concat(alerts.getKeys());
		tempKeys = tempKeys.concat(analogues.getKeys());
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
		if (!customs.isValid()) {
			flag = false;
		}
		if(!customs.isValid()){
			flag = false;
		}
		if(!raw_interfaces.isValid()){
			flag = false;
		}
		if(!counters.isValid()){
			flag = false;
		}
		if(!toggle_monitors.isValid()){
			flag = false;
		}
		if(!cbus_lights.isValid()){
			flag = false;
		}
		if(!cbus_relays.isValid()){
			flag = false;
		}		
		if(!x10_lights.isValid()){
			flag = false;
		}
		if(!pulse_outputs.isValid()){
			flag = false;
		}
		if(!toggle_outputs.isValid()){
			flag = false;
		}
		if(!toggle_inputs.isValid()){
			flag = false;
		}
		if(!alarms.isValid()){
			flag = false;
		}
		if(!alerts.isValid()){
			flag = false;
		}
		if(!analogues.isValid()){
			flag = false;
		}
		if (!catalogues.isValid()) {
			flag = false;
		}
		if (!door_ids.isValid()) {
			flag = false;
		}
		if (!comfort_users.isValid()) {
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
		var newParameter = new XMLNode(1,"ITEM");
		newParameter.attributes["NAME"] = "DOOR_IDS";
		newParameter.attributes["VALUE"] = "Door IDs";
		newParameters.appendChild(newParameter);
		newParameter = new XMLNode(1,"ITEM");
		newParameter.attributes["NAME"] = "COMFORT_USERS";
		newParameter.attributes["VALUE"] = "Comfort Users";		
		newParameters.appendChild(newParameter);		
		newDevice.appendChild(newParameters);
		newDevice.appendChild(door_ids.toXML());
		newDevice.appendChild(comfort_users.toXML());
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newComfort = new XMLNode(1, device_type);
		var tempCustoms = customs.toXML();
		for(var child in tempCustoms.childNodes){
			newComfort.appendChild(tempCustoms.childNodes[child]);
		}
		var tempRaw_Interfaces = raw_interfaces.toXML();
		for(var child in tempRaw_Interfaces.childNodes){
			newComfort.appendChild(tempRaw_Interfaces.childNodes[child]);
		}
		var tempCounters = counters.toXML();
		for(var child in tempCounters.childNodes){
			newComfort.appendChild(tempCounters.childNodes[child]);
		}
		var tempMonitors = toggle_monitors.toXML();
		for(var child in tempMonitors.childNodes){
			newComfort.appendChild(tempMonitors.childNodes[child]);
		}
		var tempCbusLights = cbus_lights.toXML();
		for(var child in tempCbusLights.childNodes){
			newComfort.appendChild(tempCbusLights.childNodes[child]);
		}
		var tempCbusRelays = cbus_relays.toXML();
		for(var child in tempCbusRelays.childNodes){
			newComfort.appendChild(tempCbusRelays.childNodes[child]);
		}		
		var tempX10Lights = x10_lights.toXML();
		for(var child in tempX10Lights.childNodes){
			newComfort.appendChild(tempX10Lights.childNodes[child]);
		}
		var tempPulseOutputs = pulse_outputs.toXML();
		for(var child in tempPulseOutputs.childNodes){
			newComfort.appendChild(tempPulseOutputs.childNodes[child]);
		}
		var tempToggleOutputs = toggle_outputs.toXML();
		for(var child in tempToggleOutputs.childNodes){
			newComfort.appendChild(tempToggleOutputs.childNodes[child]);
		}
		var tempToggleInputs = toggle_inputs.toXML();
		for(var child in tempToggleInputs.childNodes){
			newComfort.appendChild(tempToggleInputs.childNodes[child]);
		}
		var tempAlerts = alerts.toXML();
		for (var child in tempAlerts.childNodes){
			newComfort.appendChild(tempAlerts.childNodes[child]);
		}
		var tempAlarms = alarms.toXML();
		for (var child in tempAlarms.childNodes){
			newComfort.appendChild(tempAlarms.childNodes[child]);
		}
		var tempAnalogues = analogues.toXML();
		for (var child in tempAnalogues.childNodes){
			newComfort.appendChild(tempAnalogues.childNodes[child]);
		}
		newDevice.appendChild(newComfort);	
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Customs");
		if(_global.advanced){
			newNode.appendChild(catalogues.toTree());		
			newNode.appendChild(customs.toTree());
			newNode.appendChild(raw_interfaces.toTree());
			newNode.appendChild(alarms.toTree());
			newNode.appendChild(alerts.toTree());			
		}		
		newNode.appendChild(door_ids.toTree());
		newNode.appendChild(comfort_users.toTree());
		newNode.appendChild(counters.toTree());
		newNode.appendChild(toggle_monitors.toTree());
		newNode.appendChild(cbus_lights.toTree());
		newNode.appendChild(cbus_relays.toTree());
		newNode.appendChild(x10_lights.toTree());
		newNode.appendChild(pulse_outputs.toTree());
		newNode.appendChild(toggle_inputs.toTree());
		newNode.appendChild(toggle_outputs.toTree());
		newNode.appendChild(analogues.toTree());
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "Comfort";
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		parameters = new Array();		
		raw_interfaces = new Objects.Server.Raw_Interfaces();
		customs = new Objects.Server.Customs();
		counters = new Objects.Server.Counters();
		toggle_monitors = new Objects.Server.Monitors();
		pulse_outputs = new Objects.Server.Toggles("PULSE_OUTPUT");
		toggle_outputs = new Objects.Server.Toggles("TOGGLE_OUTPUT");
		toggle_inputs = new Objects.Server.Toggles("TOGGLE_INPUT");
		cbus_lights = new Objects.Server.CBusLights();
		cbus_relays = new Objects.Server.CBusRelays();		
		x10_lights = new Objects.Server.X10Lights();
		alarms = new Objects.Server.Alarms();
		alerts = new Objects.Server.Alerts();
		analogues = new Objects.Server.Analogues();
		catalogues = new Objects.Server.Catalogues();
		door_ids = new Objects.Server.Catalogue();
		comfort_users = new Objects.Server.Catalogue();
		var newDoors = new XMLNode(1,"CATALOGUE");
		newDoors.attributes["NAME"] = "Door IDs";
		door_ids.setXML(newDoors);
		var newUsers = new XMLNode(1, "CATALOGUE");
		newUsers.attributes["NAME"] = "Comfort Users";
		comfort_users.setXML(newUsers);			
		var tempCatalogues = new XMLNode(1, device_type);
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
						if((newData.childNodes[child].childNodes[parameter].attributes["NAME"] != "DOOR_IDS")&&(newData.childNodes[child].childNodes[parameter].attributes["NAME"] != "COMFORT_USERS")){
							parameters.push(newData.childNodes[child].childNodes[parameter]);
					  	}
					}
					break;
				case "CATALOGUE" :
					if(newData.childNodes[child].attributes["NAME"] == "Door IDs"){
						door_ids.setXML(newData.childNodes[child]);
					} else if(newData.childNodes[child].attributes["NAME"] == "Comfort Users"){
						comfort_users.setXML(newData.childNodes[child]);						
					} else {
						tempCatalogues.appendChild(newData.childNodes[child]);
					}
					break;
				case "COMFORT" :
					var tempNode = newData.childNodes[child];
					var tempCustomInputs = new XMLNode(1, device_type);
					var tempRawInterfaces = new XMLNode(1,device_type);
					var tempCounters = new XMLNode(1,device_type);
					var tempMonitors = new XMLNode(1,device_type);
					var tempCbusLights = new XMLNode(1,device_type);
					var tempCbusRelays = new XMLNode(1,device_type);					
					var tempX10Lights = new XMLNode(1,device_type);
					var tempPulseOutputs = new XMLNode(1,device_type);
					var tempToggleOutputs = new XMLNode(1,device_type);
					var tempToggleInputs = new XMLNode(1,device_type);
					var tempAlerts = new XMLNode(1,device_type);
					var tempAlarms = new XMLNode(1,device_type);
					var tempAnalogues = new XMLNode(1,device_type);
					for (var rawDevice in tempNode.childNodes) {
						switch (tempNode.childNodes[rawDevice].nodeName) {
						case "CUSTOM_INPUT" :
							tempCustomInputs.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "RAW_INTERFACE" :
							tempRawInterfaces.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "COUNTER":
							tempCounters.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "TOGGLE_OUTPUT_MONITOR":
							tempMonitors.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "LIGHT_CBUS":
							if(tempNode.childNodes[rawDevice].attributes["RELAY"] == "Y"){
								tempCbusRelays.appendChild(tempNode.childNodes[rawDevice]);							
							} else {
								tempCbusLights.appendChild(tempNode.childNodes[rawDevice]);
							}
							break;
						case "LIGHT_X10":
							tempX10Lights.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "PULSE_OUTPUT":
							tempPulseOutputs.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "TOGGLE_OUTPUT":
							tempToggleOutputs.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "TOGGLE_INPUT":
							tempToggleInputs.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "ALARM":
							tempAlarms.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "ALERT":
							tempAlerts.appendChild(tempNode.childNodes[rawDevice]);
							break;
						case "ANALOG":
						case "ANALOGUE":
							tempAnalogues.appendChild(tempNode.childNodes[rawDevice]);
							break;
						}
					}
					customs.setXML(tempCustomInputs);
					cbus_lights.setXML(tempCbusLights);
					cbus_relays.setXML(tempCbusRelays);					
					x10_lights.setXML(tempX10Lights);
					raw_interfaces.setXML(tempRawInterfaces);
					counters.setXML(tempCounters);
					toggle_monitors.setXML(tempMonitors);
					pulse_outputs.setXML(tempPulseOutputs);
					toggle_outputs.setXML(tempToggleOutputs);
					toggle_inputs.setXML(tempToggleInputs);
					alarms.setXML(tempAlarms);
					alerts.setXML(tempAlerts);
					analogues.setXML(tempAnalogues);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
			raw_interfaces.catalogues = catalogues;
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
