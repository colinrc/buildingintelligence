class Objects.Client.Tab extends Objects.BaseElement {
	private var controls:Array;
	private var name:String;
	private var icon:String;
	public function isValid():Boolean {
		var flag = true;
		for (var control in controls) {
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.tab";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "tab");
		if(name != "") {
			newNode.attributes["name"] = name;
		}
		if(icon != "") {
			newNode.attributes["icon"] = icon;
		}
		for (var control in controls) {
			newNode.appendChild(controls[control]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Tab");
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Tab : "+name;
	}
	public function getData():Object {
		return new Object({controls:controls,name:name,icon:icon});
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		icon = "";
		if(newData.nodeName == "tab"){
			if(newData.attributes["name"] != undefined) {
				name = newData.attributes["name"];
			}
			if(newData.attributes["icon"] != undefined) {
				icon = newData.attributes["icon"];
			}
			controls = new Array();
			for(var child in newData.childNodes){
				controls.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting tab");
		}
	}
	public function setData(newData:Object):Void {
		controls = newData.controls;
		name = newData.name;
		icon = newData.icon;
	}
}
