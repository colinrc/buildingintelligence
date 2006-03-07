import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeSlider extends Forms.BaseForm {
	private var object:XMLNode;
	private var width_ti:TextInput;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		width_ti.addEventListener("change", changeListener);
		if(object.attributes["width"] != undefined) {
			width_ti.text = object.attributes["width"];
		} else{
			width_ti.text ="";
		}
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1,"item");
		newObject.attributes["type"] = "slider";
		if(width_ti.text != "") {
			newObject.attributes["width"] = width_ti.text;
		}
		return newObject;
	}
}
