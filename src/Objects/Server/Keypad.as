package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Keypad_frm;
	import mx.collections.ArrayCollection;
	
	[Bindable("keypad")]
	[RemoteClass(alias="elifeAdmin.objects.server.keypad")]
	
	public class Keypad extends BaseElement {
		[Bindable]
		public var container:String ="";
		[Bindable]
		public var keypads:ArrayCollection = new ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(keypads);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			keypads = input.readObject()as ArrayCollection;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var keypad in keypads){
				tempKeys.push(keypads[keypad].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var keypad in keypads) {
				if ((keypads[keypad].active != "Y") && (keypads[keypad].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				if ((keypads[keypad].display_name == undefined) || (keypads[keypad].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				} else {
					if (Application.application.isKeyUsed(keypads[keypad].display_name) == false) {
						flag = "error";
						appendValidationMsg(keypads[keypad].display_name+" key is not being used");
					}
				}
				/*if ((keypads[keypad].key == undefined) || (keypads[keypad].key == "")) {
					flag = "error";
					appendValidationMsg("Input no. is empty");
				}*/
				if ((keypads[keypad].name == undefined) || (keypads[keypad].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.keypad";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var keypadsNode:XML = new XML("<"+container+" />");
			for (var keypad in keypads) {
				var newKeypad:XML = new XML("<KEYPAD />");
				if (keypads[keypad].key != "") {
					newKeypad.@KEY = parseInt(keypads[keypad].key).toString(16);
				}
				if (keypads[keypad].name != "") {
					newKeypad.@NAME = keypads[keypad].name;
				}
				if (keypads[keypad].active != "") {
					newKeypad.@ACTIVE = keypads[keypad].active;
				}
				if (keypads[keypad].display_name != "") {
					newKeypad.@DISPLAY_NAME = keypads[keypad].display_name;
				}
				keypadsNode.appendChild(newKeypad);
			}
			return keypadsNode;
		}
		public override function getName():String {
			return "Keypad";
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;	
			return newNode;
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.Keypad_frm;
			return className;		
		}
		
		public function getKey():String {
			return "Keypad";
		}	
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy( {keypads:keypads, dataObject:this})
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			keypads = newData.keypads;
		}
		public override function setXML(newData:XML):void {
			keypads = new ArrayCollection();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newKeypad = new Object();
				newKeypad.key = "";
				newKeypad.name = "";
				newKeypad.display_name = "";
				newKeypad.active = "Y";			
				if (newData.children()[child].@KEY != undefined) {
					newKeypad.key = parseInt(newData.children()[child].@KEY,16);
				}
				if (newData.children()[child].@NAME != undefined) {
					newKeypad.name = newData.children()[child].@NAME;
				}	
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newKeypad.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newKeypad.active = newData.children()[child].@ACTIVE;
				}			
				keypads.addItem(newKeypad);
			}
		}
	}
}