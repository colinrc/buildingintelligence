class Objects.Server.Raw_Interfaces extends Objects.BaseElement {
	var raw_interfaces:Array;
	var container:String;
	var catalogues:Objects.Server.Catalogues;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var raw_interface in raw_interfaces) {
			tempKeys.push(raw_interfaces[raw_interface].attributes.DISPLAY_NAME);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		/*for (var raw_interface in raw_interfaces) {
		if (!raw_interfaces[raw_interface].isValid()) {
		flag = false;
		}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raw_interfaces";
	}
	public function toXML():XMLNode {
		var newRaw_Interfaces = new XMLNode(1, container);
		for (var raw_interface in raw_interfaces) {
			newRaw_Interfaces.appendChild(raw_interfaces[raw_interface]);
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
		return "Custom Outputs";
	}
	public function getData():Object {
		return new Object({raw_interfaces:raw_interfaces, cataloguesNode:catalogues.toXML()});
	}
	public function setData(newData:Object) {
		raw_interfaces = newData.raw_interfaces;
	}
	public function setXML(newData:XMLNode):Void {
		raw_interfaces = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			raw_interfaces.push(newData.childNodes[child]);
		}
	}
}
