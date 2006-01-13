class Objects.Server.Raw_Interfaces extends Objects.BaseElement {
	var raw_interfaces:Array;
	var container:String;
	public function isValid():Boolean {
		var flag = true;
		for (var raw_interface in raw_interfaces) {
			if (!raw_interfaces[raw_interface].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raw_interfaces";
	}
	public function toXML():XMLNode {
		var newRaw_Interfaces = new XMLNode(1, container);
		for (var raw_interface in raw_interfaces) {
			newRaw_Interfaces.appendChild(raw_interfaces[raw_interface].toXML());
		}
		return newRaw_Interfaces;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Raw Interfaces");
		for (var raw_interface in raw_interfaces) {
			newNode.appendChild(raw_interfaces[raw_interface].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Raw Interfaces";
	}
	public function getData():Object {
		return new Object({raw_interfaces:raw_interfaces});
	}
	public function setData(newData:Object) {
		//process new interfaces
	}
	public function setXML(newData:XMLNode):Void {
		raw_interfaces = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newRaw_Interface = new Objects.Server.Raw_Interface();
			newRaw_Interface.setXML(newData.childNodes[child]);
			raw_interfaces.push(newRaw_Interface);
		}
	}
}
