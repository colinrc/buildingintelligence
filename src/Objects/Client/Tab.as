package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Tab")]
	[RemoteClass(alias="elifeAdmin.objects.client.tab")]
	public class Tab extends BaseElement {
		private var controls:Array;
		private var name:String;
		private var icon:String;
		private var attributes:Array;
		private var attributeGroups:Array = ["tabs"];
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(controls);
			output.writeUTF(name);
			output.writeUTF(icon);
			output.writeObject(attributes);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			controls = input.readObject()as Array;
			name = input.readUTF() as String;
			icon = input.readUTF() as String;
			attributes = input.readObject()as Array;
			attributeGroups = input.readObject()as Array;
		}
		
		public function deleteSelf():void {
			treeNode.removeNode();
		}
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (controls.length == 0) {
				flag = "empty";
				appendValidationMsg("No Controls are defined");
			}
			if (name == null || name == "") {
				flag = "warning";
				appendValidationMsg("Name is empty");
			}
			if (icon == null || icon == "") {
				flag = "warning";
				appendValidationMsg("Icon is missing");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.tab";
		}
		public override function toXML():XML {
			var newNode = new XML("<tab />");
			for (var attribute in attributes) {
				newNode.@[attributes[attribute].name] = attributes[attribute].value;
			}
			if (name != "") {
				newNode.@name = name;
			}
			if (icon != "") {
				newNode.@icon = icon;
			}
			for (var control in controls) {
				newNode.appendChild(controls[control]);
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "ClientTab";
		}
		public override function getName():String {
			return "Tab : " + name;
		}
		public  function get Data():ObjectProxy {
			return {controls:controls, name:name, icon:icon, dataObject:this};
		}
		public function getAttributes():Array {
			return attributes;
		}
		public function setAttributes(newAttributes:Array) {
			attributes = newAttributes;
		}
		public override function setXML(newData:XML):void {
			attributes = new Array();
			name = "";
			icon = "";
			if (newData.name() == "tab") {
				
				for (var child:int = 0; child < newData.attributes().length(); child++) {
					var attribute:String = newData.attributes()[child].name();
					switch (attribute) {
					case "name" :
						name = newData.@name;
						break;
					case "icon" :
						icon = newData.@icon;
						break;
					default :
						attributes.push({name:newData.attributes()[child].name(), value:newData.attributes()[child]});
						break;
					}
				}
				controls = new Array();
				for (var child:int =0; child< newData.children().length(); child++) {
					controls.push(newData.children()[child]);
				}
			} else {
				trace("Error, found " + newData.nodeName + ", was expecting tab");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			controls = newData.controls;
			name = newData.name;
			icon = newData.icon;
		}
		public override function getUsedKeys():Array {
			usedKeys = new Array();
			for (var control in controls) {
				if ((controls[control].attributes["key"] != "") && (controls[control].attributes["key"] != undefined)) {
					addUsedKey(controls[control].attributes["key"]);
				}
			}
			return usedKeys;
		}
		public function getIcons():Array {
			usedIcons = new Array();
			if (icon != "" && icon != undefined) {
				addIcon(icon);
			}
			for (var control in controls) {
				if ((controls[control].attributes["icons"] != "") && (controls[control].attributes["icons"] != undefined)) {
					var tempIcons = controls[control].attributes["icons"].split(",");
					for (var tempIcon in tempIcons) {
						if (tempIcons[tempIcon].length) {
							addIcon(tempIcons[tempIcon]);
						}
					}
				}
			}
			return usedIcons;
		}
	}
}