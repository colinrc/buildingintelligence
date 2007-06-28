package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Comfort_frm;
	[Bindable("Comfort")]
	[RemoteClass(alias="elifeAdmin.server.comfort")] 
	public class Comfort extends Device {
		private var counters:Counters;
		private var customs:Customs;
		private var raw_interfaces:Raw_Interfaces;
		private var toggle_monitors:Monitors;
		private var cbus_lights:CBusLights;
		private var cbus_relays:CBusRelays;			
		private var x10_lights:X10Lights;
		private var pulse_outputs:Toggles;
		private var toggle_inputs:Toggles;
		private var toggle_outputs:Toggles;
		private var alarms:Alarms;
		private var alerts:Objects.Server.Alerts;
		private var analogues:Analogues;
		private var door_ids:Catalogue;
		private var comfort_users:Catalogue;
		private var keypad:Keypad;
		private var password:String="";
		public override function get Data():ObjectProxy{
			return {device_type:device_type, description:description, active:active, connection:connection, parameters:parameters, password:password, dataObject:this};
		}
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(counters);
			output.writeObject(customs);
			output.writeObject(raw_interfaces);
			output.writeObject(toggle_monitors);
			output.writeObject(cbus_lights);
			output.writeObject(cbus_relays);		
			output.writeObject(x10_lights);
			output.writeObject(pulse_outputs);
			output.writeObject(toggle_inputs);
			output.writeObject(toggle_outputs);
			output.writeObject(alarms);
			output.writeObject(alerts);
			output.writeObject(analogues);
			output.writeObject(door_ids);
			output.writeObject(comfort_users);
			output.writeObject(keypad);
			output.writeUTF(password);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			counters = input.readObject() as Counters;
			customs = input.readObject() as Customs;
			raw_interfaces = input.readObject() as Raw_Interfaces;
			toggle_monitors = input.readObject() as Monitors;
			cbus_lights = input.readObject() as CBusLights;
			cbus_relays = input.readObject() as CBusRelays;			
			x10_lights = input.readObject() as X10Lights;
			pulse_outputs = input.readObject() as Toggles;
			toggle_inputs = input.readObject() as Toggles;
			toggle_outputs = input.readObject() as Toggles;
			alarms = input.readObject() as Alarms;
			alerts = input.readObject() as Objects.Server.Alerts;
			analogues = input.readObject() as Analogues;
			door_ids = input.readObject() as Catalogue;
			comfort_users = input.readObject() as Catalogue;
			keypad = input.readObject() as Keypad;
			password = input.readUTF()as String;
		}
		
		public override function set Data(newData:ObjectProxy):void {
			device_type = newData.device_type;
			description = newData.description;
			active = newData.active;
			connection = newData.connection;
			parameters = newData.parameters;
			password = newData.password;
		}
		public function getKeys():Array{
			var tempKeys:Array = new Array();
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
			tempKeys = tempKeys.concat(keypad.getKeys());
			return tempKeys;
		}
		public override function isValid():String {
			var flag:String = super.isValid();
			flag = getHighestFlagValue(flag, customs.isValid());
			flag = getHighestFlagValue(flag, raw_interfaces.isValid());
			flag = getHighestFlagValue(flag, counters.isValid());
			flag = getHighestFlagValue(flag, toggle_monitors.isValid());
			flag = getHighestFlagValue(flag, cbus_lights.isValid());
			flag = getHighestFlagValue(flag, cbus_relays.isValid());
			flag = getHighestFlagValue(flag, x10_lights.isValid());
			flag = getHighestFlagValue(flag, pulse_outputs.isValid());
			flag = getHighestFlagValue(flag, toggle_outputs.isValid());
			flag = getHighestFlagValue(flag, toggle_inputs.isValid());
			flag = getHighestFlagValue(flag, alarms.isValid());
			flag = getHighestFlagValue(flag, alerts.isValid());
			flag = getHighestFlagValue(flag, analogues.isValid());
			flag = getHighestFlagValue(flag, catalogues.isValid());
			flag = getHighestFlagValue(flag, door_ids.isValid());
			flag = getHighestFlagValue(flag, comfort_users.isValid());
			
			return flag;
		}
		
		public override function toXML():XML {
			var newDevice:XML = new XML("<DEVICE />");
			if(device_type != ""){
				newDevice.@DEVICE_TYPE = device_type;
			}
			if(description != ""){
				newDevice.@DESCRIPTION = description;
			}
			if(active != "") {
				newDevice.@ACTIVE = active;
			}
			if(password!=""){
				newDevice.@PASSWORD = password;
			}
			newDevice.appendChild(connection.toXML());
			////////////////////////////////////////////////////////////////////
			var newParameters:XML = new XML("<PARAMETERS />");
			var newParameter:XML;
			for (var myName:String in parameters) {
                
                if (myName != "DOOR_IDS" && myName != "COMFORT_USERS")
                {
                    newParameter = new XML("<ITEM />");
					newParameter.@NAME = myName;
					newParameter.@VALUE = parameters[myName];
					newParameters.appendChild(newParameter);
                }
            }
			
			newParameter = new XML("<ITEM />");
			newParameter.@NAME = "DOOR_IDS";
			newParameter.@VALUE = "Door IDs";
			newParameters.appendChild(newParameter);
			newParameter = new XML("<ITEM />");
			newParameter.@NAME = "COMFORT_USERS";
			newParameter.@VALUE = "Comfort Users";		
			newParameters.appendChild(newParameter);		
			newDevice.appendChild(newParameters);
			newDevice.appendChild(door_ids.toXML());
			newDevice.appendChild(comfort_users.toXML());
			var tempCatalogues = catalogues.toXML();
			for (var child in tempCatalogues.childNodes) {
				newDevice.appendChild(tempCatalogues.childNodes[child]);
			}
			var newComfort = new XML(device_type);
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
			var tempKeypad = keypad.toXML();
			for (var child in tempKeypad.childNodes){
				newComfort.appendChild(tempKeypad.childNodes[child]);
			}
			newDevice.appendChild(newComfort);	
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			if(mx.core.Application.application.advancedOn == true){
				newNode.appendChild(catalogues.toTree());		
				newNode.appendChild(customs.toTree());
				newNode.appendChild(raw_interfaces.toTree());
				newNode.appendChild(alarms.toTree());
				newNode.appendChild(alerts.toTree());			
			}		
			newNode.appendChild(keypad.toTree());
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
		public override function getName():String {
			return "COMFORT : " + description;
		} 
		public function getClassForm():Class {
			var className:Class = Forms.Server.Comfort_frm;
			return className;		
		}
		
		public override function newObject():void {
			super.newObject();
			device_type = "COMFORT";
			description ="";
			active = "Y";		
			password = "1234";
					
			raw_interfaces = new Raw_Interfaces();
			raw_interfaces.raw_interfaces = new Array();
			customs = new Customs();
			counters = new Counters();
			toggle_monitors = new Monitors();
			pulse_outputs = new Toggles();
			pulse_outputs.setType("PULSE_OUTPUT");
			toggle_outputs = new Toggles();
			toggle_outputs.setType("TOGGLE_OUTPUT");
			toggle_inputs = new Toggles();
			toggle_inputs.setType("TOGGLE_INPUT");
			cbus_lights = new CBusLights();
			cbus_relays = new CBusRelays();		
			x10_lights = new X10Lights();
			alarms = new Alarms();
			alerts = new Alerts();
			analogues = new Analogues();
			keypad = new Keypad();
			door_ids = new Catalogue();
			comfort_users = new Catalogue();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "COMFORT";
			description ="";
			active = "Y";		
			password = "1234";
			parameters = new HashMap();		
			raw_interfaces = new Raw_Interfaces();	
			customs = new Customs();
			counters = new Counters();
			toggle_monitors = new Monitors();
			pulse_outputs = new Toggles();
			pulse_outputs.setType("PULSE_OUTPUT");
			toggle_outputs = new Toggles();
			toggle_outputs.setType("TOGGLE_OUTPUT");
			toggle_inputs = new Toggles();
			toggle_inputs.setType("TOGGLE_INPUT");
			cbus_lights = new CBusLights();
			cbus_relays = new CBusRelays();		
			x10_lights = new X10Lights();
			alarms = new Alarms();
			alerts = new Alerts();
			analogues = new Analogues();
			catalogues = new Catalogues();
			keypad = new Keypad();
			door_ids = new Catalogue();
			comfort_users = new Catalogue();
			var newDoors:XML = new XML("<CATALOGUE />");
			newDoors.@NAME = "Door IDs";
			door_ids.setXML(newDoors);
			var newUsers:XML = new XML("<CATALOGUE />");
			newUsers.@NAME = "Comfort Users";
			comfort_users.setXML(newUsers);			
			var tempCatalogues:XML = new XML("<"+device_type+" />");
			if (newData.name() == "DEVICE") {
				device_type = newData.@NAME;
				if (device_type == undefined || device_type == "") {
					device_type = newData.@DEVICE_TYPE;	
				}
				description = newData.@DISPLAY_NAME;
				if (description == undefined || description == "") {			
					description = newData.@DESCRIPTION;
				}		
				active = newData.@ACTIVE;		
				password = newData.@PASSWORD;
				
				for (var child:int=0; child < newData.children().length();child++) {
					var myType:String = newData.children()[child].name();
					switch (myType) {
					case "CONNECTION" :
						connection.setXML(newData.CONNECTION[0]);
						break;
					case "PARAMETERS" :
						for (var parameter:int=0; parameter < newData.children()[child].children().length();parameter++) {
							if((newData.children()[child].children()[parameter].@NAME != "DOOR_IDS")&&(newData.children()[child].children()[parameter].@NAME != "COMFORT_USERS")){
								parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						  	}
						}
						break;
					case "CATALOGUE" :
						if(newData.children()[child].@NAME == "Door IDs"){
							door_ids.setXML(newData.children()[child]);
						} else if(newData.children()[child].@NAME == "Comfort Users"){
							comfort_users.setXML(newData.children()[child]);						
						} else {
							tempCatalogues.appendChild(newData.children()[child]);
						}
						break;
					case "COMFORT" :
						var tempNode:XML = newData.children()[child];
						var tempCustomInputs:XML = new XML("<"+device_type+" />");
						var tempRawInterfaces:XML = new XML("<"+device_type+" />");
						var tempCounters:XML = new XML("<"+device_type+" />");
						var tempMonitors:XML = new XML("<"+device_type+" />");
						var tempCbusLights:XML = new XML("<"+device_type+" />");
						var tempCbusRelays:XML = new XML("<"+device_type+" />");					
						var tempX10Lights:XML = new XML("<"+device_type+" />");
						var tempPulseOutputs:XML = new XML("<"+device_type+" />");
						var tempToggleOutputs:XML = new XML("<"+device_type+" />");
						var tempToggleInputs:XML = new XML("<"+device_type+" />");
						var tempAlerts:XML = new XML("<"+device_type+" />");
						var tempAlarms:XML = new XML("<"+device_type+" />");
						var tempAnalogues:XML = new XML("<"+device_type+" />");
						var tempKeypad:XML = new XML("<"+device_type+" />");
						
						for (var rawDevice:int ; rawDevice < tempNode.children().length() ; rawDevice++) {
							switch (tempNode.children()[rawDevice].name()) {
							case "CUSTOM_INPUT" :
								tempCustomInputs.appendChild(tempNode.children()[rawDevice]);
								break;
							case "RAW_INTERFACE" :
								tempRawInterfaces.appendChild(tempNode.children()[rawDevice]);
								break;
							case "COUNTER":
								tempCounters.appendChild(tempNode.children()[rawDevice]);
								break;
							case "TOGGLE_OUTPUT_MONITOR":
								tempMonitors.appendChild(tempNode.children()[rawDevice]);
								break;
							case "LIGHT_CBUS":
								if(tempNode.children()[rawDevice].@RELAY == "Y"){
									tempCbusRelays.appendChild(tempNode.children()[rawDevice]);							
								} else {
									tempCbusLights.appendChild(tempNode.children()[rawDevice]);
								}
								break;
							case "LIGHT_X10":
								tempX10Lights.appendChild(tempNode.children()[rawDevice]);
								break;
							case "PULSE_OUTPUT":
								tempPulseOutputs.appendChild(tempNode.children()[rawDevice]);
								break;
							case "TOGGLE_OUTPUT":
								tempToggleOutputs.appendChild(tempNode.children()[rawDevice]);
								break;
							case "TOGGLE_INPUT":
								tempToggleInputs.appendChild(tempNode.children()[rawDevice]);
								break;
							case "ALARM":
								tempAlarms.appendChild(tempNode.children()[rawDevice]);
								break;
							case "ALERT":
								tempAlerts.appendChild(tempNode.children()[rawDevice]);
								break;
							case "KEYPAD":
								tempKeypad.appendChild(tempNode.children()[rawDevice]);
								break;
							case "ANALOG":
							case "ANALOGUE":
								tempAnalogues.appendChild(tempNode.children()[rawDevice]);
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
						keypad.setXML(tempKeypad);
						break;
					}
				}
				catalogues.setXML(tempCatalogues);
				raw_interfaces.catalogues = catalogues;
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}