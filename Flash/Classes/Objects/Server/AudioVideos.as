class Objects.Server.AudioVideos extends Objects.BaseElement {
	private var container:String;
	private var audiovideos:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var audiovideo in audiovideos) {
			tempKeys.push(audiovideos[audiovideo].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var audiovideo in audiovideos) {
			if ((audiovideos[audiovideo].attributes["KEY"] == undefined) || (audiovideos[audiovideo].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((audiovideos[audiovideo].attributes["DISPLAY_NAME"] == undefined) || (audiovideos[audiovideo].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.audiovideo";
	}
	public function toXML():XMLNode {
		var audiovideosNode = new XMLNode(1, container);
		for (var audiovideo in audiovideos) {
			audiovideosNode.appendChild(audiovideos[audiovideo]);
		}
		return audiovideosNode;
	}
	public function getName():String {
		var itemType:String;
		switch (container) {
		case "HAL" :
		case "TUTONDO" :
			itemType = "Audio Zones";
			break;
		case "KRAMER" :
			itemType = "AV Zones";
			break;
		}
		return itemType;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({audiovideos:audiovideos, container:container});
	}
	public function setData(newData:Object) {
		audiovideos = newData.audiovideos;
	}
	public function setXML(newData:XMLNode):Void {
		audiovideos = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			audiovideos.push(newData.childNodes[child]);
		}
	}
}
