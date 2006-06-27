import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryIcon extends Forms.BaseForm {
	private var icons_ti:TextInput;
	private var commands_ti:TextInput;
	private var key_ti:TextInput;
	private var currentAlert:Object;
	public function onLoad():Void {
		icons_ti.text = currentAlert.icons;
		commands_ti.text = currentAlert.commands;
		key_ti.text = currentAlert.key;
		icons_ti.addEventListener("change", Delegate.create(this,changeListener));
		commands_ti.addEventListener("change", Delegate.create(this,changeListener));
		key_ti.addEventListener("change",Delegate.create(this, changeListener));
	}
	function changeListener() {
		_global.unSaved = true;
		currentAlert.icons = icons_ti.text;
		currentAlert.commands = commands_ti.text;
		currentAlert.key = key_ti.text;
	}
}
