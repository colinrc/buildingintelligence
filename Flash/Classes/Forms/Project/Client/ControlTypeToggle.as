import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeToggle extends Forms.BaseForm {
	private var object:XMLNode;
	private var icons_ti:TextInput;
	private var extras_ti:TextInput;
	private var width_ti:TextInput;
	private var command_ti:TextInput;
	private var sounds_ti:TextInput;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		icons_ti.addEventListener("change", changeListener);
		extras_ti.addEventListener("change", changeListener);
		width_ti.addEventListener("change", changeListener);
		command_ti.addEventListener("change", changeListener);
		sounds_ti.addEventListener("change", changeListener);
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
