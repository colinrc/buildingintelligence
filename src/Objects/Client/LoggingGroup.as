package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("LoggingGroup")]
	[RemoteClass(alias="elifeAdmin.objects.client.loggingGroup")]
	public class LoggingGroup extends BaseElement {
		private var name:String="";
		private var icon:String="";
		private var type:String="";
		private var listenTo:String="";
		private var controls:Array;
		private var attributes:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeUTF(icon);
			output.writeUTF(type);
			output.writeUTF(listenTo);
			output.writeObject(controls);
			output.writeObject(attributes);
			
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF() as String;
			icon = input.readUTF() as String;
			type = input.readUTF() as String;
			listenTo = input.readUTF() as String;
			controls = input.readObject()as Array;
			attributes = input.readObject()as Array;
			
		}
		
		public function deleteSelf() {
			treeNode.removeNode();
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			if (controls.length == 0) {
				flag = "empty";
				appendValidationMsg("No Keys are being used");
			}
			if ((listenTo == undefined) || (listenTo == "")) {
				flag = "empty";
				appendValidationMsg("Listen to is empty");
			}
			if ((name == undefined) || (name == "")) {
				flag = "warning";
				appendValidationMsg("Name is empty");
			}
			if ((icon == undefined) || (icon == "")) {
				flag = "warning";
				appendValidationMsg("Icon is invalid");
			}
			if ((type == undefined) || (type == "")) {
				flag = "warning";
				appendValidationMsg("Type is invalid");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.logginggroup";
		}
		public override function toXML():XML {
			var newNode = new XML("<group />");
			if (name != "") {
				newNode.@name = name;
			}
			if (icon != "") {
				newNode.@icon = icon;
			}
			if (type != "") {
				newNode.@type = type;
			}
			if (listenTo != "") {
				newNode.@listenTo = listenTo;
			}
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
			return "LoggingGroup";
		}
		public override function getName():String {
			return "Group: " + name;
		}
		public  function get Data():ObjectProxy {
			return {controls:controls, icon:icon, name:name, listenTo:listenTo, type:type, attributes:attributes, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			controls = newData.controls;
			name = newData.name;
			icon = newData.icon;
			listenTo = newData.listenTo;
			type = newData.type;
			attributes = newData.attributes;
		}
		public override function setXML(newData:XML):void {
			name = "";
			icon = "";
			listenTo = "";
			type = "";
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
					case "listenTo" :
						listenTo = newData.@listenTo;
						break;
					case "type" :
						type = newData.@type;
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
				trace("Error, received " + newData.name() + ", was expecting group");
			}
		}
		public override function getUsedKeys():Array {
			usedKeys = new Array();
			for (var cont in controls) {
				if ((controls[cont].attributes["key"] != "") && (controls[cont].attributes["key"] != undefined)) {
					addUsedKey(controls[cont].attributes["key"]);
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