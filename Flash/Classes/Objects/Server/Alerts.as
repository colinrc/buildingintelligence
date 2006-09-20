﻿class Objects.Server.Alerts extends Objects.BaseElement {
	private var container:String;
	private var alerts:Array;
	var treeNode:XMLNode;
	public function getKeys():Array {
		var tempKeys = new Array();
/*		for (var alert in alerts) {
			tempKeys.push(alerts[alert].display_name);
		}*/
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (alerts.length == 0) {
			flag = "empty";
			appendValidationMsg("No Alerts are defined");
		}
		for (var alert in alerts) {
			
/*			if ((alerts[alert].cat == undefined) || (alerts[alert].cat == "")) {
				flag = "warning";
				appendValidationMsg("Client Catagory is empty");
			} */
			if ((alerts[alert].message == undefined) || (alerts[alert].message == "")) {
				flag = "warning";
				appendValidationMsg("Message is empty");
			} 
			if ((alerts[alert].type == undefined) || (alerts[alert].type == "")) {
				flag = "warning";
				appendValidationMsg("Alert Type has not been selected");
			} 
			
			if ((alerts[alert].active != "Y") && (alerts[alert].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			if ((alerts[alert].display_name == undefined) || (alerts[alert].display_name == "")) {
				flag = "error";
				appendValidationMsg("Key is invalid");
			} else {
				if (_global.isKeyUsed(alerts[alert].display_name) == false) {
					flag = "error";
					appendValidationMsg(alerts[alert].display_name+" key is not being used");
				}
			}
			if ((alerts[alert].key == undefined) || (alerts[alert].key == "")) {
				flag = "error";
				appendValidationMsg("Comfort Code is empty");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.alert";
	}
	public function toXML():XMLNode {
		var alertsNode = new XMLNode(1, container);
		for (var alert in alerts) {
			var alertNode = new XMLNode(1, "ALERT");
			if (alerts[alert].key != "") {
				alertNode.attributes["KEY"] = parseInt(alerts[alert].key).toString(16);
			}
			if (alerts[alert].display_name != "") {
				alertNode.attributes["DISPLAY_NAME"] = alerts[alert].display_name;
			}
			if (alerts[alert].active != "") {
				alertNode.attributes["ACTIVE"] = alerts[alert].active;
			}
			if (alerts[alert].cat != "") {
				alertNode.attributes["CLIENT_CAT"] = alerts[alert].cat;
			}
			if (alerts[alert].message != "") {
				alertNode.attributes["MESSAGE"] = alerts[alert].message;
			}
			if (alerts[alert].type != "") {
				alertNode.attributes["ALERT_TYPE"] = alerts[alert].type;
			}
			alertsNode.appendChild(alertNode);
		}
		return alertsNode;
	}
	public function getName():String {
		return "Comfort Alerts";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, getName());
		newNode.object = this;
		treeNode = newNode;			
		return newNode;
	}
	public function getKey():String {
		return "Alerts";
	}
	public function getData():Object {
		return {alerts:alerts, dataObject:this};
	}
	public function setData(newData:Object):Void {
		alerts = newData.alerts;
	}
	public function setXML(newData:XMLNode):Void {
		alerts = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newAlert = new Object();
			newAlert.key = "";
			newAlert.display_name = "";
			newAlert.message = "";
			newAlert.active = "Y";
			newAlert.type = "";
			newAlert.cat = "";
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newAlert.key = parseInt(newData.childNodes[child].attributes["KEY"],16);
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newAlert.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["CLIENT_CAT"] != undefined) {
				newAlert.cat = newData.childNodes[child].attributes["CLIENT_CAT"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newAlert.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["MESSAGE"] != undefined) {
				newAlert.message = newData.childNodes[child].attributes["MESSAGE"];
			}
			if (newData.childNodes[child].attributes["ALERT_TYPE"] != undefined) {
				newAlert.type = newData.childNodes[child].attributes["ALERT_TYPE"];
			}
			alerts.push(newAlert);
		}
	}
}
