import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeMediaPlayer extends Forms.BaseForm {
	private var object:XMLNode;
	private var refreshRate_ti:TextInput;
	private var videoWidth_ti:TextInput;
	private var videoHeight_ti:TextInput;
	private var format_ti:TextInput;
	private var src_ti:TextInput;
	private var delete_btn:Button;
	public function onLoad() {
		refreshRate_ti.addEventListener("change", Delegate.create(this, changeListener));
		videoWidth_ti.addEventListener("change", Delegate.create(this, changeListener));
		videoHeight_ti.addEventListener("change", Delegate.create(this, changeListener));
		format_ti.addEventListener("change", Delegate.create(this, changeListener));
		src_ti.addEventListener("change", Delegate.create(this, changeListener));
		if (object.attributes["refreshRate"] != undefined) {
			refreshRate_ti.text = object.attributes["refreshRate"];
		} else {
			refreshRate_ti.text = "";
		}
		if (object.attributes["videoWidth"] != undefined) {
			videoWidth_ti.text = object.attributes["videoWidth"];
		} else {
			videoWidth_ti.text = "";
		}
		if (object.attributes["videoHeight"] != undefined) {
			videoHeight_ti.text = object.attributes["videoHeight"];
		} else {
			videoHeight_ti.text = "";
		}
		if (object.attributes["src"] != undefined) {
			src_ti.text = object.attributes["src"];
		} else {
			src_ti.text = "";
		}
		if (object.attributes["format"] != undefined) {
			format_ti.text = object.attributes["format"];
		} else {
			format_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	public function deleteItem() {
	}
	public function changeListener(eventObject:Object) {
		_global.unSaved = true;
		var newObject = new XMLNode(1, "item");
		object.attributes["type"] = "mediaPlayer";
		if(refreshRate_ti.text.length){
			object.attributes["refreshRate"] = refreshRate_ti.text;
		}
		if(videoWidth_ti.text.length){
			object.attributes["videoWidth"] = videoWidth_ti.text;
		}
		if(videoHeight_ti.text.length){
			object.attributes["videoHeight"] = videoHeight_ti.text;
		}
		if(src_ti.text.length){
			object.attributes["src"] = src_ti.text;
		}
		if(format_ti.text.length){
			object.attributes["format"] = format_ti.text;
		}
	}
}
