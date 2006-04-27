import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeLabel extends Forms.BaseForm {
	private var object:XMLNode;
	private var label_ti:TextInput;
	private var delete_btn:Button;
	public function onLoad() {
		label_ti.addEventListener("change", Delegate.create(this, changeListener));
		if (object.attributes["label"] != undefined) {
			label_ti.text = object.attributes["label"];
		} else {
			label_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	public function deleteItem() {
	}
	public function changeListener(eventObject:Object) {
		_global.unSaved = true;
		object.attributes["type"] = "label";
		if(label_ti.text.length){
			object.attributes["label"] = label_ti.text;
		}
	}
}
