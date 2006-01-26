import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeButton extends Forms.BaseForm {
	private var object:XMLNode;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var label_ti:TextInput;
	private var icon_ti:TextInput;
	private var extra_ti:TextInput;
	private var extra2_ti:TextInput;
	private var extra3_ti:TextInput;
	private var width_ti:TextInput;
	private var command_ti:TextInput;
	private var repeatRate_ti:TextInput;
	private var showOn_ti:TextInput;
	public function init() {
		label_ti.text = object.attributes["label"];
		icon_ti.text = object.attributes["icon"];
		extra_ti.text = object.attributes["extra"];
		extra2_ti.text = object.attributes["extra2"];
		extra3_ti.text = object.attributes["extra3"];
		width_ti.text = object.attributes["width"];
		command_ti.text = object.attributes["command"];
		repeatRate_ti.text = object.attributes["repeatRate"];
		showOn_ti.text = object.attributes["showOn"];
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
	}
	public function deleteItem() {
	}
	public function updateItem() {
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1,"item");
		newObject.attributes["type"] = "button";
		newObject.attributes["label"] = label_ti.text;
		newObject.attributes["icon"] = icon_ti.text;
		newObject.attributes["extra"] = extra_ti.text;
		newObject.attributes["extra2"] = extra2_ti.text;
		newObject.attributes["extra3"] = extra3_ti.text;		
		newObject.attributes["width"] = width_ti.text;
		newObject.attributes["command"] = command_ti.text;		
		newObject.attributes["repeatRate"] = repeatRate_ti.text;
		newObject.attributes["showOn"] = showOn_ti.text;
		return newObject;
	}
}
