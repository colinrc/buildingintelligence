package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("KeyGroup")]
	[RemoteClass(alias="elifeAdmin.objects.client.keyGroup")]
	public class KeyGroup extends BaseElement {
		public var name:String;
		private var icon1:String;
		private var icon2:String;
		private var type:String;
		private var keys:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeUTF(icon1);
			output.writeUTF(icon2);
			output.writeUTF(type);
			output.writeObject(keys);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF() as String;
			icon1 = input.readUTF() as String;
			icon2 = input.readUTF() as String;
			type = input.readUTF() as String;
			keys = input.readObject()as Array;
		}
		
		public function deleteSelf():void {
			treeNode.removeNode();
		}
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
	/*		if (name == null || name == "") {
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
			if (canOpen == null || canOpen == "") {
			flag = "warning";
			appendValidationMsg("Can Open is missing");
			}
			if (controls.length == 0) {
				flag = "error";
				appendValidationMsg("No Keys are used");
			}
			for (var cont in controls) {
				if (controls[cont].attributes["key"] == null || controls[cont].attributes["key"] == "") {
					flag = "error";
					appendValidationMsg("Key Name is missing");
				} else {
					if (_global.isKeyValid(controls[cont].attributes["key"]) == false) {
						flag = "error";
						appendValidationMsg("Key has changed and is invalid");
					}
				}
			}*/
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.keygroup";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<keygroup />");
			if (name != "") {
				newNode.@name = name;
			}
			if (icon1 != "") {
				newNode.@icon1 = icon1;
			}
			if (icon2 != "") {
				newNode.@icon2 = icon2;
			}
			if (type != "") {
				newNode.@controlType = type;
			}
			for(var key in keys){
				var newKeyNode:XML = new XML("<key />");
				newKeyNode.@name = keys[key];
				newNode.appendChild(newKeyNode);
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
			return "KeyGroup";
		}
		public override function getName():String {
			return "Key Group : " + name;
		}
		public  function get Data():ObjectProxy {
			return {keys:keys, icon1:icon1, name:name, icon2:icon2, type:type, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			keys = newData.keys;
			name = newData.name;
			icon1 = newData.icon1;
			icon2 = newData.icon2;
			type = newData.type;
		}
		public override function setXML(newData:XML):void {
			name = "";
			icon1 = "";
			icon2 = "";
			type = "";
			keys = new Array();
			
			if (newData.name() == "keygroup") {
				name = newData.@name;
				icon1 = newData.@icon1;
				icon2 = newData.@icon2;
				type = newData.@controlType;
				
				for (var child:int =0; child< newData.children().length(); child++) {
					keys.push(newData.children()[child].@name);
				}
			} else {
				trace("Error, received " + newData.name() + ", was expecting keygroup");
			}
		}
	}
}