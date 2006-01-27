class Objects.Client.Room extends Objects.BaseElement {
	private var name:String;
	private var poly:String;
	private var switchZone:String;
	private var window:Objects.Client.Window;
	private var doors:Objects.Client.Doors;
	private var alertGroups:Array;
	public function isValid():Boolean {
		var flag = true;
		if(!window.isValid()){
			flag = false;
		}
		if(!doors.isValid()){
			flag = false;
		}
		for(var alertGroup in alertGroups) {
			if(!alertGroups[alertGroup].isValid()){
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.room";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"room");
		if(name != ""){
			newNode.attributes["name"] = name;
		}
		if(poly != ""){
			newNode.attributes["poly"] = poly;
		}
		if(switchZone != "") {
			newNode.attributes["switchZone"] = switchZone;
		}
		newNode.appendChild(window.toXML());
		newNode.appendChild(doors.toXML());
		for(var alertGroup in alertGroups){
			newNode.appendChild(alertGroups[alertGroup].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.appendChild(window.toTree());
		newNode.appendChild(doors.toTree());
		for(var alertGroup in alertGroups){
			newNode.appendChild(alertGroups[alertGroup].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Room : "+name;
	}
	public function getData():Object{
		return new Object({name:name,poly:poly,switchZone:switchZone,alertGroups:alertGroups});
	}
	public function setXML(newData:XMLNode):Void{
		name = "";
		poly = "";
		switchZone = "";
		if(newData.nodeName == "room") {
			window = new Objects.Client.Window();
			alertGroups = new Array();
			doors = new Objects.Client.Doors();
			if(newData.attributes["name"] != undefined) {
				name = newData.attributes["name"];
			}
			if(newData.attributes["poly"] != undefined) {
				poly = newData.attributes["poly"];
			}
			if(newData.attributes["switchZone"] != undefined) {
				switchZone = newData.attributes["switchZone"];
			}
			for(var child in newData.childNodes){
				switch(newData.childNodes[child].nodeName){
					case "window":
					window.setXML(newData.childNodes[child]);
					break;
					case "doors":
					doors.setXML(newData.childNodes[child]);
					break;
					case "alerts":
					var newAlerts = new Objects.Client.Alerts();
					newAlerts.setXML(newData.childNodes[child]);
					alertGroups.push(newAlerts);
					break;
				}
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting room");
		}
	}
	public function setData(newData:Object):Void{
		name = newData.name;
		poly = newData.poly;
		switchZone = newData.switchZone;
		//process alertGroup changes
		var newAlertGroups = new Array();
		for (var index in newData.alertGroups) {
			var found = false;
			for (var alertGroup in alertGroups) {
				if ((alertGroups[alertGroup].x_pos == newData.alertGroups[index].x_pos)&&(alertGroups[alertGroup].y_pos == newData.alertGroups[index].y_pos)) {
					found = true;
				}
			}
			if (found == false) {
				newAlertGroups.push({x_pos:newData.alertGroups[index].x_pos,y_pos:newData.alertGroups[index].y_pos});
			}
		}
		var deletedAlertGroups = new Array();
		for (var alertGroup in alertGroups) {
			var found = false;
			for (var index in newData.alertGroups) {
				if ((alertGroups[alertGroup].x_pos == newData.alertGroups[index].x_pos)&&(alertGroups[alertGroup].y_pos == newData.alertGroups[index].y_pos)) {
					found = true;
				}
			}
			if (found == false) {
				alertGroups.splice(parseInt(alertGroup), 1);
			}
		}
		for (var newAlertGroup in newAlertGroups) {
			var newNode = new XMLNode(1, "alerts");
			newNode.attributes["x"] = newAlertGroups[newAlertGroup].x_pos;
			newNode.attributes["y"] = newAlertGroups[newAlertGroup].y_pos;
			var newAlertGroup = new Objects.Client.Alerts();
			newAlertGroup.setXML(newNode);
			alertGroups.push(newAlertGroup);
		}
	}
}
