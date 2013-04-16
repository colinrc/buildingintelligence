package Objects.Client {
	import Forms.Client.KeyGroup_frm;
	
	import Objects.*;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	[Bindable("KeyGroup")]
	[RemoteClass(alias="elifeAdmin.objects.client.keyGroup")]
	public class KeyGroup extends BaseElement {
		[Bindable]
		public var name:String="";
		[Bindable]
		public var icon1:Object = new Object();
		[Bindable]
		public var icon2:Object = new Object();
		[Bindable]
		public var myType:String="";
		[Bindable]
		public var keys:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeObject(icon1);
			output.writeObject(icon2);
			output.writeUTF(myType);
			output.writeObject(keys);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF() as String;
			icon1 = input.readObject() as Object;
			icon2 = input.readObject() as Object;
			myType = input.readUTF() as String;
			keys = input.readObject()as ArrayCollection;
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
		public function getClassForm():Class {
			var className:Class = Forms.Client.KeyGroup_frm;
			return className;		
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<keygroup />");
			if (name != "") {
				newNode.@name = name;
			}
			if (icon1 != null&&icon1.name != "") {
				newNode.@icon1 = icon1.name;
			}
			if (icon2!=null&&icon2.name != "") {
				newNode.@icon2 = icon2.name;
			}
			if (myType != "") {
				newNode.@controlType = myType;
			}
			for(var key in keys){
				var newKeyNode:XML = new XML("<key />");
				newKeyNode.@name = keys[key].name.toString();
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
			return {keys:keys, icon1:icon1, name:name, icon2:icon2, myType:myType, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			keys = newData.keys;
			name = newData.name;
			icon1 = newData.icon1;
			icon2 = newData.icon2;
			myType = newData.myType;
		}
		public override function setXML(newData:XML):void {
			name = "";
			icon1 = new Object();
			icon2 = new Object();
			myType = "";
			keys = new ArrayCollection();
			
			if (newData.name() == "keygroup") {
				name = newData.@name;
				icon1.name = newData.@icon1;
				icon2.name = newData.@icon2;
				myType = newData.@controlType;
				
				for (var child:int =0; child< newData.children().length(); child++) {
					keys.addItem({name:newData.children()[child].@name.toString()});
				}
			} else {
				trace("Error, received " + newData.name() + ", was expecting keygroup");
			}
		}
	}
}