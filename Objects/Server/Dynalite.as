package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("Dynalite")]
	[RemoteClass(alias="elifeAdmin.server.dynalite")] 
	public class Dynalite extends Device {
	//	private var device_type:String;
	//	private var description:String;
	//	private var active:String;
		private var irs:DynaliteIRs;
		private var lights:DynaliteLights;
		private var relays:DynaliteRelays;
		private var lightAreas:DynaliteLightAreas;	
		private var contacts:ContactClosures;
		private var alarms:Alarms
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(irs);
			output.writeObject(lights);
			output.writeObject(relays);
			output.writeObject(lightAreas);
			output.writeObject(contacts);
			output.writeObject(alarms);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			irs = input.readObject()as DynaliteIRs;
			lights = input.readObject()as DynaliteLights;
			relays = input.readObject()as DynaliteRelays;
			lightAreas = input.readObject()as DynaliteLightAreas;	
			contacts = input.readObject()as ContactClosures;
			alarms = input.readObject()as Alarms;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(lights.getKeys());
			tempKeys = tempKeys.concat(relays.getKeys());
			tempKeys = tempKeys.concat(contacts.getKeys());
			tempKeys = tempKeys.concat(irs.getKeys());
			tempKeys = tempKeys.concat(lightAreas.getKeys());
			tempKeys = tempKeys.concat(alarms.getKeys());
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
					newFlag = getHighestFlagValue(flag, irs.isValid());
					newFlag = getHighestFlagValue(flag, lights.isValid());
					newFlag = getHighestFlagValue(flag, contacts.isValid());
					newFlag = getHighestFlagValue(flag, alarms.isValid());
					newFlag = getHighestFlagValue(flag, lightAreas.isValid());
					
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
			var newDynalite = new XML(device_type);
			var tempIRs = irs.toXML();
			for (var child in tempIRs.childNodes) {
				newDynalite.appendChild(tempIRs.childNodes[child]);
			}
			var tempLights = lights.toXML();
			for (var child in tempLights.childNodes) {
				newDynalite.appendChild(tempLights.childNodes[child]);
			}
			var tempRelays = relays.toXML();
			for (var child in tempRelays.childNodes) {
				newDynalite.appendChild(tempRelays.childNodes[child]);
			}		
			var tempContacts = contacts.toXML();
			for (var child in tempContacts.childNodes) {
				newDynalite.appendChild(tempContacts.childNodes[child]);
			}
			var tempLightAreas = lightAreas.toXML();
			for (var child in tempLightAreas.childNodes) {
				newDynalite.appendChild(tempLightAreas.childNodes[child]);
			}		
			var tempAlarms = alarms.toXML();
			for (var child in tempAlarms.childNodes) {
				newDynalite.appendChild(tempAlarms.childNodes[child]);
			}
			newDevice.appendChild(newDynalite);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(lights.toTree());
			newNode.appendChild(relays.toTree());
			newNode.appendChild(contacts.toTree());
			newNode.appendChild(lightAreas.toTree());
			if(Application.application.advanced){		
				newNode.appendChild(irs.toTree());		
				newNode.appendChild(alarms.toTree());
			}
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Dynalite";
		}
		
		public function newObject():void {
			device_type = "DYNALITE";
			description ="";
			active = "Y";		
			parameters = new Array();		
			irs = new Objects.Server.DynaliteIRs();
			lights = new Objects.Server.DynaliteLights();
			relays = new Objects.Server.DynaliteRelays();
			lightAreas = new Objects.Server.DynaliteLightAreas();
			contacts = new Objects.Server.ContactClosures();
			alarms = new Objects.Server.Alarms();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";		
			parameters = new Array();		
			irs = new Objects.Server.DynaliteIRs();
			lights = new Objects.Server.DynaliteLights();
			relays = new Objects.Server.DynaliteRelays();
			lightAreas = new Objects.Server.DynaliteLightAreas();
			contacts = new Objects.Server.ContactClosures();
			alarms = new Objects.Server.Alarms();
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
						var tempIRs = new XML("<irs />");
						var tempLights = new XML("<lights />");
						var tempContacts = new XML("<contact closures />");
						var tempLightAreas = new XML("<light areas />");
						var tempRelays = new XML("<relays />");
						var tempAlarms = new XML("<alarms />");
						var tempNode:XML = newData.children()[child];
						for (var dynaliteDevice:int=0 ; dynaliteDevice < tempNode.children().length() ; dynaliteDevice++) {
							switch (tempNode.children()[dynaliteDevice].name()) {
							case "LIGHT_DYNALITE" :
								if(tempNode.children()[dynaliteDevice].@RELAY == "Y"){
									tempRelays.appendChild(tempNode.children()[dynaliteDevice]);								
								} else {
									tempLights.appendChild(tempNode.children()[dynaliteDevice]);
								}
								break;
							case "IR" :
								tempIRs.appendChild(tempNode.children()[dynaliteDevice]);
								break;
							case "CONTACT_CLOSURE" :
								tempContacts.appendChild(tempNode.children()[dynaliteDevice]);
								break;
							case "LIGHT_DYNALITE_AREA" :
								tempLightAreas.appendChild(tempNode.children()[dynaliteDevice]);
								break;
							case "ALARM":
								tempAlarms.appendChild(tempNode.children()[dynaliteDevice]);
								break;
							}
						}
						relays.setXML(tempRelays);
						irs.setXML(tempIRs);
						lights.setXML(tempLights);
						contacts.setXML(tempContacts);
						lightAreas.setXML(tempLightAreas);
						alarms.setXML(tempAlarms);
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