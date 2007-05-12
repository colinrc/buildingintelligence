package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Zone")]
	[RemoteClass(alias="elifeAdmin.objects.client.zone")]
	public class Zone extends BaseElement {
		private var rooms:Array;
		private var panels:Array;
		private var arbitrary:Arbitrary;
		private var name:String;
		public var map:String;
		public var background:String;
		private var cycle:String;
		private var alignment:String;
		private var hideFromList:String;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(rooms);
			output.writeObject(panels);
			output.writeObject(arbitrary);
			output.writeUTF(name);
			output.writeUTF(map);
			output.writeUTF(background);
			output.writeUTF(cycle);
			output.writeUTF(alignment);
			output.writeUTF(hideFromList);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			rooms = input.readObject()as Array;
			panels = input.readObject()as Array;
			arbitrary = input.readObject()as Arbitrary;
			name = input.readUTF() as String;
			map = input.readUTF() as String;
			background = input.readUTF() as String;
			cycle = input.readUTF() as String;
			alignment = input.readUTF() as String;
			hideFromList = input.readUTF() as String;
		}
		
		public function deleteSelf():void {
			treeNode.removeNode();
		}		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (rooms.length == 0) {
				flag = "empty";
				appendValidationMsg("No rooms are defined");
			}
			if (panels.length == 0) {
				flag = "empty";
				appendValidationMsg("No panels are defined");
			}
			
			if (map == null || map == "") {
				flag = "empty";
				appendValidationMsg("Map is missing");
			}
			if (background == null || background == "") {
				flag = "empty";
				appendValidationMsg("Background is missing");
			}
			if (cycle == null || cycle == "") {
				flag = "empty";
				appendValidationMsg("Cycle is missing");
			}
			if (alignment == null || alignment == "") {
				flag = "empty";
				appendValidationMsg("Alignment is missing");
			}
			if (hideFromList == null || hideFromList == "") {
				flag = "empty";
				appendValidationMsg("HideFromList is missing");
			}
			if (name == null || name == "") {
				flag = "warning";
				appendValidationMsg("Name is empty");
			}
			
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.zone";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<zone />");
			if (name != "") {
				newNode.@name = name;
			}
			if (map != "") {
				newNode.@map = map;
			}
			if (background != "") {
				newNode.@background = background;
			}
			if (cycle != "") {
				newNode.@cycle = cycle;
			}
			if (alignment != "") {
				newNode.@alignment = alignment;
			}
			if (hideFromList != "") {
				newNode.@hideFromList = hideFromList;
			}
			newNode.appendChild(arbitrary.toXML());
			var newRooms:XML = new XML("<rooms />");
			for (var room in rooms) {
				newRooms.appendChild(rooms[room].toXML());
			}
			newNode.appendChild(newRooms);
			var newPanels:XML = new XML("<panels />");
			for (var panel in panels) {
				newPanels.appendChild(panels[panel].toXML());
			}
			newNode.appendChild(newPanels);
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			//newNode.appendChild(arbitrary.toTree());
			for (var room in rooms) {
				newNode.appendChild(rooms[room].toTree());
			}
			for (var panel in panels) {
				newNode.appendChild(panels[panel].toTree());
			}
			treeNode = newNode;			
			return newNode;
		}
		public function getKey():String{
			return "Zone";
		}	
		public override function getName():String {
			return "Zone : "+name;
		}
		public override function getData():ObjectProxy {
			return {name:name, map:map, background:background, cycle:cycle, alignment:alignment, hideFromList:hideFromList,dataObject:this};
		}
		public function getPanels():Array{
			return panels;
		}
		public function getRooms():Array{
			return rooms;
		}	
		public function getArbitrary():Object{
			return {items:arbitrary.getItems(),map:map, background:background,dataObject:this};
		}
		public function setArbitraryData(items:Array):void{
			arbitrary.setData({items:items});
		}
		public override function setXML(newData:XML):void {
			rooms = new Array();
			panels = new Array();
			name = "";
			map = "";
			background = "";
			cycle = "";
			alignment = "";
			hideFromList = "";
			
			arbitrary = new Arbitrary();
			
			if (newData.name() == "zone") {
				
				name = newData.attribute("name");
				map = newData.attribute("map");
				background = newData.attribute("background");
				cycle = newData.attribute("cycle");
				alignment = newData.attribute("alignment");
				hideFromList = newData.attribute("hideFromList");
				
				arbitrary.setXML(newData.arbitrary[0]);
				
				var myRooms:XML = newData.rooms[0];
				for (var room:int=0; room< myRooms.children().length();room++) {
					var newRoom:Room = new Room();
					newRoom.setXML(myRooms.room[room]);
					newRoom.id = mx.core.Application.application.formDepth++;
					newRoom.setZone(this);
					rooms.push(newRoom);
				}
				
				var myPanels:XML = newData.panels[0];
				for (var panel:int=0;panel < myPanels.children().length();panel++) {
					var newPanel:Panel = new Panel();
					newPanel.setXML(myPanels.panel[panel]);
					newPanel.id = mx.core.Application.application.formDepth++;						
					panels.push(newPanel);
				}
			} else {
				trace("Error, found "+newData.name()+", was expecting zone");
			}
		}
		public function setPanels(newData:Object):void {
			_global.left_tree.setIsOpen(treeNode, false);		
			var newPanels:Array = new Array();
			for (var index in newData.panels) {
				if (newData.panels[index].id == undefined) {
					newPanels.push({name:newData.panels[index].name});
				}
			}
			var deletedPanels:Array = new Array();
			for (var panel in panels) {
				var found = false;
				for (var index in newData.panels) {
					if (panels[panel].id == newData.panels[index].id) {
						panels[panel].name = newData.panels[index].name;
						found = true;
					}
				}
				if (found == false) {
					panels[panel].deleteSelf();
					panels.splice(parseInt(panel), 1);
				}
			}
			for (var newPanel in newPanels) {
				var newNode:XMLNode = new XMLNode(1, "panel");
				newNode.@name = newPanels[newPanel].name;
				var newPanel = new Objects.Client.Panel();
				newPanel.setXML(newNode);
				newPanel.id = _global.formDepth++;			
				treeNode.appendChild(newPanel.toTree());
				panels.push(newPanel);
			}
			_global.left_tree.setIsOpen(treeNode, true);				
		}
		public function setRooms(newData:Object):void {
			_global.left_tree.setIsOpen(treeNode, false);		
			var newRooms = new Array();
			for (var index in newData.rooms) {
				if (newData.rooms[index].id == undefined) {
					newRooms.push({name:newData.rooms[index].name});
				}
			}
			for (var room in rooms) {
				var found = false;
				for (var index in newData.rooms) {
					if (rooms[room].id == newData.rooms[index].id) {
						rooms[room].name = newData.rooms[index].name;
						found = true;
					}
				}
				if (found == false) {
					rooms[room].deleteSelf();
					rooms.splice(parseInt(room), 1);
				}
			}
			for (var newRoom in newRooms) {
				var newNode = new XMLNode(1, "room");
				newNode.@name = newRooms[newRoom].name;
				var newRoom = new Objects.Client.Room();
				newRoom.setXML(newNode);		
				newRoom.id = _global.formDepth++;	
				newRoom.setZone(this);
				treeNode.appendChild(newRoom.toTree());			
				rooms.push(newRoom);
			}		
			_global.left_tree.setIsOpen(treeNode, true);			
		}
		public override function setData(newData:Object):void {
			name = newData.name;
			map = newData.map;
			background = newData.background;
			cycle = newData.cycle;
			alignment = newData.alignment;
			hideFromList = newData.hideFromList;
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			usedKeys=usedKeys.concat(arbitrary.getUsedKeys());
			for (var room in rooms) {
				usedKeys=usedKeys.concat(rooms[room].getUsedKeys());
			}
			for (var panel in panels) {
				usedKeys=usedKeys.concat(panels[panel].getUsedKeys());
			}
			return usedKeys;
		}
		public function getIcons():Array{
			var usedIcons = new Array();
			usedIcons = usedIcons.concat(arbitrary.getIcons());
			for (var room in rooms) {
				usedIcons = usedIcons.concat(rooms[room].getIcons());
			}
			for (var panel in panels) {
				usedIcons = usedIcons.concat(panels[panel].getIcons());
			}
			return usedIcons;
		}
	}
}