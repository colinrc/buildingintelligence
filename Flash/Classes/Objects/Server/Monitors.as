class Objects.Server.Monitors extends Objects.BaseElement {
	private var container:String;
	private var monitors:Array;
	private var treeNode:XMLNode;	
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var monitor in monitors) {
			tempKeys.push(monitors[monitor].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var monitor in monitors) {
			if ((monitors[monitor].active != "Y") && (monitors[monitor].active != "N")) {
				flag = "error";
				appendValidationMsg("Active is invalid");
			}
			else {
				if (monitors[monitor].active =="Y"){
					if ((monitors[monitor].name == undefined) || (monitors[monitor].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((monitors[monitor].key == undefined) || (monitors[monitor].key == "")) {
						flag = "error";
						appendValidationMsg("Output no. is empty");
					}
					if ((monitors[monitor].display_name == undefined) || (monitors[monitor].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyUsed(monitors[monitor].display_name) == false) {
							flag = "error";
							appendValidationMsg(monitors[monitor].display_name+" key is not used");
						}
					}
				}
				else {
					if (monitors[monitor].active =="N"){
						flag = "empty";
						appendValidationMsg("Monitors is not active");
					}
				}
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.togglemonitor";
	}
	public function toXML():XMLNode {
		var monitorsNode = new XMLNode(1, container);
		for (var monitor in monitors) {
			var monitorNode = new XMLNode(1, "TOGGLE_OUTPUT_MONITOR");
			if (monitors[monitor].key != "") {
				monitorNode.attributes["KEY"] = monitors[monitor].key;
			}
			if (monitors[monitor].name != "") {
				monitorNode.attributes["NAME"] = monitors[monitor].name;
			}
			if (monitors[monitor].active != "") {
				monitorNode.attributes["ACTIVE"] = monitors[monitor].active;
			}
			if (monitors[monitor].display_name != "") {
				monitorNode.attributes["DISPLAY_NAME"] = monitors[monitor].display_name;
			}
			monitorsNode.appendChild(monitorNode);
		}
		return monitorsNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "Monitors";
	}	
	public function getName():String {
		return "Output Monitors";
	}
	public function getData():Object {
		return {monitors:monitors, dataObject:this};
	}
	public function setData(newData:Object) {
		monitors = newData.monitors;
	}
	public function setXML(newData:XMLNode):Void {
		monitors = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newMonitor = new Object();
			newMonitor.key = "";
			newMonitor.name = "";
			newMonitor.display_name = "";
			newMonitor.active = "Y";
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newMonitor.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newMonitor.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newMonitor.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newMonitor.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			monitors.push(newMonitor);
		}
	}
}
