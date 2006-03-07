import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeLabel extends Forms.BaseForm {
	private var object:XMLNode;
	private var label_ti:TextInput;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		label_ti.addEventListener("change", changeListener);
		if (object.attributes["label"] != undefined) {
			label_ti.text = object.attributes["label"];
		} else {
			label_ti.text = "";
		}
	}
	public function getObject():XMLNode {
		var newObject = new XMLNode(1,"item");
		newObject.attributes["type"] = "label";
		if(label_ti.text != ""){
			newObject.attributes["label"] = label_ti.text;
		}
		return newObject;
	}
}
