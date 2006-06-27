import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryButton extends Forms.BaseForm {
	private var bgColour_mc:MovieClip;
	private var borderColour_mc:MovieClip;
	private var fontColour_mc:MovieClip;
	private var labels_ti:TextInput;
	private var commands_ti:TextInput;
	private var width_ti:TextInput;
	private var key_ti:TextInput;
	private var fontSize_ti:TextInput;
	private var currentAlert:Object;
	public function onLoad():Void {
		if ((currentAlert.bgColour != undefined) && (currentAlert.bgColour != "")) {
			bgColour_mc.setColour(currentAlert.bgColour);
		}
		if ((currentAlert.borderColour != undefined) && (currentAlert.borderColour != "")) {
			borderColour_mc.setColour(currentAlert.borderColour);
		}
		if ((currentAlert.fontColour != undefined) && (currentAlert.fontColour != "")) {
			fontColour_mc.setColour(currentAlert.fontColour);
		}
		labels_ti.text = currentAlert.labels;
		commands_ti.text = currentAlert.commands;
		width_ti.text = currentAlert.width;
		key_ti.text = currentAlert.key;
		fontSize_ti.text = currentAlert.fontSize;
		labels_ti.addEventListener("change", Delegate.create(this,changeListener));
		commands_ti.addEventListener("change", Delegate.create(this,changeListener));
		key_ti.addEventListener("change", Delegate.create(this,changeListener));
		fontSize_ti.addEventListener("change", Delegate.create(this,changeListener));
	}
	function changeListener(){
		_global.unSaved = true;
		currentAlert.labels = labels_ti.text;
		currentAlert.commands = commands_ti.text;
		currentAlert.width = width_ti.text;
		currentAlert.key = key_ti.text;
		currentAlert.fontSize = fontSize_ti.text;
	}
}
