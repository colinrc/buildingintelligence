class Objects.Client.Doors extends Objects.BaseElement {
	private var doors:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var door in doors) {
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.doors";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "doors");
		for (var door in doors) {
			newNode.appendChild(doors[door]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Doors";
	}
	public function getData():Object {
		return new Object({doors:doors});
	}
	public function setXML(newData:XMLNode):Void {
		doors = new Array();
		if(newData.nodeName == "doors"){
			for(var child in newData.childNodes){
				doors.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting");
		}
	}
	public function setData(newData:Object):Void {
		doors = newData.doors;
	}
}
