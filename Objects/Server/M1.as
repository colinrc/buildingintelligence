package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
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
					
			if ((active != "Y") && (active != "N")) {
				flag = "error";
				appendValidationMsg("Active is invalid");
			}
			else {
				if (active =="Y"){
					if ((description == undefined) || (description == "")) {
						flag = "warning";
						appendValidationMsg("Description is invalid");
					}
					if ((device_type == undefined) || (device_type == "")) {
						flag = "error";
						appendValidationMsg("Device Type is invalid");
					}
					var newFlag:String;				
					newFlag = getHighestFlagValue(flag, contacts.isValid());
					newFlag = getHighestFlagValue(flag, toggle_outputs.isValid());
					newFlag = getHighestFlagValue(flag, sensors.isValid());
					newFlag = getHighestFlagValue(flag, x10_lights.isValid());
					if (newFlag != "ok") {
						appendValidationMsg("M1 is invalid");
					}
					flag = getHighestFlagValue(flag, newFlag);
					
					if (connection.children()[0].name() == "IP") {
						if ((connection.children()[0].@IP_ADDRESS == "") || (connection.children()[0].@IP_ADDRESS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Address is invalid");
						}
						if ((connection.children()[0].@PORT == "") || (connection.children()[0].@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is invalid");
						}
					}
					else{
						//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
						if ((connection.children()[0].@PORT == "") || (connection.children()[0].@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is invalid");
						}
						if ((connection.children()[0].@FLOW == "") || (connection.children()[0].@FLOW ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Flow is invalid");
						}
						if ((connection.children()[0].@DATA_BITS == "") || (connection.children()[0].@DATA_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Data Bits is invalid");
						}
						if ((connection.children()[0].@STOP_BITS == "") || (connection.children()[0].@STOP_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Stop Bits is invalid");
						}
						if ((connection.children()[0].@SUPPORTS_CD == "") || (connection.children()[0].@SUPPORTS_CD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Supports CD is invalid");
						}
						if ((connection.children()[0].@PARITY == "") || (connection.children()[0].@PARITY ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Parity is invalid");
						}
						if ((connection.children()[0].@BAUD == "") || (connection.children()[0].@BAUD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Baud is invalid");
						}
					}
				}
				else {
					if (active =="N"){
						flag = "empty";
						appendValidationMsg("M1 is not active");
					}
				}
				
			}
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
			newDevice.appendChild(connection);
			var newParameters = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				newParameters.appendChild(parameters[parameter]);
			}
			//<ITEM NAME="POLL_SENSOR_INTERVAL" VALUE="10"/>
			var newItem = new XML("<ITEM />");
			newItem.@NAME="POLL_SENSOR_INTERVAL";
			newItem.@VALUE="10";
			newParameters.appendChild(newItem);
			newDevice.appendChild(newParameters);
			var newM1:XML = new XML(device_type);
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
		
		public override function newObject():void {
			super.newObject();
			device_type = "M1";
			description ="";
			active = "Y";		
				
			contacts = new Objects.Server.ContactClosures();
			sensors = new Objects.Server.M1Sensors();
			x10_lights = new Objects.Server.X10Lights();
			keypad = new Objects.Server.Keypad();
			toggle_outputs = new Objects.Server.Toggles("TOGGLE_OUTPUT");
		}
			
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			contacts = new Objects.Server.ContactClosures();
			sensors = new Objects.Server.M1Sensors();
			x10_lights = new Objects.Server.X10Lights();
			keypad = new Objects.Server.Keypad();
			toggle_outputs = new Objects.Server.Toggles("TOGGLE_OUTPUT");
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
					switch (newData.children()[child].name()) {
					case "M1" :
						var tempContacts:XML = new XML("<contact_closures />");
						var tempToggleOutputs:XML = new XML(device_type);
						var tempSensors:XML = new XML("<sensors />");
						var tempX10Lights:XML = new XML(device_type);
						var tempKeypad:XML = new XML(device_type);
						var tempNode = newData.children()[child];
						for (var M1Device:int=0 ; M1Device < tempNode.children().length() ; M1Device++) {
						switch (tempNode.children()[M1Device].name()) {
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
						connection = newData.children()[child];
						break;
					case "PARAMETERS" :
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.push(newData.children()[child].children()[parameter]);
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