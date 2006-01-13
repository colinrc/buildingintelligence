class Objects.Server.CBusSensors extends Objects.BaseElement {
	private var container:String;
	private var sensors:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var sensor in sensors) {
			if ((sensors[sensor].attributes["ACTIVE"] != "Y") && (sensors[sensor].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((sensors[sensor].attributes["KEY"] == undefined) || (sensors[sensor].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((sensors[sensor].attributes["CHANNEL"] == undefined) || (sensors[sensor].attributes["CHANNEL"] == "")) {
				flag = false;
			}
			if ((sensors[sensor].attributes["NAME"] == undefined) || (sensors[sensor].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((sensors[sensor].attributes["DISPLAY_NAME"] == undefined) || (sensors[sensor].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.cbussensors";
	}
	public function toXML():XMLNode {
		var sensorsNode = new XMLNode(1, container);
		for (var sensor in sensors) {
			sensorsNode.appendChild(sensors[sensor]);
		}
		return sensorsNode;
	}
	public function getName():String {
		return "Sensors";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function setData(newData:Object){
		sensors = newData.sensors;
	}
	public function getData():Object {
		return new Object({sensors:sensors});
	}
	public function setXML(newData:XMLNode):Void {
		sensors = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			sensors.push(newData.childNodes[child]);
		}
	}
}
