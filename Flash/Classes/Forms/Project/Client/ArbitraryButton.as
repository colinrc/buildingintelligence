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
		bgColour_mc.setColour(dataObj.bgColour);
		borderColour_mc.setColour(dataObj.borderColour);
		fontColour_mc.setColour(dataObj.fontColour);
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
