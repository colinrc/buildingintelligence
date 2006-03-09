import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeButton extends Forms.BaseForm {
	private var object:XMLNode;
	private var label_ti:TextInput;
	private var icon_ti:TextInput;
	private var extra_ti:TextInput;
	private var extra2_ti:TextInput;
	private var extra3_ti:TextInput;
	private var width_ti:TextInput;
	private var command_ti:TextInput;
	private var repeatRate_ti:TextInput;
	private var showOn_ti:TextInput;
	private var delete_btn:Button;
	public function onLoad() {
		label_ti.addEventListener("change", Delegate.create(this, changeListener));
		icon_ti.addEventListener("change", Delegate.create(this, changeListener));
		extra_ti.addEventListener("change", Delegate.create(this, changeListener));
		extra2_ti.addEventListener("change", Delegate.create(this, changeListener));
		extra3_ti.addEventListener("change", Delegate.create(this, changeListener));
		width_ti.addEventListener("change", Delegate.create(this, changeListener));
		command_ti.addEventListener("change", Delegate.create(this, changeListener));
		repeatRate_ti.addEventListener("change", Delegate.create(this, changeListener));
		showOn_ti.addEventListener("change", Delegate.create(this, changeListener));
		if (object.attributes["label"] != undefined) {
			label_ti.text = object.attributes["label"];
		} else {
			label_ti.text = "";
		}
		if (object.attributes["icon"] != undefined) {
			icon_ti.text = object.attributes["icon"];
		} else {
			icon_ti.text = "";
		}
		if (object.attributes["extra"] != undefined) {
			extra_ti.text = object.attributes["extra"];
		} else {
			extra_ti.text = "";
		}
		if (object.attributes["extra2"] != undefined) {
			extra2_ti.text = object.attributes["extra2"];
		} else {
			extra2_ti.text = "";
		}
		if (object.attributes["extra3"] != undefined) {
			extra3_ti.text = object.attributes["extra3"];
		} else {
			extra3_ti.text = "";
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
		if (object.attributes["repeatRate"] != undefined) {
			repeatRate_ti.text = object.attributes["repeatRate"];
		} else {
			repeatRate_ti.text = "";
		}
		if (object.attributes["showOn"] != undefined) {
			showOn_ti.text = object.attributes["showOn"];
		} else {
			showOn_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	public function changeListener(evtObj) {
		_global.unSaved = true;
		object.attributes["type"] = "button";
		object.attributes["label"] = label_ti.text;
		object.attributes["icon"] = icon_ti.text;
		object.attributes["extra"] = extra_ti.text;
		object.attributes["extra2"] = extra2_ti.text;
		object.attributes["extra3"] = extra3_ti.text;
		object.attributes["width"] = width_ti.text;
		object.attributes["command"] = command_ti.text;
		object.attributes["repeatRate"] = repeatRate_ti.text;
		object.attributes["showOn"] = showOn_ti.text;
	}
	public function deleteItem() {
	}
}
