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
		src_ti.text = object.attributes["src"];
		format_ti.text = object.attributes["format"];
		refreshRate_ti.text = object.attributes["refreshRate"];
		videoWidth_ti.text = object.attributes["videoWidth"];
		videoHeight_ti.text = object.attributes["videoHeight"];
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
