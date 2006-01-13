class Objects.Server.Monitors extends Objects.BaseElement {
	private var container:String;
	private var monitors:Array;
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
		return "forms.project.device.monitor";
	}
	public function toXML():XMLNode {
		var monitorsNode = new XMLNode(1, container);
		for (var monitor in monitors) {
			monitorsNode.appendChild(monitors[monitor]);
		}
		return monitorsNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Monitors";
	}
	public function getData():Object {
		return new Object({monitors:monitors});
	}
	public function setData(newData:Object){
		monitors = newData.monitors;
	}
	public function setXML(newData:XMLNode):Void {
		monitors = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			monitors.push(newData.childNodes[child]);
		}
	}
}
