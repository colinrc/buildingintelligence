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
			dataObj.icons = icons_ti.text;
			dataObj.commands = commands_ti.text;
			dataObj.key = key_ti.text;
		};
		icons_ti.text = dataObj.icons;
		commands_ti.text = dataObj.commands;
		key_ti.text = dataObj.key;
		icons_ti.addEventListener("change", changeListener);	
		commands_ti.addEventListener("change", changeListener);		
		key_ti.addEventListener("change", changeListener);
	}
}
