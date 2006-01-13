class Objects.Server.Toggles extends Objects.BaseElement {
	private var container:String;
	private var toggles:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var toggle in toggles) {
			if ((toggles[toggle].attributes["ACTIVE"] != "Y") && (toggles[toggle].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["KEY"] == undefined) || (toggles[toggle].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["NAME"] == undefined) || (toggles[toggle].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["DISPLAY_NAME"] == undefined) || (toggles[toggle].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.toggle";
	}
	public function toXML():XMLNode {
		var togglesNode = new XMLNode(1, container);
		for (var toggle in toggles) {
			togglesNode.appendChild(toggles[toggle]);
		}
		return togglesNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Toggles");
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Toggles";
	}
	public function getData():Object {
		return new Object({toggles:toggles});
	}
	public function setData(newData:Object):Void{
		toggles = newData.toggles;
	}
	public function setXML(newData:XMLNode):Void {
		toggles = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			toggles.push(newData.childNodes[child]);
		}
	}
}
