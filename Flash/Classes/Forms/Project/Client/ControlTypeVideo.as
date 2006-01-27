import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeVideo extends Forms.BaseForm {
	private var object:XMLNode;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var src_ti:TextInput;
	private var format_ti:TextInput;
	private var refreshRate_ti:TextInput;
	private var videoWidth_ti:TextInput;
	private var videoHeight_ti:TextInput;
	public function init() {
		if(object.attributes["src"] != undefined){
			src_ti.text = object.attributes["src"];
		} else {
			src_ti.text = "";
		}
		if(object.attributes["format"] != undefined) {
			format_ti.text = object.attributes["format"];
		} else {
			format_ti.text = "";
		}
		if(object.attributes["refreshRate"] != undefined) {		
		refreshRate_ti.text = object.attributes["refreshRate"];
		} else {
			refreshRate_ti.text = "";
		}
		if(object.attributes["videoWidth"] != undefined) {				
		videoWidth_ti.text = object.attributes["videoWidth"];
		} else {
			videoWidth_ti.text = "";
		}
		if(object.attributes["videoHeight"] != undefined) {				
		videoHeight_ti.text = object.attributes["videoHeight"];
		} else {
			videoHeight_ti.text = "";
		}	
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
	}
	public function deleteItem() {
	}
	public function updateItem() {
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1,"item");
		newObject.attributes["type"] = "video";
		newObject.attributes["src"] = src_ti.text;
		newObject.attributes["format"] = format_ti.text;
		newObject.attributes["refreshRate"] = refreshRate_ti.text;
		newObject.attributes["videoWidth"] = videoWidth_ti.text;
		newObject.attributes["videoHeight"] = videoHeight_ti.text;		
		return newObject;
	}
}
