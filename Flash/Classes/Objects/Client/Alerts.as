class Objects.Client.Alerts extends Objects.BaseElement {
	private var x_pos:String;
	private var y_pos:String;
	private var alerts:Array;
	private var treeNode:XMLNode;
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (alerts.length == 0) {
			flag = "error";
			appendValidationMsg("No Alerts are defined");
		}
		for (var alert in alerts) {
			if ((alerts[alert].attributes["name"] == "") || (alerts[alert].attributes["name"] == undefined)) {
				flag = "error";
				appendValidationMsg("Name is invalid");
			}
			//keys is a string comma seperated.
			if ((alerts[alert].attributes["keys"] == "") || (alerts[alert].attributes["keys"] == undefined)) {
				flag = "error";
				appendValidationMsg("No Keys are used");
			}
			else {
				if (_global.isKeyValid(alerts[alert].attributes["keys"]) == false) {
					flag = "error";
					appendValidationMsg(alerts[alert].attributes["keys"]+" Key has changed and is invalid");
				}
			}
			if ((alerts[alert].attributes["icon"] == "") || (alerts[alert].attributes["icon"] == undefined)) {
				flag = "error";
				appendValidationMsg("No Icon is used");
			}
			if ((alerts[alert].attributes["fadeOutTime"] == "") || (alerts[alert].attributes["fadeOutTime"] == undefined)) {
				flag = "empty";
				appendValidationMsg("No Fade Out Time is used");
			}
			
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.alerts";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "alerts");
		if ((x_pos != "") && (x_pos != undefined)) {
			newNode.attributes["x"] = x_pos;
		}
		if ((y_pos != "") && (y_pos != undefined)) {
			newNode.attributes["y"] = y_pos;
		}
		for (var alert in alerts) {
			newNode.appendChild(alerts[alert]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "ClientAlerts";
	}
	public function getName():String {
		var newString = "Alerts";
		if ((x_pos != undefined) && (x_pos != "")) {
			newString += " X:" + x_pos;
		}
		if ((y_pos != undefined) && (y_pos != "")) {
			newString += " Y:" + y_pos;
		}
		return newString;
	}
	public function getData():Object {
		return {x_pos:x_pos, y_pos:y_pos, alerts:alerts, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		if (newData.nodeName == "alerts") {
			alerts = new Array();
			if (newData.attributes["x"] != undefined) {
				x_pos = newData.attributes["x"];
			} else {
				x_pos = "";
			}
			if (newData.attributes["y"] != undefined) {
				y_pos = newData.attributes["y"];
			} else {
				y_pos = "";
			}
			for (var child in newData.childNodes) {
				alerts.push(newData.childNodes[child]);
			}
		} else {
			trace("Error, found " + newData.nodeName + ", was expecting alerts");
		}
	}
	public function setData(newData:Object):Void {
		alerts = newData.alerts;
	}
	public function getUsedKeys():Array{
		usedKeys = new Array();
		for (var alert in alerts) {
			if ((alerts[alert].attributes["keys"] != "") && (alerts[alert].attributes["keys"] != undefined)) {
				addUsedKey(alerts[alert].attributes["keys"]);
			}
		}
		return usedKeys;
	}
	public function getIcons():Array{
		usedIcons = new Array();
		for (var alert in alerts) {
			if ((alerts[alert].attributes["icon"] != "") && (alerts[alert].attributes["icon"] != undefined)) {
				addIcon(alerts[alert].attributes["icon"]);
			}
		}
		return usedIcons;
	}
}
