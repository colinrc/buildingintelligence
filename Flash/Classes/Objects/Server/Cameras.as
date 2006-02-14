class Objects.Server.Cameras extends Objects.BaseElement {
	private var container:String;
	private var cameras:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var camera in cameras) {
			tempKeys.push(cameras[camera].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var camera in cameras) {
			if ((cameras[camera].attributes["ACTIVE"] != "Y") && (cameras[camera].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((cameras[camera].attributes["KEY"] == undefined) || (cameras[camera].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((cameras[camera].attributes["DISPLAY_NAME"] == undefined) || (cameras[camera].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
			//does zoom need to be checked? 
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.camera";
	}
	public function toXML():XMLNode {
		var camerasNode = new XMLNode(1, container);
		for (var camera in cameras) {
			camerasNode.appendChild(cameras[camera]);
		}
		return camerasNode;
	}
	public function getName():String {
		return "Cameras";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		_global.workflow.addNode("Cameras",newNode);
		return newNode;
	}
	public function setData(newData:Object) {
		cameras = newData.cameras;
	}
	public function getData():Object {
		return new Object({cameras:cameras});
	}
	public function setXML(newData:XMLNode):Void {
		cameras = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			cameras.push(newData.childNodes[child]);
		}
	}
}
