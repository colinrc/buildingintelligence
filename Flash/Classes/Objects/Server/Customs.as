class Objects.Server.Customs extends Objects.BaseElement {
	private var container:String;
	private var customs:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var custom in customs) {
			if ((customs[custom].attributes["ACTIVE"] != "Y") && (customs[custom].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((customs[custom].attributes["KEY_IS_REGEX"] != "Y") && (customs[custom].attributes["KEY_IS_REGEX"] != "N")) {
				flag = false;
			}
			if ((customs[custom].attributes["KEY"] == undefined) || (customs[custom].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((customs[custom].attributes["NAME"] == undefined) || (customs[custom].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((customs[custom].attributes["DISPLAY_NAME"] == undefined) || (customs[custom].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
			if ((customs[custom].attributes["COMMAND"] == undefined) || (customs[custom].attributes["COMMAND"] == "")) {
				flag = false;
			}
			if ((customs[custom].attributes["EXTRA"] == undefined) || (customs[custom].attributes["EXTRA"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.custom";
	}
	public function toXML():XMLNode {
		var customsNode = new XMLNode(1, container);
		for (var custom in customs) {
			customsNode.appendChild(customs[custom]);
		}
		return customsNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Customs");
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Customs";
	}
	public function getData():Object {
		return new Object({customs:customs});
	}
	public function setData(newData:Object){
		customs = newData.customs;
	}
	public function setXML(newData:XMLNode):Void {
		customs = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			customs.push(newData.childNodes[child]);
		}
	}
}
