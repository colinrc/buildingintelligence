package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("cBusRelays")]
	[RemoteClass(alias="elifeAdmin.objects.server.cBusRelays")]
	public class CBusRelays extends BaseElement {
		private var container:String;
		private var relays:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(relays);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			relays = input.readObject()as Array;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var relay in relays) {
				tempKeys.push(relays[relay].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var relay in relays) {
				if ((relays[relay].active != "Y") && (relays[relay].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				
				if (relays[relay].active =="Y"){
					if(Application.application.advanced){
						if ((relays[relay].power == undefined) || (relays[relay].power == "")) {
							flag = "empty";
							appendValidationMsg("Power Rating is empty");
						}
						if ((relays[relay].application == undefined) || (relays[relay].application == "")) {
							flag = "empty";
							appendValidationMsg("App. is empty");
						}
					}
					if ((relays[relay].display_name == undefined) || (relays[relay].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					 else {
						if (Application.application.isKeyUsed(relays[relay].display_name) == false) {
							flag = "error";
							appendValidationMsg(relays[relay].display_name+" key is not used");
						}
					}
					if ((relays[relay].name == undefined) || (relays[relay].name == "")) {
						flag = "error";
						appendValidationMsg("Description is invalid");
					}
					
					if ((relays[relay].key == undefined) || (relays[relay].key == "")) {
						flag = "error";
						appendValidationMsg("Group Addr. is empty");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("CBUS Dimmers is not Active");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.cbusrelays";
		}
		public override function toXML():XML {
			var relaysNode:XML = new XML("<"+container+" />");
			for (var relay in relays) {
				var newRelay = new XML("<LIGHT_CBUS />");
				if (relays[relay].name != "") {
					newRelay.@NAME = relays[relay].name;
				}
				if (relays[relay].display_name != "") {
					newRelay.@DISPLAY_NAME = relays[relay].display_name;
				}
				if (relays[relay].key != "") {
					newRelay.@KEY = relays[relay].key;
				}
				if (relays[relay].active != "") {
					newRelay.@ACTIVE = relays[relay].active;
				}
				if (relays[relay].power != "") {
					newRelay.@POWER_RATING = relays[relay].power;
				}
				newRelay.@RELAY = "Y";
				
				if (relays[relay].application != "") {
					newRelay.@CBUS_APPLICATION = relays[relay].application;
				}
				relaysNode.appendChild(newRelay);
			}
			return relaysNode;
		}
		public override function getName():String {
			if(container == "COMFORT"){
				return "CBus Relays";
			} else{
				return "Relays";
			}		
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "CBusRelays";
		}
		public override function setData(newData:Object):void {
			relays = newData.relays;
		}
		public override function getData():ObjectProxy {
			return {relays:relays, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			relays = new Array();
			container = newData.name();
			for (var child in newData.children()) {
				var newRelay = new Object();
				newRelay.name = "";
				newRelay.display_name = "";
				newRelay.key = "";
				newRelay.active = "Y";
				newRelay.power = "";
				newRelay.application = "38";
				if (newData.children()[child].@NAME != undefined) {
					newRelay.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newRelay.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newRelay.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newRelay.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@POWER_RATING != undefined) {
					newRelay.power = newData.children()[child].@POWER_RATING;
				}
				if (newData.children()[child].@CBUS_APPLICATION != undefined) {
					newRelay.application = newData.children()[child].@CBUS_APPLICATION;
				}
				relays.push(newRelay);
			}
		}
	}
}