﻿package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.CBus_frm;
	import Forms.test;
	[Bindable("Cbus")]
	[RemoteClass(alias="elifeAdmin.server.CBus")]
	public class CBus extends Device{
		private var sensors:CBusSensors;
		private var temperatureSensors:CBusTemperatureSensors;
		private var lights:CBusLights;
		private var relays:CBusRelays;
		private var labelNames:Catalogue;
		private var labels:CBusLabels;
		public function getKeys():Array{
			var tempKeys:Array = new Array();
			tempKeys = tempKeys.concat(sensors.getKeys());
			tempKeys = tempKeys.concat(lights.getKeys());
			tempKeys = tempKeys.concat(relays.getKeys());
			tempKeys = tempKeys.concat(temperatureSensors.getKeys());		
			tempKeys = tempKeys.concat(labels.getKeys());		
			return tempKeys;
		}
				
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(sensors);
			output.writeObject(lights);
			output.writeObject(relays);
			output.writeObject(labelNames);
			output.writeObject(temperatureSensors);
			output.writeObject(labels);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);	
			sensors = input.readObject() as CBusSensors;
			lights = input.readObject() as CBusLights;
			relays = input.readObject() as CBusRelays;
			labelNames = input.readObject() as Catalogue;
			temperatureSensors = input.readObject() as Objects.Server.CBusTemperatureSensors;
			labels = input.readObject() as Objects.Server.CBusLabels;			
		}
		
		public override function isValid():String {
			var flag:String = super.isValid();
				//flag = getHighestFlagValue(flag, sensors.isValid());
				//flag = getHighestFlagValue(flag, lights.isValid());
				//flag = getHighestFlagValue(flag, relays.isValid());
				//flag = getHighestFlagValue(flag, temperatureSensors.isValid());
				//need to isValid connection and parameters 
				
				//appendValidationMsg("CBUS is invalid");
			
			return flag;
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.CBus_frm;
			return className;		
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
			newDevice.appendChild(connection.toXML());
			var newParameters:XML = new XML("<PARAMETERS />");
			
			var x1:XML = new XML("<ITEM />");
			if (parameters.containsKey("POLL_TEMP_INTERVAL") == true) { 
				x1.@NAME = "POLL_TEMP_INTERVAL";
				x1.@VALUE = parameters.getValue("POLL_TEMP_INTERVAL");
				newParameters.appendChild(x1);
			}
			var x2:XML = new XML("<ITEM />");
			if (parameters.containsKey("LABELS") == true) { 
				x2.@NAME = "LABELS";
				x2.@VALUE = parameters.getValue("LABELS");
				newParameters.appendChild(x2);
			}
			
			newDevice.appendChild(newParameters);
			newDevice.appendChild(labelNames.toXML());
			var newCBus:XML = new XML("<"+device_type+" />");
			var tempSensors:XML = sensors.toXML();
			for (var child:int in tempSensors.children()) {
				newCBus.appendChild(tempSensors.children()[child]);
			}
			var tempLights:XML = lights.toXML();
			for (var child2:int in tempLights.children()) {
				newCBus.appendChild(tempLights.children()[child2]);
			}
			var tempRelays:XML = relays.toXML();
			for (var child3:int in tempRelays.children()) {
				newCBus.appendChild(tempRelays.children()[child3]);
			}
			var tempTemperatureSensors:XML = temperatureSensors.toXML();
			for (var child4:int in tempTemperatureSensors.children()) {
				newCBus.appendChild(tempTemperatureSensors.children()[child4]);
			}		
			var tempLabels:XML = labels.toXML();
			for(var child5:int in tempLabels.children()){
				newCBus.appendChild(tempLabels.children()[child5]);
			}
			newDevice.appendChild(newCBus);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(lights.toTree());
			newNode.appendChild(relays.toTree());
			if(Application.application.advancedOn == true){		
				newNode.appendChild(sensors.toTree());		
				newNode.appendChild(temperatureSensors.toTree());
			}
			newNode.appendChild(labelNames.toTree());
			newNode.appendChild(labels.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "CBus";
		}
		
		public override function newObject():void {
			super.newObject();
			device_type = "CBUS";
			description ="";
			active = "Y";		
			
			sensors = new CBusSensors();
			lights = new CBusLights();
			relays = new CBusRelays();
			labelNames = new Catalogue();
			temperatureSensors = new Objects.Server.CBusTemperatureSensors();
			labels = new Objects.Server.CBusLabels();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			
			active = "Y";		
			parameters = new HashMap();		
			sensors = new CBusSensors();
			lights = new CBusLights();
			relays = new CBusRelays();
			
			var newLabelNames:XML = new XML("<CATALOGUE />");
			newLabelNames.@NAME = "Button Labels";
			
			labelNames = new Catalogue();
			
			labelNames.setXML(newLabelNames);		
			temperatureSensors = new Objects.Server.CBusTemperatureSensors();
			labels = new Objects.Server.CBusLabels();
			if (newData.name() == "DEVICE") {
				device_type = newData.@NAME ;
				if (device_type.length == 0) {
					device_type = newData.@DEVICE_TYPE.toString() ;
				}
				description = newData.@DISPLAY_NAME;
				if (description.length == 0) {		
					description = newData.@DESCRIPTION;		
				}
				active = newData.@ACTIVE;
				
			}
				
			var tempNode:XML = newData.CBUS[0];
			
			var tempSensors:XML = new XML("<sensors />");
			var tempLights:XML = new XML("<lights />");
			var tempRelays:XML = new XML("<relays />");
			var tempTemperatureSensors:XML = new XML("<temperatureSensors />");
			var tempLabels:XML = new XML("<labels />");
			
			var sizeOfLight:int = tempNode.LIGHT_CBUS.length();	
			var i:int;
			for (i = 0; i < sizeOfLight; i++) {
				var temp:XML = tempNode.LIGHT_CBUS[i];
				if(temp.@RELAY == "Y"){
					tempRelays.appendChild(temp);
				}
				else{					
					tempLights.appendChild(temp);
				}
			}
			
			tempSensors.appendChild(tempNode.SENSOR[0]);
			tempTemperatureSensors.appendChild(tempNode.TEMPERATURE[0]);
			tempLabels.appendChild(tempNode.LABEL[0]);
				
			sensors.setXML(tempSensors);
			lights.setXML(tempLights);
			relays.setXML(tempRelays);
			temperatureSensors.setXML(tempTemperatureSensors);
			labels.setXML(tempLabels);

			var tempCat:XML = newData.CATALOGUE[0];
			
			if (tempCat != null && tempCat.@NAME == "Button Labels"){
				labelNames.setXML(tempCat);
			}
			
			connection.setXML(newData.CONNECTION[0]);
			
			var tempPar:XML = newData.PARAMETERS[0];
			
			var sizeOfPar:int = tempPar.ITEM.length();	
			var k:int;
			parameters.clear();
			
			for (k = 0; k < sizeOfPar; k++) {
				var t1:XML = tempPar.ITEM[k];
				var name:String =t1.@NAME;
				var val:String = t1.@VALUE;
				parameters.put(name, val);
			}
			
		}
	}
}
