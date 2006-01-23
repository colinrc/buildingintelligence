class Objects.Client.Control_Types extends Objects.BaseElement {
	private var controls:Array;
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.controltypes";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "controlTypes");
		for (var control in controls) {
			newNode.appendChild(controls[control].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		for (var control in controls) {
			newNode.appendChild(controls[control].toTree());
		}
		return newNode;
	}
	public function getName():String {
		return "Control Types";
	}
	public function getData():Object {
		return new Object({controls:controls});
	}
	public function setXML(newData:XMLNode):Void {
		controls = new Array();
		if (newData.nodeName == "controlTypes") {
			for (var child in newData.childNodes) {
				var newControl = new Objects.Client.Control();
				newControl.setXML(newData.childNodes[child]);
				controls.push(newControl);
			}
		} else {
			trace("Error, found "+newData.nodeName+", was expecting controlTypes");
		}
	}
	public function setData(newData:Object):Void {
		//Process control changes....
		var newControls = new Array();
		for (var index in newData.controls) {
			var found = false;
			for (var control in controls) {
				if (controls[control].type == newData.controls[index].type) {
					found = true;
				}
			}
			if (found == false) {
				newControls.push({type:newData.controls[index].type});
			}
		}
		var deletedControls = new Array();
		for (var control in controls) {
			var found = false;
			for (var index in newData.controls) {
				if (controls[control].type == newData.controls[index].type) {
					found = true;
				}
			}
			if (found == false) {
				controls.splice(parseInt(control), 1);
			}
		}
		for (var newControl in newControls) {
			var newNode = new XMLNode(1, "control");
			newNode.attributes["type"] = newControls[newControl].type;
			var newControl = new Objects.Client.Control();
			newControl.setXML(newNode);
			controls.push(newControl);
		}
	}
}
