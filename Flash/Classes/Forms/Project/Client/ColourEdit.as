import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ColourEdit extends Forms.BaseForm {
	private var update_btn:Button;
	private var colour_picker_mc:MovieClip;
	private var name_lb:Label;
	private var default_lb:Label;
	private var description_lb:Label;
	private var setting:Object;
	public function onLoad():Void {
		update_btn.addEventListener("click", Delegate.create(this, update));
		colour_picker_mc.setColour(setting.value);
		default_lb.text = setting.def;
		description_lb.text = setting.description;
		name_lb.text = setting.label;
	}
	private function update() {
		setting.value = "0x" + colour_picker_mc.getColour().toString(16);
	}
}
