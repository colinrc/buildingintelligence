import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeSlider extends Forms.BaseForm {
	private var object:XMLNode;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var width_ti:TextInput;
	public function init() {
		width_ti.text = object.attributes["width"];
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
	}
	public function deleteItem() {
	}
	public function updateItem() {
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1,"item");
		newObject.attributes["type"] = "slider";
		newObject.attributes["width"] = width_ti.text;
		return newObject;
	}
}
