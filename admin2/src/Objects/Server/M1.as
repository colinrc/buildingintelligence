package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.M1_frm;
	
	[Bindable("m1")]
	[RemoteClass(alias="elifeAdmin.objects.server.m1")]
	
	public class M1 extends Device {
	//	private var device_type:String;
	//	private var description:String;
	//	private var active:String;
		private var contacts:ContactClosures;
		private var toggle_outputs:Toggles;
		private var sensors:M1Sensors;
		private var x10_lights:X10Lights;
		private var keypad:Keypad;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(contacts);
			output.writeObject(toggle_outputs);
			output.writeObject(sensors);
			output.writeObject(x10_lights);
			output.writeObject(keypad);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			contacts = input.readObject()as ContactClosures;
			toggle_outputs = input.readObject()as Toggles;
			sensors = input.readObject()as M1Sensors;
			x10_lights = input.readObject()as X10Lights;
			keypad = input.readObject()as Keypad;
		}
	
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(contacts.getKeys());
			tempKeys = tempKeys.concat(toggle_outputs.getKeys());
			tempKeys = tempKeys.concat(sensors.getKeys());
			tempKeys = tempKeys.concat(x10_lights.getKeys());
			tempKeys = tempKeys.concat(keypad.getKeys());
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			flag = super.isValid();		
						
			flag = getHighestFlagValue(flag, contacts.isValid());
			flag = getHighestFlagValue(flag, toggle_outputs.isValid());
			flag = getHighestFlagValue(flag, sensors.isValid());
			flag = getHighestFlagValue(flag, x10_lights.isValid());
			
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
			newDevice.appendChild(connection.toXML());
			
			var newParameters:XML = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				var x1:XML = new XML("<ITEM />");
				x1.@NAME = parameter;
				x1.@VALUE = parameters[parameter];
				newParameters.appendChild(x1);
			}
			var newItem:XML = new XML("<ITEM />");
			newItem.@NAME="POLL_SENSOR_INTERVAL";
			newItem.@VALUE="10";
			newParameters.appendChild(newItem);
			
			newDevice.appendChild(newParameters);
			var newM1:XML = new XML("<"+device_type+" />");
			var tempToggleOutputs:XML = toggle_outputs.toXML();
			for (var child:int=0 ; child < tempToggleOutputs.children().length() ; child++) {
				newM1.appendChild(tempToggleOutputs.children()[child]);
			}
			var tempContacts:XML = contacts.toXML();
			for (var child:int=0 ; child < tempContacts.children().length() ; child++) {
				newM1.appendChild(tempContacts.children()[child]);
			}
			var tempSensors:XML = sensors.toXML();
			for (var child:int=0 ; child < tempSensors.children().length() ; child++) {
				newM1.appendChild(tempSensors.children()[child]);
			}
			var tempX10Lights:XML = x10_lights.toXML();
			for (var child:int=0 ; child < tempX10Lights.children().length() ; child++) {
				newM1.appendChild(tempX10Lights.children()[child]);
			}
			var tempKeypad = keypad.toXML();
			for (var child:int=0 ; child < tempKeypad.children().length() ; child++) {
				newM1.appendChild(tempKeypad.children()[child]);
			}
			newDevice.appendChild(newM1);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(contacts.toTree());
			newNode.appendChild(toggle_outputs.toTree());
			newNode.appendChild(sensors.toTree());
			newNode.appendChild(x10_lights.toTree());
			newNode.appendChild(keypad.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "M1";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.M1_frm;
			return className;		
		}
		public override function newObject():void {
			super.newObject();
			device_type = "M1";
			description ="";
			active = "Y";		
				
			contacts = new Objects.Server.ContactClosures();
			sensors = new Objects.Server.M1Sensors();
			x10_lights = new Objects.Server.X10Lights();
			keypad = new Objects.Server.Keypad();
			toggle_outputs = new Objects.Server.Toggles();
			toggle_outputs.setType("TOGGLE_OUTPUT");
		}
			
		public override function setXML(newData:XML):void {
			device_type = "M1";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			contacts = new Objects.Server.ContactClosures();
			sensors = new Objects.Server.M1Sensors();
			x10_lights = new Objects.Server.X10Lights();
			keypad = new Objects.Server.Keypad();
			toggle_outputs = new Objects.Server.Toggles();
			toggle_outputs.setType("TOGGLE_OUTPUT");
			if (newData.name() == "DEVICE") {
				if(newData.@NAME!=undefined){
					device_type = newData.@NAME;
				}
				if(newData.@DEVICE_TYPE!=undefined){
					device_type = newData.@DEVICE_TYPE;
				}			
				if(newData.@DISPLAY_NAME!=undefined){			
					description = newData.@DISPLAY_NAME;
				}
				if(newData.@DESCRIPTION!=undefined){			
					description = newData.@DESCRIPTION;
				}			
				if(newData.@ACTIVE!=undefined){			
					active = newData.@ACTIVE;
				}
				for (var child:int=0 ; child < newData.children().length() ; child++) {
					var myType:String = newData.children()[child].name();
					switch (myType) {
					case "M1" :
						var tempContacts:XML = new XML("<contact_closures />");
						var tempToggleOutputs:XML = new XML("<"+device_type+" />");
						var tempSensors:XML = new XML("<sensors />");
						var tempX10Lights:XML = new XML("<"+device_type+" />");
						var tempKeypad:XML = new XML("<"+device_type+" />");
						var tempNode = newData.children()[child];
						for (var M1Device:int=0 ; M1Device < tempNode.children().length() ; M1Device++) {
						
						switch (tempNode.children()[M1Device].name().toString()) {
							case "LIGHT_X10":
								tempX10Lights.appendChild(tempNode.children()[M1Device]);
								break;
							case "CONTACT_CLOSURE" :
								tempContacts.appendChild(tempNode.children()[M1Device]);
								break;
							case "TOGGLE_OUTPUT":
								tempToggleOutputs.appendChild(tempNode.children()[M1Device]);
								break;
							case "SENSOR":
								tempSensors.appendChild(tempNode.children()[M1Device]);
								break;
							case "KEYPAD":
								tempKeypad.appendChild(tempNode.children()[M1Device]);
								break;
							}
						}
						contacts.setXML(tempContacts);
						toggle_outputs.setXML(tempToggleOutputs);
						sensors.setXML(tempSensors);
						x10_lights.setXML(tempX10Lights);
						keypad.setXML(tempKeypad);
						break;
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						}
						break;
					}
				}
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}