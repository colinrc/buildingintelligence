class Objects.Server.AudioVideos extends Objects.BaseElement {
	private var container:String;
	private var audiovideos:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var audiovideo in audiovideos) {
			tempKeys.push(audiovideos[audiovideo].display_name);
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
		var itemType:String;
		switch (container) {
		case "HAL" :
		case "TUTONDO" :
			itemType = "AUDIO_OUTPUT";
			break;
		case "KRAMER" :
			itemType = "AV_OUTPUT";
			break;
		}
		for (var audiovideo in audiovideos) {		
			var newAudioVideoNode = new XMLNode(1, itemType);
			if (audiovideos[audiovideo].key != "") {
				newAudioVideoNode.attributes["KEY"] = audiovideos[audiovideo].key;
			}
			if (audiovideos[audiovideo].display_name != "") {
				newAudioVideoNode.attributes["DISPLAY_NAME"] = audiovideos[audiovideo].display_name;
			}
			if (audiovideos[audiovideo].active != "") {
				newAudioVideoNode.attributes["ACTIVE"] = audiovideos[audiovideo].active;
			}
			audiovideosNode.appendChild(newAudioVideoNode);
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
	public function getKey():String {
		return "AudioVideos";
	}
	public function getData():Object {
		return {audiovideos:audiovideos, container:container, dataObject:this};
	}
	public function setData(newData:Object) {
		audiovideos = newData.audiovideos;
	}
	public function setXML(newData:XMLNode):Void {
		audiovideos = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newAudiovideo = new Object();
			newAudiovideo.key = "";
			newAudiovideo.display_name = "";
			newAudiovideo.active = "Y";
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newAudiovideo.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newAudiovideo.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newAudiovideo.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			audiovideos.push(newAudiovideo);
		}
	}
}
