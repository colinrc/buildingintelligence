import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.BooleanEdit extends Forms.BaseForm {
	private var value_chk:CheckBox;
	private var name_lb:Label;
	private var default_lb:Label;
	private var description_lb:Label;
	private var setting:Object;
	public function onLoad():Void {
		value_chk.addEventListener("click", Delegate.create(this, update));
		if((setting.value == "true")||(setting.value == true)){
			value_chk.selected = true;
		}
		default_lb.text = setting.def;
		description_lb.text = setting.description;
		name_lb.text = setting.label;
	}
	private function update() {
		setting.value = value_chk.selected;
		_global.unSaved = true;
	}
}
