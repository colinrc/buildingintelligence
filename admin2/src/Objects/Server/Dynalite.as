package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Dynalite_frm;
	
	[Bindable("Dynalite")]
	[RemoteClass(alias="elifeAdmin.server.dynalite")] 
	public class Dynalite extends Device {
	//	private var device_type:String;
	//	private var description:String;
	//	private var active:String;
		[Bindable]
		public var irs:DynaliteIRs;
		[Bindable]
		public var lights:DynaliteLights;
		[Bindable]
		public var relays:DynaliteRelays;
		[Bindable]
		public var lightAreas:DynaliteLightAreas;	
		[Bindable]
		public var contacts:ContactClosures;
		[Bindable]
		public var alarms:Alarms
		
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
			var flag:String = super.isValid();
			
			flag = getHighestFlagValue(flag, irs.isValid());
			flag = getHighestFlagValue(flag, lights.isValid());
			flag = getHighestFlagValue(flag, contacts.isValid());
			flag = getHighestFlagValue(flag, alarms.isValid());
			flag = getHighestFlagValue(flag, lightAreas.isValid());
			return flag;
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.Dynalite_frm;
			return className;		
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
			newDevice.appendChild(connection.toXML());
			var newParameters:XML = new XML("<PARAMETERS />");
			
			var x1:XML = new XML("<ITEM />");
			if (parameters.containsKey("PROTOCOL") == true) { 
				x1.@NAME = "PROTOCOL";
				x1.@VALUE = parameters.getValue("PROTOCOL");
				newParameters.appendChild(x1);
			}
			newDevice.appendChild(newParameters);
			
			var newDynalite:XML = new XML("<DYNALITE />");
			var tempIRs:XML = irs.toXML();
			for (var child in tempIRs.children()) {
				newDynalite.appendChild(tempIRs.children()[child]);
			}
			var tempLights:XML = lights.toXML();
			for (var child in tempLights.children()) {
				newDynalite.appendChild(tempLights.children()[child]);
			}
			var tempRelays:XML = relays.toXML();
			for (var child in tempRelays.children()) {
				newDynalite.appendChild(tempRelays.children()[child]);
			}		
			var tempContacts:XML = contacts.toXML();
			for (var child in tempContacts.children()) {
				newDynalite.appendChild(tempContacts.children()[child]);
			}
			var tempLightAreas:XML = lightAreas.toXML();
			for (var child in tempLightAreas.children()) {
				newDynalite.appendChild(tempLightAreas.children()[child]);
			}		
			var tempAlarms = alarms.toXML();
			for (var child in tempAlarms.children()) {
				newDynalite.appendChild(tempAlarms.children()[child]);
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
		
		public override function newObject():void {
			super.newObject();
			device_type = "DYNALITE";
			description ="";
			active = "Y";		
				
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
			parameters = new HashMap();		
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
					var fieldName:String = newData.children()[child].name();
					var field:XML = newData.children()[child];
					switch (fieldName) {
						case "DYNALITE" :
						var tempIRs = new XML("<irs />");
						var tempLights = new XML("<lights />");
						var tempContacts = new XML("<contact_closures />");
						var tempLightAreas = new XML("<light_areas />");
						var tempRelays = new XML("<relays />");
						var tempAlarms = new XML("<alarms />");
						var tempNode:XML = newData.children()[child];
						for (var dynaliteDevice:int=0 ; dynaliteDevice < tempNode.children().length() ; dynaliteDevice++) {
							var myNodes:String = tempNode.children()[dynaliteDevice].name();
							switch (myNodes) {
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
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						for (var parameter:int=0; parameter < newData.children()[child].children().length();parameter++) {
							if(newData.children()[child].children()[parameter].@NAME != "PROTOCOL"){
								parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						  	}
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