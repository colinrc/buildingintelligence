class Objects.Server.Raw_Interfaces extends Objects.BaseElement {
	var raw_interfaces:Array;
	var container:String;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var raw_interface in raw_interfaces){
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
		return new Object({raw_interfaces:raw_interfaces});
	}
	public function setData(newData:Object) {
		raw_interfaces = newData.raw_interfaces;
		//Process raw_interface changes....
		/*var newRaw_Interfaces = new Array();
		for (var index in newData.raw_interfaces) {
			var found = false;
			for (var raw_interface in raw_interfaces) {
				if (raw_interfaces[raw_interface].name == newData.raw_interfaces[index].name) {
					found = true;
				}
			}
			if (found == false) {
				newRaw_Interfaces.push({name:newData.raw_interfaces[index].name});
			}
		}
		var deletedRaw_Interfaces = new Array();
		for (var raw_interface in raw_interfaces) {
			var found = false;
			for (var index in newData.raw_interfaces) {
				if (raw_interfaces[raw_interface].name == newData.raw_interfaces[index].name) {
					found = true;
				}
			}
			if (found == false) {
				raw_interfaces.splice(parseInt(raw_interface), 1);
			}
		}
		for (var newRaw_Interface in newRaw_Interfaces) {
			var newNode = new XMLNode(1, "RAW_INTERFACES");
			newNode.attributes["NAME"] = newRaw_Interfaces[newRaw_Interface].name;
			var newRaw_Interface = new Objects.Server.Raw_Interface();
			newRaw_Interface.setXML(newNode);
			raw_interfaces.push(newRaw_Interface);
		}*/
	}
	public function setXML(newData:XMLNode):Void {
		raw_interfaces = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			//var newRaw_Interface = new Objects.Server.Raw_Interface();
			//newRaw_Interface.setXML(newData.childNodes[child]);
			raw_interfaces.push(newData.childNodes[child]);
		}
	}
}
