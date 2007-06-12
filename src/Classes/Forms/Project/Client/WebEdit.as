import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.WebEdit extends Forms.BaseForm {
	private var value_ti:TextInput;
	private var name_lb:Label;
	private var default_lb:Label;
	private var description_lb:Label;
	private var setting:Object;
	public function onLoad():Void {
		value_ti.addEventListener("change", Delegate.create(this, update));
		value_ti.text = setting.value;
		default_lb.text = setting.def;
		description_lb.text = setting.description;
		name_lb.text = setting.label;
	}
	private function update(eventObject) {
		setting.value = value_ti.text;
		_global.unSaved = true;
	}
}
