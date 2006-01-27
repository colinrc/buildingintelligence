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
		if(object.attributes["icons"] != undefined){
			icons_ti.text = object.attributes["icons"];
		} else{
			icons_ti.text = "";
		}
		if(object.attributes["extras"] != undefined){		
		extras_ti.text = object.attributes["extras"];
		} else {
			extras_ti.text = "";
		}
		if(object.attributes["width"] != undefined){				
			width_ti.text = object.attributes["width"];
		} else {
			width_ti.text = "";
		}
		if(object.attributes["command"] != undefined){
			command_ti.text = object.attributes["command"];
		} else {
			command_ti.text = "";
		}
		if(object.attributes["sounds"] != undefined){		
			sounds_ti.text = object.attributes["sounds"];
		} else {
			sounds_ti.text = "";
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
		newObject.attributes["type"] = "toggle";
		if(icons_ti.text != "") {
			newObject.attributes["icons"] = icons_ti.text;
		}
		if(extras_ti.text != "") {
			newObject.attributes["extras"] = extras_ti.text;
		}
		if(width_ti.text != "") {
			newObject.attributes["width"] = width_ti.text;
		}
		if(command_ti.text !="") {
			newObject.attributes["command"] = command_ti.text;		
		}
		if(sounds_ti.text !="") {
			newObject.attributes["sounds"] = sounds_ti.text;
		}
		return newObject;
	}
}
