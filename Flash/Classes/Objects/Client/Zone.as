﻿class Objects.Client.Zone extends Objects.BaseElement{
	private var rooms:Array;
	private var arbitrary:Objects.Client.Arbitrary;
	private var name:String;
	private var map:String;
	private var background:String;
	private var cycle:String;
	private var alignment:String;
	private var hideFromList:String;
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.zone";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"zone");
		if(name != ""){
			newNode.attributes["name"] = name;
		}
		if(map != ""){		
			newNode.attributes["map"] = map;
		}
		if(background != ""){				
			newNode.attributes["background"] = background;
		}
		if(cycle != ""){				
			newNode.attributes["cycle"] = cycle;
		}
		if(alignment != ""){				
			newNode.attributes["alignment"] = alignment;
		}
		if(hideFromList != ""){				
			newNode.attributes["hideFromList"] = hideFromList;
		}	
		newNode.appendChild(arbitrary.toXML());
		var newRooms = new XMLNode(1,"rooms");
		for(var room in rooms){
			newRooms.appendChild(rooms[room].toXML());
		}
		newNode.appendChild(newRooms);
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		newNode.appendChild(arbitrary.toTree());
		for(var room in rooms){
			newNode.appendChild(rooms[room].toTree());
		}
		return newNode;
	}
	public function getName():String{
		return "Zone : "+name;
	}
	public function getData():Object{
		return new Object({rooms:rooms,name:name,map:map,background:background,cycle:cycle,alignment:alignment,hideFromList:hideFromList});
	}
	public function setXML(newData:XMLNode):Void{
		rooms = new Array();
		name = "";
		map ="";
		background ="";
		cycle ="";
		alignment = "";
		hideFromList = "";
		arbitrary = new Objects.Client.Arbitrary();
		if(newData.nodeName == "zone"){
			if(newData.attributes["name"] != undefined){
				name = newData.attributes["name"];
			}
			if(newData.attributes["map"] != undefined){
				map = newData.attributes["map"];
			}
			if(newData.attributes["background"] != undefined){
				background = newData.attributes["background"];
			}
			if(newData.attributes["cycle"] != undefined){
				cycle = newData.attributes["cycle"];
			}
			if(newData.attributes["alignment"] != undefined){
				alignment = newData.attributes["alignment"];
			}
			if(newData.attributes["hideFromList"] != undefined){			
				hideFromList = newData.attributes["hideFromList"];
			}
			for(var child in newData.childNodes){
				switch(newData.childNodes[child].nodeName){
					case "arbitrary":
					arbitrary.setXML(newData.childNodes[child]);
					break;
					case "rooms":
					for(var room in newData.childNodes[child].childNodes){
					var newRoom = new Objects.Client.Room();
					newRoom.setXML(newData.childNodes[child].childNodes[room]);
					rooms.push(newRoom);
					}
					break;
				}
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting zone");
		}
	}
	public function setData(newData:Object):Void{
		name = newData.name;
		map = newData.map;
		background = newData.background;
		cycle = newData.cycle;
		alignment = newData.alignment;
		hideFromList = newData.hideFromList;
		//Process rooms changes....
		var newRooms = new Array();
		for (var index in newData.rooms) {
			var found = false;
			for (var room in rooms) {
				if (rooms[room].name == newData.rooms[index].name) {
					found = true;
				}
			}
			if (found == false) {
				newRooms.push({name:newData.rooms[index].name});
			}
		}
		var deletedRooms = new Array();
		for (var room in rooms) {
			var found = false;
			for (var index in newData.rooms) {
				if (rooms[room].name == newData.rooms[index].name) {
					found = true;
				}
			}
			if (found == false) {
				rooms.splice(parseInt(room), 1);
			}
		}
		for (var newRoom in newRooms) {
			var newNode = new XMLNode(1, "room");
			newNode.attributes["name"] = newRooms[newRoom].name;
			var newRoom = new Objects.Client.Room();
			newRoom.setXML(newNode);
			rooms.push(newRoom);
		}
	}
}
