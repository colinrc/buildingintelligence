import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.BooleanEdit{
	private var update_btn:Button;
	private var value_chk:CheckBox;
	private var name_lb:Label;
	private var default_lb:Label;
	private var description_lb:Label;
	private var setting:Object;
	
	public function init():Void{
		update_btn.addEventListener("click", Delegate.create(this, update));
		value_chk.selected = setting.value;
		default_lb.text = setting.def;
		description_lb.text = setting.description;
		name_lb.text = setting.label;
	}
	private function update(){
		setting.value=value_chk.selected;
	}
}
