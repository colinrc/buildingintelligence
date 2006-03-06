class Objects.Server.Cameras extends Objects.BaseElement {
	private var container:String;
	private var cameras:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var camera in cameras) {
			tempKeys.push(cameras[camera].display_name);
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
			var newCamera = new XMLNode(1, "CAMERA");
			if (cameras[camera].key != "") {
				newCamera.attributes["KEY"] = cameras[camera].key;
			}
			if (cameras[camera].display_name != "") {
				newCamera.attributes["DISPLAY_NAME"] = cameras[camera].display_name;
			}
			if (cameras[camera].active != "") {
				newCamera.attributes["ACTIVE"] = cameras[camera].active;
			}
			if (cameras[camera].zoom != "") {
				newCamera.attributes["ZOOM"] = cameras[camera].zoom;
			}			
			camerasNode.appendChild(newCamera);
		}
		return camerasNode;
	}
	public function getName():String {
		return "Cameras";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getKey():String {
		return "Cameras";
	}
	public function setData(newData:Object) {
		cameras = newData.cameras;
	}
	public function getData():Object {
		return {cameras:cameras, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		cameras = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newCamera = new Object();
			newCamera.active = "Y";
			newCamera.key = "";
			newCamera.display_name = "";
			newCamera.zoom = "";
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newCamera.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newCamera.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["ZOOM"] != undefined) {
				newCamera.zoom = newData.childNodes[child].attributes["ZOOM"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newCamera.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			cameras.push(newCamera);
		}
	}
}
