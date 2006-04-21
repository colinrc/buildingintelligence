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
	private var dataObj:Object;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		labels_ti.addEventListener("change", changeListener);
		commands_ti.addEventListener("change", changeListener);
		key_ti.addEventListener("change", changeListener);
		fontSize_ti.addEventListener("change", changeListener);
		if ((dataObj.bgColour != undefined) && (dataObj.bgColour != "")) {
			bgColour_mc.setColour(dataObj.bgColour);
		}
		if ((dataObj.borderColour != undefined) && (dataObj.borderColour != "")) {
			borderColour_mc.setColour(dataObj.borderColour);
		}
		if ((dataObj.fontColour != undefined) && (dataObj.fontColour != "")) {
			fontColour_mc.setColour(dataObj.fontColour);
		}
		labels_ti.text = dataObj.labels;
		commands_ti.text = dataObj.commands;
		width_ti.text = dataObj.width;
		key_ti.text = dataObj.key;
		fontSize_ti.text = dataObj.fontSize;
	}
	private function getData():Object {
		var newObj = new Object();
		newObj.bgColour = "0x" + bgColour_mc.getColour().toString(16);
		newObj.borderColour = "0x" + borderColour_mc.getColour().toString(16);
		newObj.fontColour = "0x" + fontColour_mc.getColour().toString(16);
		newObj.labels = labels_ti.text;
		newObj.commands = commands_ti.text;
		newObj.width = width_ti.text;
		newObj.key = key_ti.text;
		newObj.fontSize = fontSize_ti.text;
		return newObj;
	}
}
