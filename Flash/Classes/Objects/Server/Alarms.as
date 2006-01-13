class Objects.Server.Alarms extends Objects.BaseElement {
	private var container:String;
	private var alarms:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var alarm in alarms) {
			if ((alarms[alarm].attributes["ACTIVE"] != "Y") && (alarms[alarm].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((alarms[alarm].attributes["KEY"] == undefined) || (alarms[alarm].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((alarms[alarm].attributes["NAME"] == undefined) || (alarms[alarm].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((alarms[alarm].attributes["DISPLAY_NAME"] == undefined) || (alarms[alarm].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.alarm";
	}
	public function toXML():XMLNode {
		var alarmsNode = new XMLNode(1, container);
		for (var alarm in alarms) {
			alarmsNode.appendChild(alarms[alarm]);
		}
		return alarmsNode;
	}
	public function getName():String {
		return "Comfort Alarms";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({alarms:alarms});
	}
	public function setData(newData:Object):Void{
		alarms = setData.alarms;
	}
	public function setXML(newData:XMLNode):Void {
		alarms = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			alarms.push(newData.childNodes[child]);
		}
	}
}
