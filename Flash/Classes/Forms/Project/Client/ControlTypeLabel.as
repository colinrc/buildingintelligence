import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeLabel extends Forms.BaseForm {
	private var object:XMLNode;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var label_ti:TextInput;
	public function init() {
		if (object.attributes["label"] != undefined) {
			label_ti.text = object.attributes["label"];
		} else {
			label_ti.text = "";
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
		newObject.attributes["type"] = "label";
		if(label_ti.text != ""){
			newObject.attributes["label"] = label_ti.text;
		}
		return newObject;
	}
}
