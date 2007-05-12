package Objects.Server {
	import Objects.Server.Device;
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("DMX")]
	[RemoteClass(alias="elifeAdmin.server.dmx")] 
	public class DMX extends Device {
	//	private var device_type:String;
	//	private var description:String;
	//	public var active:String;
		private var lights:DMXLights;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(lights);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			lights = input.readObject()as DMXLights;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(lights.getKeys());
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
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((device_type == undefined) || (device_type == "")) {
						flag = "error";
						appendValidationMsg("Device Type is invalid");
					}
					var newFlag:String;				
					newFlag = getHighestFlagValue(flag, lights.isValid());
					
					if (newFlag != "ok") {
						appendValidationMsg("Dynalite is invalid");
					}
					flag = getHighestFlagValue(flag, newFlag);
					
					if (connection.children()[0].name() == "IP") {
						if ((connection.children()[0].@IP_ADDRESS == "") || (connection.children()[0].@IP_ADDRESS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Address is empty");
						}
						else if (Application.application.isValidIP(connection.children()[0].@IP_ADDRESS)==false) {
							flag = "error";
							appendValidationMsg("Connection IP Address is invalid");
						}
						if ((connection.children()[0].@PORT == "") || (connection.children()[0].@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is empty");
						}
					}
					else{
						//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
						if ((connection.children()[0].@PORT == "") || (connection.children()[0].@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is empty");
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
						appendValidationMsg("Dynalite is not active");
					}
				}
				
			}
			return flag;
		}
		public override function toXML():XML {
			var newDevice = new XML("<DEVICE />");
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
			newDevice.appendChild(newParameters);
			var newDMX:XML = new XML("<"+device_type+" />");
			var tempLights:XML = lights.toXML();
			for (var child:int=0 ; child < tempLights.children().length() ; child++) {
				newDMX.appendChild(tempLights.children()[child]);
			}
			newDevice.appendChild(newDMX);
			return newDevice;			
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(lights.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "DMX";
		}
		
		public function newObject():void {
			device_type = "DMX";
			description ="";
			active = "Y";		
			parameters = new Array();		
			lights = new Objects.Server.DMXLights();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";		
			parameters = new Array();		
			lights = new Objects.Server.DMXLights();
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
					case "DYNALITE" :
						var tempLights = new XML("<lights />");
						var tempNode = newData.children()[child];
						for (var dynaliteDevice:int=0 ; dynaliteDevice < tempNode.children().length() ; dynaliteDevice++) {
							switch (tempNode.children()[dynaliteDevice].nodeName) {
							case "LIGHT" :
								tempLights.appendChild(tempNode.children()[dynaliteDevice]);
								break;
							}
						}
						lights.setXML(tempLights);
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