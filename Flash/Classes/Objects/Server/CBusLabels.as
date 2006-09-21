class Objects.Server.CBusLabels extends Objects.BaseElement {
	private var container:String;
	private var labels:Array;
	var treeNode:XMLNode;			
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var label in labels) {
			tempKeys.push(labels[label].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var label in labels) {
			if ((labels[label].active != "Y") && (labels[label].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			
			if (labels[label].active =="Y"){
				if(_global.advanced){
					if ((labels[label].def == undefined) || (labels[label].def == "")) {
						flag = "empty";
						appendValidationMsg("Default is empty");
					}
					if ((labels[label].application == undefined) || (labels[label].application == "")) {
						flag = "empty";
						appendValidationMsg("App. is empty");
					}
				}
				if ((labels[label].display_name == undefined) || (labels[label].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				} else {
					if (_global.isKeyUsed(labels[label].display_name) == false) {
						flag = "error";
						appendValidationMsg(labels[label].display_name+" Key is not used");
					}
				}
				if ((labels[label].name == undefined) || (labels[label].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((labels[label].key == undefined) || (labels[label].key == "")) {
					flag = "error";
					appendValidationMsg("Group Addr. is empty");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("CBUS Dimmers is not Active");
			}
			
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.cbuslabels";
	}
	public function toXML():XMLNode {
		var labelsNode = new XMLNode(1, container);
		for (var label in labels) {
			var newLabel = new XMLNode(1, "LIGHT_CBUS");
			if (labels[label].name != "") {
				newLabel.attributes["NAME"] = labels[label].name;
			}
			if (labels[label].display_name != "") {
				newLabel.attributes["DISPLAY_NAME"] = labels[label].display_name;
			}
			if (labels[label].key != "") {
				newLabel.attributes["KEY"] = labels[label].key;
			}
			if (labels[label].active != "") {
				newLabel.attributes["ACTIVE"] = labels[label].active;
			}
			if (labels[label].def != "") {
				newLabel.attributes["DEFAULT"] = labels[label].def;
			}
			if (labels[label].application != "") {
				newLabel.attributes["CBUS_APPLICATION"] = labels[label].application;
			}
			labelsNode.appendChild(newLabel);
		}
		return labelsNode;
	}
	public function getName():String {
		return "Labels";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "CBusLabels";
	}
	public function setData(newData:Object) {
		labels = newData.labels;
	}
	public function getData():Object {
		return {labels:labels, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		labels = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newLabel = new Object();
			newLabel.name = "";
			newLabel.display_name = "";
			newLabel.key = "";
			newLabel.active = "Y";
			newLabel.def = "";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newLabel.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newLabel.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newLabel.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newLabel.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["DEFAULT"] != undefined) {
				newLabel.def = newData.childNodes[child].attributes["DEFAULT"];
			}
			if (newData.childNodes[child].attributes["CBUS_APPLICATION"] != undefined) {
				newLabel.application = newData.childNodes[child].attributes["CBUS_APPLICATION"];
			}
			labels.push(newLabel);
		}
	}
}
