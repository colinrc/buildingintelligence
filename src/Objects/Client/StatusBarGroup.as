package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	
	[Bindable("StatusBarGroup")]
	[RemoteClass(alias="elifeAdmin.objects.client.statusBarGroup")]
	public class StatusBarGroup extends BaseElement {
		private var name:String="";
		private var icon:String="";
		private var show:String="";
		private var hide:String="";
		private var controls:Array;
		private var attributes:Array;
		private var canOpen:String="";
		private var attributeGroups:Array = ["window"];
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeUTF(icon);
			output.writeUTF(show);
			output.writeUTF(hide);
			output.writeObject(controls);
			output.writeObject(attributes);
			output.writeUTF(canOpen);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			
			name = input.readUTF() as String;
			icon = input.readUTF() as String;
			show = input.readUTF() as String;
			hide = input.readUTF() as String;
			controls = input.readObject()as Array;
			attributes = input.readObject()as Array;
			canOpen = input.readUTF() as String;
			attributeGroups = input.readObject()as Array;
		}
		
		public function deleteSelf():void {
			treeNode.removeNode();
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			if (name == null || name == "") {
				flag = "warning";
				appendValidationMsg("Name is empty");
			}
			if (icon == null || icon == "") {
				flag = "warning";
				appendValidationMsg("Icon is missing");
			}
			if (show == null || show == "") {
				flag = "warning";
				appendValidationMsg("Show is empty");
			}
			if (hide == null || hide == "") {
				flag = "warning";
				appendValidationMsg("Hide is empty");
			}
			/*if (canOpen == null || canOpen == "") {
			flag = "warning";
			appendValidationMsg("Can Open is missing");
			}*/ 
			if (controls.length == 0) {
				flag = "error";
				appendValidationMsg("No Keys are used");
			}
			for (var cont in controls) {
				if (controls[cont].attributes["key"] == null || controls[cont].attributes["key"] == "") {
					flag = "error";
					appendValidationMsg("Key Name is missing");
				} else {
					if (Application.application.isKeyValid(controls[cont].attributes["key"]) == false) {
						flag = "error";
						appendValidationMsg("Key has changed and is invalid");
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.statusbargroup";
		}
		public override function toXML():XML {
			var newNode = new XML("<group />");
			if (name != "") {
				newNode.@name = name;
			}
			if (icon != "") {
				newNode.@icon = icon;
			}
			if (show != "") {
				newNode.@show = show;
			}
			if (hide != "") {
				newNode.@hide = hide;
			}
			newNode.@canOpen = canOpen;
			for (var attribute in attributes) {
				newNode.@[attributes[attribute].name] = attributes[attribute].value;
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
			return "StatusBarGroup";
		}
		public override function getName():String {
			return "Group: " + name;
		}
		public  function get Data():ObjectProxy {
			return {controls:controls, icon:icon, name:name, show:show, hide:hide, canOpen:canOpen, dataObject:this};
		}
		public function getAttributes():Array {
			return attributes;
		}
		public function setAttributes(newAttributes:Array) {
			attributes = newAttributes;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			controls = newData.controls;
			name = newData.name;
			icon = newData.icon;
			show = newData.show;
			hide = newData.hide;
			canOpen = newData.canOpen;
		}
		public override function setXML(newData:XML):void {
			name = "";
			icon = "";
			show = "";
			hide = "";
			canOpen = "";
			controls = new Array();
			attributes = new Array();
			if (newData.name() == "group") {
				for (var child:int = 0; child < newData.attributes().length(); child++) {
					var attribute:String = newData.attributes()[child].name();
					switch (attribute) {
					case "name" :
						name = newData.@name;
						break;
					case "icon" :
						icon = newData.@icon;
						break;
					case "show" :
						show = newData.@show;
						break;
					case "hide" :
						hide = newData.@hide;
						break;
					case "canOpen" :
						canOpen = newData.@canOpen;
						break;
					default :
						attributes.push({name:newData.attributes()[child].name(), value:newData.attributes()[child]});
						break;
					}
				}
				for (var child:int =0; child< newData.children().length(); child++) {
					controls.push(newData.children()[child]);
				}
			} else {
				trace("Error, received " + newData.nodeName + ", was expecting group");
			}
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
			return usedIcons;
		}
	}
}