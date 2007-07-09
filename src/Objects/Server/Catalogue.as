package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Catalogue_frm;
	import mx.collections.ArrayCollection;
	[Bindable("catalogue")]
	[RemoteClass(alias="elifeAdmin.objects.server.catalogue")]
	public class Catalogue extends BaseElement {
		private var name:String="";
		private var items:ArrayCollection;
		public var code:String = "";
		public var val:String = "";
		
		public function initCodeVal():void {
			code = "code";
			val = "value";
			
			switch(name){
				case "Sign Video Inputs":
					code = "Video Device";
					val = "Video Input #";
					break;
				case "HAL Inputs":
				case "Tutondo Inputs":
				case "Kramer Audio Inputs":
				case "Nuvo Audio Inputs":
					code = "Audio Device";
					val =  "Audio Input #";
					break;
				case "Kramer AV Inputs":
					code = "AV Device";
					val =  "AV Input #";
					break;
				case "Tutondo Functions":
				case "HAL Functions":
					code = "Function Name";
					val = "Function Number";
					break;
				default:
					code = "Code";
				  	val = "Value";
					break;
			}
		}
		
		public function deleteSelf(){
			treeNode.removeNode();
		}			
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeObject(items);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF()as String;
			items = input.readObject()as ArrayCollection;
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.Catalogue_frm;
			return className;		
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			var code = "code";
			var val = "value";
			
			switch(name){
				case "Sign Video Inputs":
					code = "Video Device";
					val = "Video Input #";
					break;
				case "HAL Inputs":
				case "Tutondo Inputs":
				case "Kramer Audio Inputs":
				case "Nuvo Audio Inputs":
					code = "Audio Device";
					val =  "Audio Input #";
					break;
				case "Kramer AV Inputs":
					code = "AV Device";
					val =  "AV Input #";
					break;
				case "Tutondo Functions":
				case "HAL Functions":
					code = "Function Name";
					val = "Function Number";
					break;
				default:
					code = "Code";
				  	val = "Value";
					break;
			}
			
			for (var item in items) {
				
				if ((items[item].code == undefined) || (items[item].code == "")) {
					flag = "error";
					appendValidationMsg(code + " is empty");
				}
				if ((items[item].value == undefined) || (items[item].value == "")) {
					flag = "error";
					appendValidationMsg(val + " is empty");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.catalogue";
		}
		public override function toXML():XML {
			var newCatalogue:XML = new XML("<CATALOGUE />");
			if (name != "") {
				newCatalogue.@NAME = name;
			}
			for (var item in items) {
				var newItem:XML = new XML("<ITEM />");
				newItem.@VALUE = items[item].value;
				newItem.@CODE = items[item].code;
				newCatalogue.appendChild(newItem);
			}
			return newCatalogue;
		}
		public override function getName():String {
			return name;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode =newNode;
			return newNode;
		}
		public function getKey():String {
			return "Catalogue";
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			items = newData.items;
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy( {name:name, items:items, code:code, val:val, dataObject:this})
			return ob;
		}
		public override function setXML(newData:XML):void {
			name = "";
			if (newData.attribute("NAME") != undefined) {
				name = newData.attribute("NAME");
			}
			items = new ArrayCollection();
			var len:int = newData.children().length();
			for (var child:int = 0; child < len; child++) {
				items.addItem({"value":newData.children()[child].@VALUE, "code":newData.children()[child].@CODE});
			}
			
			initCodeVal();
			
		}
	}
}