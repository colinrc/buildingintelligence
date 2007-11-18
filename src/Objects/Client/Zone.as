package Objects.Client {
	import Forms.Client.Arbitrary_frm;
	import Forms.Client.Panels_frm;
	import Forms.Client.Rooms_frm;
	import Forms.Client.Zone_frm;
	
	import Objects.*;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	
	[Bindable("Zone")]
	[RemoteClass(alias="elifeAdmin.objects.client.zone")]
	public class Zone extends BaseElement {
		[Bindable]
		public var rooms:ArrayCollection;
		[Bindable]
		public var panels:ArrayCollection;
		[Bindable]
		public var arbitrary:Arbitrary;
		[Bindable]
		public var name:String="";
		[Bindable]
		public var map:String="";
		[Bindable]
		public var background:String="";
		[Bindable]
		public var cycle:String="";
		[Bindable]
		public var alignment:String="";
		[Bindable]
		public var hideFromList:String="";
		
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
			rooms = input.readObject()as ArrayCollection;
			panels = input.readObject()as ArrayCollection;
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
		
		public function getClassForm():Array {
			var className:Class = Forms.Client.Zone_frm;
			var class2Name:Class = Forms.Client.Rooms_frm;
			var class3Name:Class = Forms.Client.Arbitrary_frm;
			var class4Name:Class = Forms.Client.Panels_frm;	
			return [className,class2Name,class3Name,class4Name];				
		}
		public function getOtherNames():ArrayCollection {
			var tabNames:ArrayCollection = new ArrayCollection();
			tabNames.addItem(getName());
			tabNames.addItem("Rooms");
			tabNames.addItem(arbitrary.getName());
			tabNames.addItem("Panels");
			return tabNames;
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
		public  function get Data():ObjectProxy {
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
			rooms = new ArrayCollection();
			panels = new ArrayCollection();
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
					rooms.addItem(newRoom);
				}
				
				var myPanels:XML = newData.panels[0];
				for (var panel:int=0;panel < myPanels.children().length();panel++) {
					var newPanel:Panel = new Panel();
					newPanel.setXML(myPanels.panel[panel]);
					newPanel.id = mx.core.Application.application.formDepth++;						
					panels.addItem(newPanel);
				}
			} else {
				trace("Error, found "+newData.name()+", was expecting zone");
			}
		}
		public function setPanels(newData:Object):void {
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
					panels.removeItemAt(panel);
				}
			}
			for (var newPanel in newPanels) {
				var newNode:XML = new XML("<panel/>");
				newNode.@name = newPanels[newPanel].name;
				var newPanel:Panel = new Objects.Client.Panel();
				newPanel.setXML(newNode);
				newPanel.id = Application.application.formDepth++;			
				treeNode.appendChild(newPanel.toTree());
				panels.addItem(newPanel);
			}
			//open tree		
		}
		public function setRooms(newData:Object):void {
			//_global.left_tree.setIsOpen(treeNode, false);		
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
					rooms.removeItemAt(room);
				}
			}
			for (var newRoom in newRooms) {
				var newNode:XML = new XML("<room/>");
				newNode.@name = newRooms[newRoom].name;
				var newRoom = new Objects.Client.Room();
				newRoom.setXML(newNode);		
				newRoom.id = Application.application.formDepth++;	
				newRoom.setZone(this);
				treeNode.appendChild(newRoom.toTree());			
				rooms.addItem(newRoom);
			}		
			//_global.left_tree.setIsOpen(treeNode, true);			
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
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