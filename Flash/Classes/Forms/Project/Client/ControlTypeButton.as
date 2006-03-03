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
	public function onLoad() {
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
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
	}
	public function deleteItem() {
	}
	public function updateItem() {
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1, "item");
		newObject.attributes["type"] = "button";
		if(label_ti.text != ""){
			newObject.attributes["label"] = label_ti.text;
		}
		if(icon_ti.text != ""){
			newObject.attributes["icon"] = icon_ti.text;
		}
		if(extra_ti.text != ""){		
			newObject.attributes["extra"] = extra_ti.text;
		}
		if(extra2_ti.text != ""){		
			newObject.attributes["extra2"] = extra2_ti.text;
		}
		if(extra3_ti.text != ""){		
			newObject.attributes["extra3"] = extra3_ti.text;
		}
		if(width_ti.text != ""){		
			newObject.attributes["width"] = width_ti.text;
		}
		if(command_ti.text != ""){		
			newObject.attributes["command"] = command_ti.text;
		}
		if(repeatRate_ti.text != ""){		
			newObject.attributes["repeatRate"] = repeatRate_ti.text;
		}
		if(showOn_ti.text != ""){		
			newObject.attributes["showOn"] = showOn_ti.text;
		}	
		return newObject;
	}
}
