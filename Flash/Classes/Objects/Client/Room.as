class Objects.Client.Room extends Objects.BaseElement {
	private var name:String;
	private var poly:String;
	private var switchZone:String;
	private var window:Objects.Client.Window;
	private var doors:Objects.Client.Doors;
	private var alerts:Objects.Client.AlertGroups;
	public function isValid():Boolean {
		var flag = true;
		if (!window.isValid()) {
			flag = false;
		}
		if (!doors.isValid()) {
			flag = false;
		}
		if (!alerts.isValid()) {
			flag = false;
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.room";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "room");
		if (name != "") {
			newNode.attributes["name"] = name;
		}
		if (poly != "") {
			newNode.attributes["poly"] = poly;
		}
		if ((switchZone != "")&&(switchZone != "None")){
			newNode.attributes["switchZone"] = switchZone;
		}
		newNode.appendChild(window.toXML());
		newNode.appendChild(doors.toXML());
		var tempNode = alerts.toXML();
		for (var alertGroup in tempNode.childNodes) {
			newNode.appendChild(tempNode.childNodes[alertGroup]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Room");
		newNode.appendChild(window.toTree());
		newNode.appendChild(doors.toTree());
		newNode.appendChild(alerts.toTree());
		newNode.object = this;
		_global.workflow.addNode("ClientRoom",newNode);
		return newNode;
	}
	public function getName():String {
		return "Room : "+name;
	}
	public function getData():Object {
		return new Object({name:name, poly:poly, switchZone:switchZone});
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		poly = "";
		switchZone = "";
		if (newData.nodeName == "room") {
			alerts = new Objects.Client.AlertGroups();
			var tempAlertGroups = new XMLNode(1, "AlertGroups");
			window = new Objects.Client.Window();
			doors = new Objects.Client.Doors();
			if (newData.attributes["name"] != undefined) {
				name = newData.attributes["name"];
			}
			if (newData.attributes["poly"] != undefined) {
				poly = newData.attributes["poly"];
			}
			if (newData.attributes["switchZone"] != undefined) {
				switchZone = newData.attributes["switchZone"];
			}
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "window" :
					window.setXML(newData.childNodes[child]);
					break;
				case "doors" :
					doors.setXML(newData.childNodes[child]);
					break;
				case "alerts" :
					tempAlertGroups.appendChild(newData.childNodes[child]);
					break;
				}
			}
			alerts.setXML(tempAlertGroups);
		} else {
			trace("Error, found "+newData.nodeName+", was expecting room");
		}
	}
	public function setData(newData:Object):Void {
		name = newData.name;
		poly = newData.poly;
		switchZone = newData.switchZone;
	}
}
