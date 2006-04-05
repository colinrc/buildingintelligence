class Objects.Client.Control_Types extends Objects.BaseElement {
	private var controls:Array;
	private var treeNode:XMLNode;		
	public function isValid():String {
		return "ok";
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
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String{
		return "ClientControl_Types";
	}	
	public function getName():String {
		return "Control Types";
	}
	public function getData():Object {
		return {controls:controls, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		controls = new Array();
		if (newData.nodeName == "controlTypes") {
			for (var child in newData.childNodes) {
				var newControl = new Objects.Client.Control();
				newControl.setXML(newData.childNodes[child]);
				newControl.id = _global.formDepth++;
				controls.push(newControl);
			}
		} else {
			trace("Error, found "+newData.nodeName+", was expecting controlTypes");
		}
	}
	public function setData(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);
		//Process control changes....
		var newControls = new Array();
		for (var index in newData.controls) {
			if (newData.controls[index].id == undefined) {
				newControls.push({type:newData.controls[index].type});
			}
		}
		for (var control in controls) {
			var found = false;
			for (var index in newData.controls) {
				if (controls[control].id == newData.controls[index].id) {
					controls[control].type = newData.controls[index].type;
					found = true;
				}
			}
			if (found == false) {
				controls[control].deleteSelf();
				controls.splice(parseInt(control), 1);
			}
		}
		for (var newControl in newControls) {
			var newNode = new XMLNode(1, "control");
			newNode.attributes["type"] = newControls[newControl].type;
			var newControl = new Objects.Client.Control();
			newControl.setXML(newNode);
			newControl.id = _global.formDepth++;			
			treeNode.appendChild(newControl.toTree());	
			controls.push(newControl);
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
}
