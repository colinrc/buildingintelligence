import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ColourEdit extends Forms.BaseForm {
	private var colour_picker_mc:MovieClip;
	private var name_lb:Label;
	private var default_lb:Label;
	private var description_lb:Label;
	private var setting:Object;
	public function onLoad():Void {
		//update_btn.addEventListener("click", Delegate.create(this, update));
		colour_picker_mc.setColour(setting.value);
		default_lb.text = setting.def;
		description_lb.text = setting.description;
		name_lb.text = setting.label;
		colour_picker_mc.setCallbackObject(this);
	}
	function onColourChange(newColour:Number) {
		setting.value = "0x" + newColour.toString(16);
		_global.unSaved = true;
	}
}
