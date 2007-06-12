package Objects.Client {
	import Objects.BaseElement;
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("CalendarTab")]
	[RemoteClass(alias="elifeAdmin.objects.client.calendarTab")]
	public class CalendarTab extends BaseElement {
		private var zones:Array;
		private var label:String;
		private var icon:String;
		private var view:String;
		private var macro:String;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(zones);
			output.writeUTF(label);
			output.writeUTF(icon);
			output.writeUTF(view);
			output.writeUTF(macro);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			zones = input.readObject()as Array;
			label = input.readUTF()as String;
			icon = input.readUTF()as String;
			view = input.readUTF()as String;
			macro = input.readUTF()as String;	
		}
		
		
		public function deleteSelf(){
			treeNode.removeNode();
		}		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			if (zones.length == 0) {
				flag = "empty";
				appendValidationMsg("No Zones are defined");
			}
			if (label == null || label == "") {
				flag = "warning";
				appendValidationMsg("Label is missing");
			}
			if (icon == null || icon == "") {
				flag = "warning";
				appendValidationMsg("Icon is missing");
			}
			if (view == null || view == "") {
				flag = "warning";
				appendValidationMsg("View is missing");
			}
			if (macro == null || macro == "") {
				flag = "warning";
				appendValidationMsg("Macro is missing");
			}
			for (var zone in zones) {
				if (zones[zone].attributes["label"] == null || zones[zone].attributes["label"] == "") {
					flag = "warning";
					appendValidationMsg("Zone Name is empty");
				}
				if (zones[zone].attributes["key"] == null || zones[zone].attributes["key"] == "") {
					flag = "error";
					appendValidationMsg("Zone Key is missing");
				}
				else {
					if (_global.isKeyValid(zones[zone].attributes["key"]) == false) {
						flag = "error";
						appendValidationMsg("Key has changed and is invalid");
					}
				}
			}
			
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.calendartab";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<tab />");
			if(label != "") {
				newNode.@label = label;
			}
			if(icon != "") {
				newNode.@icon = icon;
			}
			if(view != "") {
				newNode.@view = view;
			}
			if(macro !=""){
				newNode.@macro = macro;
			}
			for (var zone in zones) {
				newNode.appendChild(zones[zone]);
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String{
			return "Calendar_Tab";
		}
		public override function getName():String {
			return label;
		}
		public  function get Data():ObjectProxy {
			return {zones:zones, label:label, icon:icon, view:view, macro:macro, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			label = "";
			icon = "";
			view = "";
			macro = "";
			zones = new Array();		
			if(newData.name() == "tab"){
				label = newData.attribute("label");
				icon = newData.attribute("icon");
				view = newData.attribute("view");
				macro = newData.attribute("macro");
				
				for (var child:int =0; child< newData.children().length(); child++) {
					zones.push(newData.children()[child]);
				}
			}
			else{
				trace("Error, found "+newData.name()+", was expecting tab");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			zones = newData.zones;
			label = newData.label;
			icon = newData.icon;
			macro = newData.macro;
			view = newData.view;
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var zone in zones) {
				if ((zones[zone].attributes["keys"] != "") && (zones[zone].attributes["keys"] != undefined)) {
					addUsedKey(zones[zone].attributes["keys"]);
				}
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var zone in zones) {
				if ((zones[zone].attributes["icon"] != "") && (zones[zone].attributes["icon"] != undefined)) {
					addIcon(zones[zone].attributes["icon"]);
				}
			}
			return usedIcons;
		}
	}
}