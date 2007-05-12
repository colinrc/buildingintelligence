package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Panel")]
	[RemoteClass(alias="elifeAdmin.objects.client.panel")]
	public class Panel extends BaseElement {
		private var controls:Array;
		private var name:String;
		private var x_pos:String;
		private var y_pos:String;
		private var height:String;
		private var width:String;
		private var attributes:Array;
		private var attributeGroups:Array = ["Window"];
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(controls);
			output.writeUTF(name);
			output.writeUTF(x_pos);
			output.writeUTF(y_pos);
			output.writeUTF(height);
			output.writeUTF(width);
			output.writeObject(attributes);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			controls = input.readObject()as Array;
			name = input.readUTF() as String;
			x_pos = input.readUTF() as String;
			y_pos = input.readUTF() as String;
			height = input.readUTF() as String;
			width = input.readUTF() as String;
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
			if (name == undefined || name == "") {
				flag = "error";
				appendValidationMsg("Name is empty");
			}
			if (x_pos == undefined || x_pos == "") {
				flag = "error";
				appendValidationMsg("X pos is empty");
			}
			if (height == undefined || height == "") {
				flag = "error";
				appendValidationMsg("Heigth is empty");
			}
			if (width == undefined || width == "") {
				flag = "error";
				appendValidationMsg("Width is empty");
			}
			for (var control in controls) {
				if ((controls[control].attributes["name"] == "") || (controls[control].attributes["name"] == undefined)) {
					flag = "error";
					appendValidationMsg("Control Name is empty");
				}
				if ((controls[control].attributes["key"] == "") || (controls[control].attributes["key"] == undefined)) {
					flag = "error";
					appendValidationMsg("No Keys are used");
				} else {
					if (_global.isKeyValid(controls[control].attributes["key"]) == false) {
						flag = "error";
						appendValidationMsg("Key has changed and is invalid");
					}
				}
				if ((controls[control].attributes["type"] == "") || (controls[control].attributes["type"] == undefined)) {
					flag = "error";
					appendValidationMsg("Control Type is invalid");
				}
				if ((controls[control].attributes["icons"] == "") || (controls[control].attributes["icons"] == undefined)) {
					flag = "error";
					appendValidationMsg("Icons are invalid");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.panel";
		}
		public function getAttributes():Array {
			return attributes;
		}
		public function setAttributes(newAttributes:Array) {
			attributes = newAttributes;
		}
		public override function toXML():XML {
			var newNode = new XML("<panel />");
			for (var attribute in attributes) {
				newNode.@[attributes[attribute].name] = attributes[attribute].value;
			}
			if (name != "") {
				newNode.@name = name;
			}
			if (x_pos != "") {
				newNode.@x = x_pos;
			}
			if (y_pos != "") {
				newNode.@y = y_pos;
			}
			if (height != "") {
				newNode.@height = height;
			}
			if (width != "") {
				newNode.@width = width;
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
			return "Panel";
		}
		public override function getName():String {
			return "Panel : " + name;
		}
		public override function getData():ObjectProxy {
			return {controls:controls, name:name, x_pos:x_pos, y_pos:y_pos, width:width, height:height, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			attributes = new Array();
			name = "";
			x_pos = "";
			y_pos = "";
			width = "";
			height = "";
			if (newData.name() == "panel") {
				for (var child:int = 0; child < newData.attributes().length(); child++) {
					var attribute:String = newData.attributes()[child].name();
					switch (attribute) {
					case "name" :
						name = newData.@name;
						break;
					case "x" :
						x_pos = newData.@x;
						break;
					case "y" :
						y_pos = newData.@y;
						break;
					case "width" :
						width = newData.@width;
						break;
					case "height" :
						height = newData.@height;
						break;
					default :
						attributes.push({name:newData.attributes()[child].name(), value:newData.attributes()[child]});
						break;
					}
				}
				controls = new Array();
				for (var child in newData.childNodes) {
					controls.push(newData.childNodes[child]);
				}
			} else {
				trace("Error, found " + newData.nodeName + ", was expecting panel");
			}
		}
		public override function setData(newData:Object):void {
			controls = newData.controls;
			name = newData.name;
			x_pos = newData.x_pos;
			y_pos = newData.y_pos;
			width = newData.width;
			height = newData.height;
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
			for (var control in controls) {
				if ((controls[control].attributes["icons"] != "") && (controls[control].attributes["icons"] != undefined)) {
					addIcon(controls[control].attributes["icons"]);
				}
			}
			return usedIcons;
		}
	}
}