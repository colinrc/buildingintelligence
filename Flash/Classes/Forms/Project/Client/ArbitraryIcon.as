import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryIcon extends Forms.BaseForm {
	private var icons_ti:TextInput;
	private var commands_ti:TextInput;
	private var key_ti:TextInput;
	private var dataObj:Object;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		icons_ti.addEventListener("change", changeListener);	
		commands_ti.addEventListener("change", changeListener);		
		key_ti.addEventListener("change", changeListener);
		icons_ti.text = dataObj.icons;
		commands_ti.text = dataObj.commands;
		key_ti.text = dataObj.key;
	}
	private function getData():Object {
		var newObj = new Object();
		newObj.icons = icons_ti.text;
		newObj.commands = commands_ti.text;
		newObj.key = key_ti.text;
		return newObj;
	}
}
