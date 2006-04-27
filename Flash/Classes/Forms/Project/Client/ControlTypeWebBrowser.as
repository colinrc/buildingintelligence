import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeWebBrowser extends Forms.BaseForm {
	private var object:XMLNode;
	private var url_ti:TextInput;
	private var width_ti:TextInput;
	private var height_ti:TextInput;
	private var delete_btn:Button;
	public function onLoad() {
		url_ti.addEventListener("change", Delegate.create(this, changeListener));
		width_ti.addEventListener("change", Delegate.create(this, changeListener));
		height_ti.addEventListener("change", Delegate.create(this, changeListener));
		if (object.attributes["url"] != undefined) {
			url_ti.text = object.attributes["url"];
		} else {
			url_ti.text = "";
		}
		if (object.attributes["width"] != undefined) {
			width_ti.text = object.attributes["width"];
		} else {
			width_ti.text = "";
		}
		if (object.attributes["height"] != undefined) {
			height_ti.text = object.attributes["height"];
		} else {
			height_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	public function deleteItem() {
	}
	public function changeListener(eventObject:Object) {
		_global.unSaved = true;
		object.attributes["type"] = "browser";
		if(url_ti.text.length){
			object.attributes["url"] = url_ti.text;
		}
		if(width_ti.text.length){
			object.attributes["width"] = width_ti.text;
		}
		if(height_ti.text.length){
			object.attributes["height"] = height_ti.text;
		}
	}
}
