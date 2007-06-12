package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("jandy")]
	[RemoteClass(alias="elifeAdmin.objects.server.jandy")]
	public class Jandy extends Device {
	//	private var device_type:String;
	//	private var description:String;
	//	private var active:String;
		private var outputs:Toggles;
		private var sensors:Toggles;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(outputs);
			output.writeObject(sensors);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			outputs = input.readObject()as Toggles;
			sensors = input.readObject()as Toggles;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(outputs.getKeys());
			tempKeys = tempKeys.concat(sensors.getKeys());
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
					newFlag = getHighestFlagValue(flag, outputs.isValid());
					newFlag = getHighestFlagValue(flag, sensors.isValid());
					if (newFlag != "ok") {
						appendValidationMsg("Jandy is invalid");
					}
					flag = getHighestFlagValue(flag, newFlag);
					
					if (connection.children()[0].name() == "IP") {
						if ((connection.@IP_ADDRESS == "") || (connection.@IP_ADDRESS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Address is invalid");
						}
						if ((connection.@PORT == "") || (connection.@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is invalid");
						}
					}
					else{
						//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
						if ((connection.@PORT == "") || (connection.@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is invalid");
						}
						if ((connection.@FLOW == "") || (connection.@FLOW ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Flow is invalid");
						}
						if ((connection.@DATA_BITS == "") || (connection.@DATA_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Data Bits is invalid");
						}
						if ((connection.@STOP_BITS == "") || (connection.@STOP_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Stop Bits is invalid");
						}
						if ((connection.@SUPPORTS_CD == "") || (connection.@SUPPORTS_CD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Supports CD is invalid");
						}
						if ((connection.@PARITY == "") || (connection.@PARITY ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Parity is invalid");
						}
						if ((connection.@BAUD == "") || (connection.@BAUD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Baud is invalid");
						}
					}
				}
				else {
					if (active =="N"){
						flag = "empty";
						appendValidationMsg("Jandy is not active");
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
			var newParameters:XML = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				newParameters.appendChild(parameters[parameter]);
			}
			var newItem = new XML("<ITEM />");
			newItem.@NAME="UNITS";
			newItem.@VALUE="C";
			newParameters.appendChild(newItem);
			newDevice.appendChild(newParameters);
			var newJandy:XML = new XML("<"+device_type+" />");
			var tempOutputs = outputs.toXML();
			
			for (var child:int=0 ; child < tempOutputs.children().length() ; child++) {
				newJandy.appendChild(tempOutputs.children()[child]);
			}
			var tempSensors = sensors.toXML();
			for (var child:int=0 ; child < tempSensors.children().length() ; child++) {
				newJandy.appendChild(tempSensors.children[child]);
			}
			newDevice.appendChild(newJandy);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(outputs.toTree());
			newNode.appendChild(sensors.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Jandy";
		}
		
		public function newObject():void {
			device_type = "JANDI";
			description ="";
			active = "Y";		
			parameters = new Array();		
			sensors = new Objects.Server.Toggles("SENSOR");
			outputs = new Objects.Server.Toggles("OUTPUT");
		}
			
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";		
			parameters = new Array();		
			sensors = new Objects.Server.Toggles("SENSOR");
			outputs = new Objects.Server.Toggles("OUTPUT");
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
					case "JANDI" :
						var tempOutputs:XML = new XML("<"+device_type+" />");
						var tempSensors:XML = new XML("<sensors />");
						var tempNode = newData.childNodes[child];
						for (var JandyDevice:int=0 ; JandyDevice < tempNode.children().length() ; JandyDevice++) {
						switch (tempNode.children()[JandyDevice].name()) {
							case "OUTPUT":
								tempOutputs.appendChild(tempNode.children()[JandyDevice]);
								break;
							case "SENSOR":
								tempSensors.appendChild(tempNode.children()[JandyDevice]);
								break;
							}
						}
						outputs.setXML(tempOutputs);
						sensors.setXML(tempSensors);
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