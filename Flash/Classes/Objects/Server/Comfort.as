﻿class Objects.Server.Comfort extends Objects.BaseElement {
	private var type:String = "COMFORT";
	private var display_name:String;
	private var name:String;
	private var active:String;
	private var catalogues:Objects.Server.Catalogues;
	private var counters:Objects.Server.Counters;
	private var customs:Objects.Server.Customs;
	private var raw_interfaces:Objects.Server.Raw_Interfaces;
	private var toggle_monitors:Objects.Server.Monitors;
	private var cbus_lights:Objects.Server.CBusLights;
	private var x10_lights:Objects.Server.X10Lights;
	private var pulse_outputs:Objects.Server.Toggles;
	private var toggle_inputs:Objects.Server.Toggles;
	private var toggle_outputs:Objects.Server.Toggles;
	private var alarms:Objects.Server.Alarms;
	private var alerts:Objects.Server.Alerts;
	private var analogues:Objects.Server.Analogues;
	private var connection:XMLNode;
	private var parameters:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(counters.getKeys());
		tempKeys = tempKeys.concat(customs.getKeys());
		tempKeys = tempKeys.concat(raw_interfaces.getKeys());
		tempKeys = tempKeys.concat(toggle_monitors.getKeys());
		tempKeys = tempKeys.concat(cbus_lights.getKeys());
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
		if ((name == undefined) || (name == "")) {
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
		var tempCatalogues = catalogues.toXML();
		for (var child in tempCatalogues.childNodes) {
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newRawConnection = new XMLNode(1, type);
		var tempCustoms = customs.toXML();
		for(var child in tempCustoms.childNodes){
			newRawConnection.appendChild(tempCustoms.childNodes[child]);
		}
		var tempRaw_Interfaces = raw_interfaces.toXML();
		for(var child in tempRaw_Interfaces.childNodes){
			newRawConnection.appendChild(tempRaw_Interfaces.childNodes[child]);
		}
		var tempCounters = counters.toXML();
		for(var child in tempCounters.childNodes){
			newRawConnection.appendChild(tempCounters.childNodes[child]);
		}
		var tempMonitors = toggle_monitors.toXML();
		for(var child in tempMonitors.childNodes){
			newRawConnection.appendChild(tempMonitors.childNodes[child]);
		}
		var tempCbusLights = cbus_lights.toXML();
		for(var child in tempCbusLights.childNodes){
			newRawConnection.appendChild(tempCbusLights.childNodes[child]);
		}
		var tempX10Lights = x10_lights.toXML();
		for(var child in tempX10Lights.childNodes){
			newRawConnection.appendChild(tempX10Lights.childNodes[child]);
		}
		var tempPulseOutputs = pulse_outputs.toXML();
		for(var child in tempPulseOutputs.childNodes){
			newRawConnection.appendChild(tempPulseOutputs.childNodes[child]);
		}
		var tempToggleOutputs = toggle_outputs.toXML();
		for(var child in tempToggleOutputs.childNodes){
			newRawConnection.appendChild(tempToggleOutputs.childNodes[child]);
		}
		var tempToggleInputs = toggle_inputs.toXML();
		for(var child in tempToggleInputs.childNodes){
			newRawConnection.appendChild(tempToggleInputs.childNodes[child]);
		}
		var tempAlerts = alerts.toXML();
		for (var child in tempAlerts.childNodes){
			newRawConnection.appendChild(tempAlerts.childNodes[child]);
		}
		var tempAlarms = alarms.toXML();
		for (var child in tempAlarms.childNodes){
			newRawConnection.appendChild(tempAlarms.childNodes[child]);
		}
		var tempAnalogues = analogues.toXML();
		for (var child in tempAnalogues.childNodes){
			newRawConnection.appendChild(tempAnalogues.childNodes[child]);
		}
		newDevice.appendChild(newRawConnection);
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Customs");
		newNode.appendChild(catalogues.toTree());
		newNode.appendChild(counters.toTree());
		newNode.appendChild(customs.toTree());
		newNode.appendChild(raw_interfaces.toTree());
		newNode.appendChild(toggle_monitors.toTree());
		newNode.appendChild(cbus_lights.toTree());
		newNode.appendChild(x10_lights.toTree());
		newNode.appendChild(pulse_outputs.toTree());
		newNode.appendChild(toggle_inputs.toTree());
		newNode.appendChild(toggle_outputs.toTree());
		newNode.appendChild(alarms.toTree());
		newNode.appendChild(alerts.toTree());
		newNode.appendChild(analogues.toTree());
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
		raw_interfaces = new Objects.Server.Raw_Interfaces();
		customs = new Objects.Server.Customs();
		counters = new Objects.Server.Counters();
		toggle_monitors = new Objects.Server.Monitors();
		pulse_outputs = new Objects.Server.Toggles("PULSE_OUTPUT");
		toggle_outputs = new Objects.Server.Toggles("TOGGLE_OUTPUT");
		toggle_inputs = new Objects.Server.Toggles("TOGGLE_INPUT");
		cbus_lights = new Objects.Server.CBusLights();
		x10_lights = new Objects.Server.X10Lights();
		alarms = new Objects.Server.Alarms();
		alerts = new Objects.Server.Alerts();
		analogues = new Objects.Server.Analogues();
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1, type);
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
				case "COMFORT" :
					var tempNode = newData.childNodes[child];
					var tempCustomInputs = new XMLNode(1, type);
					var tempRawInterfaces = new XMLNode(1,type);
					var tempCounters = new XMLNode(1,type);
					var tempMonitors = new XMLNode(1,type);
					var tempCbusLights = new XMLNode(1,type);
					var tempX10Lights = new XMLNode(1,type);
					var tempPulseOutputs = new XMLNode(1,type);
					var tempToggleOutputs = new XMLNode(1,type);
					var tempToggleInputs = new XMLNode(1,type);
					var tempAlerts = new XMLNode(1,type);
					var tempAlarms = new XMLNode(1,type);
					var tempAnalogues = new XMLNode(1,type);
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
							tempCbusLights.appendChild(tempNode.childNodes[rawDevice]);
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
						case "ANALOGUE":
							tempAnalogues.appendChild(tempNode.childNodes[rawDevice]);
							break;
						}
					}
					customs.setXML(tempCustomInputs);
					cbus_lights.setXML(tempCbusLights);
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
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
