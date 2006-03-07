import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeWebBrowser extends Forms.BaseForm {
	private var object:XMLNode;
	private var url_ti:TextInput;
	private var width_ti:TextInput;
	private var height_ti:TextInput;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		url_ti.addEventListener("change", changeListener);
		width_ti.addEventListener("change", changeListener);
		height_ti.addEventListener("change", changeListener);		
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
