package Objects.Client {
	import Forms.Client.Property_frm;
	
	import Objects.*;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	
	[Bindable("Property")]
	[RemoteClass(alias="elifeAdmin.objects.client.property")]
	public class Property extends BaseElement {
		[Bindable]
		public var zones:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(zones);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			zones = input.readObject()as ArrayCollection;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (zones.length == 0) {
				flag = "empty";
				appendValidationMsg("No Zones are defined");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.property";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Client.Property_frm;
			return className;		
		}
		
		public override function toXML():XML {
			var newNode:XML = new XML("<property />");
			for (var zone:int = 0; zone < zones.length; zone++) {
				newNode.appendChild(zones[zone].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			for (var zone = 0; zone < zones.length; zone++) {
				newNode.appendChild(zones[zone].toTree());
			}
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Property";
		}
		public override function getName():String {
			return "Property";
		}
		public  function get Data():ObjectProxy {
			return {zones:zones, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			zones = new ArrayCollection();
			if (newData.name() == "property") {
				for (var child:int = 0; child < newData.children().length(); child++) {
					var newZone:Zone = new Zone();
					var zoneXML:XML = newData.zone[child];
					newZone.setXML(zoneXML);
					newZone.id = mx.core.Application.application.formDepth++;
					zones.addItem(newZone);
				}
			} else {
				trace("Error, found " + newData.name() + ", was expecting property");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);
			//Process new zones
			var newZones = new Array();
			for (var index in newData.zones) {
				if (newData.zones[index].id == undefined) {
					newZones.push({name:newData.zones[index].name});
				}
			}
			for (var zone in zones) {
				var found = false;
				for (var index in newData.zones) {
					if (zones[zone].id == newData.zones[index].id) {
						zones[zone].name = newData.zones[index].name;
						found = true;
					}
				}
				if (found == false) {
					zones.removeItemAt(zone);
				}
			} 
			for (var newZone in newZones) {
				var newNode = new XMLNode(1, "zone");
				newNode.attributes["name"] = newZones[newZone].name;
				var newZone = new Objects.Client.Zone();
				newZone.id = Application.application.formDepth++;
				newZone.setXML(newNode);
				zones.addItem(newZone);
			}
			//sort according to desired order
			newZones = new Array();
			for (var newZone = 0; newZone < newData.zones.length; newZone++) {
				for (var zone = 0; zone < zones.length; zone++) {
					if (newData.zones[newZone].name == zones[zone].name) {
						newZones.push(zones[zone]);
					}
				}
			}
			zones = newZones;
			var treeLength = treeNode.childObject.length;
			for(var child = treeLength-1; child > -1;child--){
				treeNode.childObject[child].removeNode();
			}
			for(var zone = 0; zone<zones.length;zone++){
				treeNode.appendChild(zones[zone].toTree());
			}
			//refresh tree
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var zone in zones) {
				usedKeys=usedKeys.concat(zones[zone].getUsedKeys());
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var zone in zones) {
				usedIcons=usedIcons.concat(zones[zone].getIcons());
			}
			return usedIcons;
		}
	}
}