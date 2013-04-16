package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	import mx.collections.ArrayCollection;
	import Forms.Server.Analogues_frm;
	
	[Bindable("analogues")]
	[RemoteClass(alias="elifeAdmin.objects.server.analogues")]
	public class Analogues extends BaseElement {
		[Bindable]
		public var container:String="";
		[Bindable]
		public var analogues:ArrayCollection;
				
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(analogues);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			analogues = input.readObject()as ArrayCollection;
		}
		
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var analogue in analogues){
				tempKeys.push(analogues[analogue].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var analogue in analogues) {
				if ((analogues[analogue].active != "Y") && (analogues[analogue].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				if ((analogues[analogue].display_name == undefined) || (analogues[analogue].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				} else {
					if (Application.application.isKeyUsed(analogues[analogue].display_name) == false) {
						flag = "error";
						appendValidationMsg(analogues[analogue].display_name+" key is not being used");
					}
				}
				if ((analogues[analogue].key == undefined) || (analogues[analogue].key == "")) {
					flag = "error";
					appendValidationMsg("Input no. is empty");
				}
				if ((analogues[analogue].name == undefined) || (analogues[analogue].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.analogue";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var analoguesNode = new XML("<"+container+" />");
			for (var analogue in analogues) {
				var newAnalogue = new XML("<ANALOG />");
				if (analogues[analogue].key != "") {
					newAnalogue.@KEY = parseInt(analogues[analogue].key).toString(16);
				}
				if (analogues[analogue].name != "") {
					newAnalogue.@NAME = analogues[analogue].name;
				}
				if (analogues[analogue].active != "") {
					newAnalogue.@ACTIVE = analogues[analogue].active;
				}
				if (analogues[analogue].display_name != "") {
					newAnalogue.@DISPLAY_NAME = analogues[analogue].display_name;
				}
				analoguesNode.appendChild(newAnalogue);
			}
			return analoguesNode;
		}
		public override function getName():String {
			return "Analog Inputs";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.Analogues_frm;
			return className;		
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;	
			return newNode;
		}
		public function getKey():String {
			return "Analogues";
		}	
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy( {analogues:analogues, dataObject:this})
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			analogues = newData.analogues;
		}
		public override function setXML(newData:XML):void {
			analogues = new ArrayCollection();
			container = newData.name();
			for (var child in newData.children()) {
				var newAnalogue = new Object();
				newAnalogue.key = "";
				newAnalogue.name = "";
				newAnalogue.display_name = "";
				newAnalogue.active = "Y";			
				if (newData.children()[child].@KEY != undefined) {
					newAnalogue.key = parseInt(newData.children()[child].@KEY,16);
				}
				if (newData.children()[child].@NAME != undefined) {
					newAnalogue.name = newData.children()[child].@NAME;
				}	
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newAnalogue.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newAnalogue.active = newData.children()[child].@ACTIVE;
				}			
				analogues.addItem(newAnalogue);
			}
		}
	}
}