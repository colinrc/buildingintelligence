import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeToggle extends Forms.BaseForm {
	private var object:XMLNode;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var icons_ti:TextInput;
	private var extras_ti:TextInput;
	private var width_ti:TextInput;
	private var command_ti:TextInput;
	private var sounds_ti:TextInput;
	public function init() {
		icons_ti.text = object.attributes["icons"];
		extras_ti.text = object.attributes["extras"];
		width_ti.text = object.attributes["width"];
		command_ti.text = object.attributes["command"];
		sounds_ti.text = object.attributes["sounds"];
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
	}
	public function deleteItem() {
	}
	public function updateItem() {
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1,"item");
		newObject.attributes["type"] = "toggle";
		newObject.attributes["icons"] = icons_ti.text;
		newObject.attributes["extras"] = extras_ti.text;
		newObject.attributes["width"] = width_ti.text;
		newObject.attributes["command"] = command_ti.text;		
		newObject.attributes["sounds"] = sounds_ti.text;
		return newObject;
	}
}
