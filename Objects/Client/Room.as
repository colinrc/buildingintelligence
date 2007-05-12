package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Room")]
	[RemoteClass(alias="elifeAdmin.objects.client.room")]
	public class Room extends BaseElement {
		private var name:String;
		private var poly:String;
		private var switchZone:String;
		private var window:Window;
		private var doors:Doors;
		private var alerts:AlertGroups;
		private var zone:Zone;
		public function Room(){
			name = "";
			poly = "";
			switchZone = "";
			window = new Window();
			var newNode:XML = new XML("<window></window>");
			window.setXML(newNode);
			doors = new Doors();		
			var newNodeDoors:XML = new XML("<doors></doors>");
			doors.setXML(newNodeDoors);
			alerts = new AlertGroups();
			var tempAlertGroups:XML = new XML("<AlertGroups></AlertGroups>");		
			alerts.setXML(tempAlertGroups);		
			alerts.setRoom(this);		
		}
				
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeUTF(poly);
			output.writeUTF(switchZone);
			output.writeObject(window);
			output.writeObject(doors);
			output.writeObject(alerts);
			output.writeObject(zone);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF() as String;
			poly = input.readUTF() as String;
			switchZone = input.readUTF() as String;
			window = input.readObject() as Window;
			doors = input.readObject() as Doors;
			alerts = input.readObject() as AlertGroups;
			zone = input.readObject() as Zone;
		}
		
		public function deleteSelf(){
			treeNode.removeNode();
		}
		public function setZone(inZone:Zone){
			zone = inZone;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			if ((switchZone == "") || (switchZone == undefined)) {
				flag = "ok";
				appendValidationMsg("SwitchZone is empty");
			}
			if ((name == "") || (name == undefined)) {
				flag = "error";
				appendValidationMsg("Name is empty");
			}
			if ((poly == "") || (poly == undefined)) {
				flag = "error";
				appendValidationMsg("Room polygon is invalid");
			}
			
			return flag;
			
		}
		public override function getForm():String {
			return "forms.project.client.room";
		}
		public override function toXML():XML {
			var newNode = new XML("<room />");
			if (name != "") {
				newNode.@name = name;
			}
			if (poly != "") {
				newNode.@poly = poly;
			}
			if ((switchZone != "")&&(switchZone != "None")){
				newNode.@switchZone = switchZone;
			}
			if((switchZone=="")||(switchZone == "None")){
				newNode.appendChild(window.toXML());
			}
			newNode.appendChild(doors.toXML());
			var tempNode = alerts.toXML();
			for (var alertGroup in tempNode.childNodes) {
				newNode.appendChild(tempNode.childNodes[alertGroup]);
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(doors.toTree());
			newNode.appendChild(alerts.toTree());
			if((switchZone=="")||(switchZone == "None")){
				newNode.appendChild(window.toTree());
			}
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String{
			return "ClientRoom";
		}
		public override function getName():String {
			return "Room : "+name;
		}
		public override function getData():ObjectProxy {
			return {name:name, poly:poly, switchZone:switchZone, map:zone.map, background:zone.background, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			var tempAlertGroups:XML = new XML("<AlertGroups></AlertGroups>");		
			if (newData.name() == "room") {
				name = newData.attribute("name");
				poly = newData.attribute("poly");
				switchZone = newData.attribute("switchZone");
				
				for (var child:int =0; child< newData.children().length(); child++) {
					var childRec:XML = newData.children()[child];
					switch (childRec.name()) {
					case "window" :
						window.setXML(newData.childRec);
						break;
					case "doors" :
						doors.setXML(newData.childRec);
						break;
					case "alerts" :
						tempAlertGroups.appendChild(newData.childRec);
						break;
					}
				}
			} else {
				trace("Error, found "+newData.nodeName+", was expecting room");
			}
			alerts.setXML(tempAlertGroups);		
			alerts.setRoom(this);		
			doors.setRoom(this);
		}
		public override function setData(newData:Object):void {
			name = newData.name;
			poly = newData.poly;
			switchZone = newData.switchZone;
			window.deleteSelf();
			if((switchZone=="")||(switchZone == "None")){
				treeNode.appendChild(window.toTree());
			} 
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			usedKeys=usedKeys.concat(window.getUsedKeys());
			usedKeys=usedKeys.concat(doors.getUsedKeys());
			usedKeys=usedKeys.concat(alerts.getUsedKeys());
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			usedIcons=usedIcons.concat(window.getIcons());
			usedIcons=usedIcons.concat(alerts.getIcons());
			return usedIcons;
		}
	}
}