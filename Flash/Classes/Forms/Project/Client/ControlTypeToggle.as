import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeToggle extends Forms.BaseForm {
	private var object:XMLNode;
	private var icons_ti:TextInput;
	private var extras_ti:TextInput;
	private var width_ti:TextInput;
	private var command_ti:TextInput;
	private var sounds_ti:TextInput;
	private var delete_btn:Button;
	private var update_btn:Button;
	public function onLoad() {
		icons_ti.addEventListener("change", Delegate.create(this, changeListener));
		extras_ti.addEventListener("change", Delegate.create(this, changeListener));
		width_ti.addEventListener("change", Delegate.create(this, changeListener));
		command_ti.addEventListener("change", Delegate.create(this, changeListener));
		sounds_ti.addEventListener("change", Delegate.create(this, changeListener));
		if (object.attributes["icons"] != undefined) {
			icons_ti.text = object.attributes["icons"];
		} else {
			icons_ti.text = "";
		}
		if (object.attributes["extras"] != undefined) {
			extras_ti.text = object.attributes["extras"];
		} else {
			extras_ti.text = "";
		}
		if (object.attributes["width"] != undefined) {
			width_ti.text = object.attributes["width"];
		} else {
			width_ti.text = "";
		}
		if (object.attributes["command"] != undefined) {
			command_ti.text = object.attributes["command"];
		} else {
			command_ti.text = "";
		}
		if (object.attributes["sounds"] != undefined) {
			sounds_ti.text = object.attributes["sounds"];
		} else {
			sounds_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	public function deleteItem() {
	}
	public function changeListener(eventObject:Object) {
		_global.unSaved = true;
		object.attributes["type"] = "toggle";
		object.attributes["icons"] = icons_ti.text;
		object.attributes["extras"] = extras_ti.text;
		object.attributes["width"] = width_ti.text;
		object.attributes["command"] = command_ti.text;
		object.attributes["sounds"] = sounds_ti.text;
	}
}
