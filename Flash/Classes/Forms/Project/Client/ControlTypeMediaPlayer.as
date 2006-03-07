import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeMediaPlayer extends Forms.BaseForm {
	private var object:XMLNode;
	private var refreshRate_ti:TextInput;
	private var videoWidth_ti:TextInput;
	private var videoHeight_ti:TextInput;
	private var format_ti:TextInput;
	private var src_ti:TextInput;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		refreshRate_ti.addEventListener("change", changeListener);
		videoWidth_ti.addEventListener("change", changeListener);
		videoHeight_ti.addEventListener("change", changeListener);
		format_ti.addEventListener("change", changeListener);
		src_ti.addEventListener("change", changeListener);		
		if(object.attributes["refreshRate"] != undefined){
			refreshRate_ti.text = object.attributes["refreshRate"];
		} else{
			refreshRate_ti.text = "";
		}
		if(object.attributes["videoWidth"] != undefined){		
			videoWidth_ti.text = object.attributes["videoWidth"];
		} else{
			videoWidth_ti.text = "";
		}
		if(object.attributes["videoHeight"] != undefined){				
			videoHeight_ti.text = object.attributes["videoHeight"];
		} else{
			videoHeight_ti.text = "";
		}
		if(object.attributes["src"] != undefined){				
			src_ti.text = object.attributes["src"];
		} else{
			src_ti.text = "";
		}
		if(object.attributes["format"] != undefined){				
			format_ti.text = object.attributes["format"];
		} else{
			format_ti.text = "";
		}		
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1,"item");
		newObject.attributes["type"] = "mediaPlayer";
		if(refreshRate_ti.text != "") {
			newObject.attributes["refreshRate"] = refreshRate_ti.text;
		}
		if(videoWidth_ti.text != "") {
			newObject.attributes["videoWidth"] = videoWidth_ti.text;
		}
		if(videoHeight_ti.text !="") {
			newObject.attributes["videoHeight"] = videoHeight_ti.text;		
		}
		if(src_ti.text !="") {
			newObject.attributes["src"] = src_ti.text;		
		}
		if(format_ti.text !="") {
			newObject.attributes["format"] = format_ti.text;		
		}		
		return newObject;
	}
}
