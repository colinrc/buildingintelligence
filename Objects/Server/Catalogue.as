package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("catalogue")]
	[RemoteClass(alias="elifeAdmin.objects.server.catalogue")]
	public class Catalogue extends BaseElement {
		private var name:String;
		private var items:Array;
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
			items = input.readObject()as Array;
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
				
				if ((items[item].attributes["CODE"] == undefined) || (items[item].attributes["CODE"] == "")) {
					flag = "error";
					appendValidationMsg(code + " is empty");
				}
				if ((items[item].attributes["VALUE"] == undefined) || (items[item].attributes["VALUE"] == "")) {
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
			var newCatalogue = new XML("<CATALOGUE />");
			if (name != "") {
				newCatalogue.@NAME = name;
			}
			for (var item in items) {
				newCatalogue.appendChild(items[item]);
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
		public override function setData(newData:Object):void {
			items = newData.items;
		}
		public override function getData():ObjectProxy {
			return {name:name, items:items, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			name = "";
			if (newData.attribute("NAME") != undefined) {
				name = newData.attribute("NAME");
			}
			items = new Array();
			var len:int = newData.children().length();
			for (var child:int = 0; child < len; child++) {
				items.push(newData.children()[child]);
			}
			
		}
	}
}