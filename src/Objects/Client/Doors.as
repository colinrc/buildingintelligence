package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Doors")]
	[RemoteClass(alias="elifeAdmin.objects.client.doors")]
	public class Doors extends BaseElement {
		private var doors:Array;
		public var room:Object;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(doors);
			output.writeObject(room);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			doors = input.readObject() as Array;
			room = input.readObject()as Object;
		}
		
		public function setRoom(inRoom:Object):void {
			room = inRoom;
		}	
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			for (var door in doors) {
				if((doors[door].attributes["name"] == "")||(doors[door].attributes["name"] == undefined)){
					flag = "empty";
					appendValidationMsg("Name is empty");
				}
				if((doors[door].attributes["key"] == "")||(doors[door].attributes["key"] == undefined)){
					flag = "error";
					appendValidationMsg("Key is invalid");
				} else {
					if (Application.application.isKeyValid(doors[door].attributes["key"]) == false) {
						flag = "error";
						appendValidationMsg("Key has changed and is invalid");
					}
				}
				if((doors[door].attributes["colour1"] == "")||(doors[door].attributes["colour1"] == undefined) || (doors[door].attributes["colour2"] == "")||(doors[door].attributes["colour2"] == undefined)){
					flag = "error";
					appendValidationMsg("Colour is invalid");
				}			
				if((doors[door].attributes["pos"] == "")||(doors[door].attributes["pos"] == undefined)){
					flag = "error";
					appendValidationMsg("Door polygon is invalid");
				}		
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.doors";
		}
		public override function toXML():XML {
			var newNode = new XML("<doors />");
			for (var door in doors) {
				newNode.appendChild(doors[door]);
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String{
			return "ClientDoors";
		}
		public override function getName():String {
			return "Doors \& Windows";
		}
		public  function get Data():ObjectProxy {
			return {doors:doors, dataObject:this, poly:room.poly, map:room.zone.map,background:room.zone.background};
		}
		public override function setXML(newData:XML):void {
			doors = new Array();
			if(newData.name() == "doors"){
				for (var child:int =0; child< newData.children().length(); child++) {
					doors.push(newData.children()[child]);
				}
			}
			else{
				trace("Error, found "+newData.name()+", was expecting");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			doors = newData.doors;
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var door in doors) {
				if ((doors[door].attributes["key"] != "") && (doors[door].attributes["key"] != undefined)) {
					addUsedKey(doors[door].attributes["key"]);
				}
			}
			return usedKeys;
		}
	}
}