import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeSlider extends Forms.BaseForm {
	private var object:XMLNode;
	private var width_ti:TextInput;
	private var delete_btn:Button;
	public function onLoad() {
		width_ti.addEventListener("change", Delegate.create(this, changeListener));
		if (object.attributes["width"] != undefined) {
			width_ti.text = object.attributes["width"];
		} else {
			width_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	public function deleteItem() {
	}
	public function changeListener(eventObject:Object) {
		_global.unSaved = true;
		object.attributes["type"] = "slider";
		object.attributes["width"] = width_ti.text;
	}
}
