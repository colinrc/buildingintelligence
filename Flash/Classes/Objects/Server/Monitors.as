class Objects.Server.Monitors extends Objects.BaseElement {
	private var container:String;
	private var monitors:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var monitor in monitors) {
			tempKeys.push(monitors[monitor].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var monitor in monitors) {
			if ((monitors[monitor].attributes["ACTIVE"] != "Y") && (monitors[monitor].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((monitors[monitor].attributes["KEY"] == undefined) || (monitors[monitor].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((monitors[monitor].attributes["NAME"] == undefined) || (monitors[monitor].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((monitors[monitor].attributes["DISPLAY_NAME"] == undefined) || (monitors[monitor].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
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
		_global.workflow.addNode("Monitors", newNode);
		return newNode;
	}
	public function getName():String {
		return "Monitors";
	}
	public function getData():Object {
		return new Object({monitors:monitors});
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
