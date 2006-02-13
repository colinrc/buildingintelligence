import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeWebBrowser extends Forms.BaseForm {
	private var object:XMLNode;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var url_ti:TextInput;
	private var width_ti:TextInput;
	private var height_ti:TextInput;
	public function init() {
		if(object.attributes["url"] != undefined){
			url_ti.text = object.attributes["url"];
		} else {
			url_ti.text = "";
		}

		if(object.attributes["width"] != undefined) {				
		width_ti.text = object.attributes["width"];
		} else {
			width_ti.text = "";
		}
		if(object.attributes["height"] != undefined) {				
		height_ti.text = object.attributes["height"];
		} else {
			height_ti.text = "";
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
		newObject.attributes["type"] = "browser";
		newObject.attributes["url"] = url_ti.text;
		newObject.attributes["width"] = width_ti.text;
		newObject.attributes["height"] = height_ti.text;		
		return newObject;
	}
}
