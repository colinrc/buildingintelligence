class Objects.Client.Sounds extends Objects.BaseElement {
	private var sounds:Array;
	private var treeNode:XMLNode;
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		//mdm.Dialogs.prompt("InSound");
		var flag = "ok";
		clearValidationMsg();
		for (var sound in sounds) {
			if ((sounds[sound].attributes["name"] == undefined) || (sounds[sound].attributes["name"] == "")) {
				flag = "warning";
				appendValidationMsg("Name is invalid");
			}
			if ((sounds[sound].attributes["file"] == undefined) || (sounds[sound].attributes["file"] == "")) {
				flag = "warning";
				appendValidationMsg("File is invalid");
			}
			if ((sounds[sound].attributes["volume"] == undefined) || (sounds[sound].attributes["volume"] == "")) {
				flag = "warning";
				appendValidationMsg("Volume is invalid");
			}
		}
		mdm.Exception.DebugWindow(flag);

		return flag;
	}
	public function getForm():String {
		return "forms.project.client.sounds";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "sounds");
		for(var sound in sounds){
			newNode.appendChild(sounds[sound]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String{
		return "Sounds";
	}
	public function getName():String {
		return "Sounds";
	}
	public function getData():Object {
		return {sounds:sounds, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		sounds = new Array();
		if(newData.nodeName == "sounds"){
			for(var child in newData.childNodes){
				sounds.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting sounds");
		}
	}
	public function setData(newData:Object):Void {
		sounds = newData.sounds;
	}
}
