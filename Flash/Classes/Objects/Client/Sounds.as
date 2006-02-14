class Objects.Client.Sounds extends Objects.BaseElement {
	private var sounds:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var sound in sounds) {
			if ((sounds[sound].attributes["name"] == undefined) || (sounds[sound].attributes["name"] == "")) {
				flag = false;
			}
			if ((sounds[sound].attributes["file"] == undefined) || (sounds[sound].attributes["file"] == "")) {
				flag = false;
			}
			if ((sounds[sound].attributes["volume"] == undefined) || (sounds[sound].attributes["volume"] == "")) {
				flag = false;
			}
		}
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
		_global.workflow.addNode("ClientSounds",newNode);
		return newNode;
	}
	public function getName():String {
		return "Sounds";
	}
	public function getData():Object {
		return new Object({sounds:sounds});
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
