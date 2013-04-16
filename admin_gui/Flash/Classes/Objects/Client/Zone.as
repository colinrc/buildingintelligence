class Objects.Client.Zone extends Objects.BaseElement {
	private var rooms:Array;
	private var panels:Array;
	private var arbitrary:Objects.Client.Arbitrary;
	private var name:String;
	public var map:String;
	public var background:String;
	private var cycle:String;
	private var alignment:String;
	private var hideFromList:String;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		treeNode.removeNode();
	}		
	public function isValid():String {
		var flag = "ok";
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
	public function getForm():String {
		return "forms.project.client.zone";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "zone");
		if (name != "") {
			newNode.attributes["name"] = name;
		}
		if (map != "") {
			newNode.attributes["map"] = map;
		}
		if (background != "") {
			newNode.attributes["background"] = background;
		}
		if (cycle != "") {
			newNode.attributes["cycle"] = cycle;
		}
		if (alignment != "") {
			newNode.attributes["alignment"] = alignment;
		}
		if (hideFromList != "") {
			newNode.attributes["hideFromList"] = hideFromList;
		}
		newNode.appendChild(arbitrary.toXML());
		var newRooms = new XMLNode(1, "rooms");
		for (var room in rooms) {
			newRooms.appendChild(rooms[room].toXML());
		}
		newNode.appendChild(newRooms);
		var newPanels = new XMLNode(1, "panels");
		for (var panel in panels) {
			newPanels.appendChild(panels[panel].toXML());
		}
		newNode.appendChild(newPanels);
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Zone");
		newNode.object = this;
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
	public function getName():String {
		return "Zone : "+name;
	}
	public function getData():Object {
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
	public function setArbitraryData(items:Array):Void{
		arbitrary.setData({items:items});
	}
	public function setXML(newData:XMLNode):Void {
		rooms = new Array();
		panels = new Array();
		name = "";
		map = "";
		background = "";
		cycle = "";
		alignment = "";
		hideFromList = "";
		arbitrary = new Objects.Client.Arbitrary();
		if (newData.nodeName == "zone") {
			if (newData.attributes["name"] != undefined) {
				name = newData.attributes["name"];
			}
			if (newData.attributes["map"] != undefined) {
				map = newData.attributes["map"];
			}
			if (newData.attributes["background"] != undefined) {
				background = newData.attributes["background"];
			}
			if (newData.attributes["cycle"] != undefined) {
				cycle = newData.attributes["cycle"];
			}
			if (newData.attributes["alignment"] != undefined) {
				alignment = newData.attributes["alignment"];
			}
			if (newData.attributes["hideFromList"] != undefined) {
				hideFromList = newData.attributes["hideFromList"];
			}
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "arbitrary" :
					arbitrary.setXML(newData.childNodes[child]);
					break;
				case "rooms" :
					for (var room in newData.childNodes[child].childNodes) {
						var newRoom = new Objects.Client.Room();
						newRoom.setXML(newData.childNodes[child].childNodes[room]);
						newRoom.id = _global.formDepth++;
						newRoom.setZone(this);
						rooms.push(newRoom);
					}
					break;
				case "panels" :
					for (var panel in newData.childNodes[child].childNodes) {
						var newPanel = new Objects.Client.Panel();
						newPanel.setXML(newData.childNodes[child].childNodes[panel]);
						newPanel.id = _global.formDepth++;						
						panels.push(newPanel);
					}
					break;
				}
			}
		} else {
			trace("Error, found "+newData.nodeName+", was expecting zone");
		}
	}
	public function setPanels(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);		
		var newPanels = new Array();
		for (var index in newData.panels) {
			if (newData.panels[index].id == undefined) {
				newPanels.push({name:newData.panels[index].name});
			}
		}
		var deletedPanels = new Array();
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
			var newNode = new XMLNode(1, "panel");
			newNode.attributes["name"] = newPanels[newPanel].name;
			var newPanel = new Objects.Client.Panel();
			newPanel.setXML(newNode);
			newPanel.id = _global.formDepth++;			
			treeNode.appendChild(newPanel.toTree());
			panels.push(newPanel);
		}
		_global.left_tree.setIsOpen(treeNode, true);				
	}
	public function setRooms(newData:Object):Void {
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
			newNode.attributes["name"] = newRooms[newRoom].name;
			var newRoom = new Objects.Client.Room();
			newRoom.setXML(newNode);		
			newRoom.id = _global.formDepth++;	
			newRoom.setZone(this);
			treeNode.appendChild(newRoom.toTree());			
			rooms.push(newRoom);
		}		
		_global.left_tree.setIsOpen(treeNode, true);			
	}
	public function setData(newData:Object):Void {
		name = newData.name;
		map = newData.map;
		background = newData.background;
		cycle = newData.cycle;
		alignment = newData.alignment;
		hideFromList = newData.hideFromList;
	}
	public function getUsedKeys():Array{
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
