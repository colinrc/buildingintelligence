class Objects.Server.Alerts extends Objects.BaseElement {
	private var container:String;
	private var alerts:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var alert in alerts){
			tempKeys.push(alerts[alert].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var alert in alerts) {
			if ((alerts[alert].attributes["ACTIVE"] != "Y") && (alerts[alert].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((alerts[alert].attributes["KEY"] == undefined) || (alerts[alert].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((alerts[alert].attributes["NAME"] == undefined) || (alerts[alert].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((alerts[alert].attributes["DISPLAY_NAME"] == undefined) || (alerts[alert].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
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
			alertsNode.appendChild(alerts[alert]);
		}
		return alertsNode;
	}
	public function getName():String {
		return "Comfort Alerts";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,getName());
		newNode.object = this;
		_global.workflow.addNode("Alerts",newNode);
		return newNode;
	}
	public function getData():Object {
		return new Object({alerts:alerts});
	}
	public function setData(newData:Object):Void{
		alerts= newData.alerts;
	}
	public function setXML(newData:XMLNode):Void {
		alerts = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			alerts.push(newData.childNodes[child]);
		}
	}
}
