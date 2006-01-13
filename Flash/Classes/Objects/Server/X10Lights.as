class Objects.Server.X10Lights extends Objects.BaseElement {
	private var container:String;
	private var x10lights:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var x10light in x10lights) {
			if ((x10lights[x10light].attributes["ACTIVE"] != "Y") && (x10lights[x10light].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((x10lights[x10light].attributes["KEY"] == undefined) || (x10lights[x10light].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((x10lights[x10light].attributes["NAME"] == undefined) || (x10lights[x10light].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((x10lights[x10light].attributes["DISPLAY_NAME"] == undefined) || (x10lights[x10light].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.x10light";
	}
	public function toXML():XMLNode {
		var x10lightsNode = new XMLNode(1, container);
		for (var x10light in x10lights) {
			x10lightsNode.appendChild(x10lights[x10light]);
		}
		return x10lightsNode;
	}
	public function getName():String {
		return "X10 Lights";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({x10lights:x10lights});
	}
	public function setData(newData:Object):Void{
		x10lights = newData.x10lights;
	}
	public function setXML(newData:XMLNode):Void {
		x10lights = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			x10lights.push(newData.childNodes[child]);
		}
	}
}
