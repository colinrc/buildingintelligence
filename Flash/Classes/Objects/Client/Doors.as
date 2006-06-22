class Objects.Client.Doors extends Objects.BaseElement {
	private var doors:Array;
	var room:Object;
	private var treeNode;
	public function setRoom(inRoom:Object) {
		room = inRoom;
	}	
	public function isValid():String {
		var flag = "ok";
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
				if (_global.isKeyValid(doors[door].attributes["key"]) == false) {
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
	public function getForm():String {
		return "forms.project.client.doors";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "doors");
		for (var door in doors) {
			newNode.appendChild(doors[door]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String{
		return "ClientDoors";
	}
	public function getName():String {
		return "Doors & Windows";
	}
	public function getData():Object {
		return {doors:doors, dataObject:this, poly:room.poly, map:room.zone.map,background:room.zone.background};
	}
	public function setXML(newData:XMLNode):Void {
		doors = new Array();
		if(newData.nodeName == "doors"){
			for(var child in newData.childNodes){
				doors.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting");
		}
	}
	public function setData(newData:Object):Void {
		doors = newData.doors;
	}
	public function getUsedKeys():Array{
		usedKeys = new Array();
		for (var door in doors) {
			if ((doors[door].attributes["key"] != "") && (doors[door].attributes["key"] != undefined)) {
				addUsedKey(doors[door].attributes["key"]);
			}
		}
		return usedKeys;
	}
}