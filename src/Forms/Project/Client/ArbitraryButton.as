import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryButton extends Forms.BaseForm {
	private var bgColour_mc:MovieClip;
	private var borderColour_mc:MovieClip;
	private var fontColour_mc:MovieClip;
	private var label_ti:TextInput;
	private var label2_ti:TextInput;
	private var command_cmb:ComboBox;
	private var command2_cmb:ComboBox;
	private var width_ti:TextInput;
	private var key_cmb:ComboBox;
	private var fontSize_ti:TextInput;
	private var currentAlert:Object;
	public function onLoad():Void {
		var DPControl = new Array();
		DPControl.push({label:"channel"});
		DPControl.push({label:"down"});
		DPControl.push({label:"goto"});
		DPControl.push({label:"keyPress"});
		DPControl.push({label:"on"});
		DPControl.push({label:"off"});
		DPControl.push({label:"pan"});
		DPControl.push({label:"pause"});
		DPControl.push({label:"tilt"});
		DPControl.push({label:"volume"});
		DPControl.push({label:"send_audio_command"});
		DPControl.push({label:"src"});
		//		DPControl.push({label:"state"});
		DPControl.push({label:"up"});
		command_cmb.dataProvider = DPControl;
		command2_cmb.dataProvider = DPControl;
		for (var tempIcon = 0; tempIcon < command_cmb.dataProvider.length; tempIcon++) {
			if (command_cmb.dataProvider[tempIcon].label == currentAlert.command) {
				command_cmb.selectedIndex = tempIcon;
				break;
			}
		}
		for (var tempIcon = 0; tempIcon < command2_cmb.dataProvider.length; tempIcon++) {
			if (command2_cmb.dataProvider[tempIcon].label == currentAlert.command2) {
				command2_cmb.selectedIndex = tempIcon;
				break;
			}
		}
		var tempKeys = _global.serverDesign.getKeys();
		var DPKey = new Array();
		DPKey.push({label:""});
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		key_cmb.dataProvider = DPKey;
		key_cmb.text = currentAlert.key;
		if ((currentAlert.bgColour != undefined) && (currentAlert.bgColour != "")) {
			bgColour_mc.setColour(currentAlert.bgColour);
		}
		if ((currentAlert.borderColour != undefined) && (currentAlert.borderColour != "")) {
			borderColour_mc.setColour(currentAlert.borderColour);
		}
		if ((currentAlert.fontColour != undefined) && (currentAlert.fontColour != "")) {
			fontColour_mc.setColour(currentAlert.fontColour);
		}
		label_ti.text = currentAlert.label;
		label2_ti.text = currentAlert.label2;
		width_ti.restrict = "0-9";
		width_ti.text = currentAlert.width;
		fontSize_ti.restrict = "0-9";
		fontSize_ti.text = currentAlert.fontSize;
		fontColour_mc.setCallbackObject(this);
		borderColour_mc.setCallbackObject(this);
		bgColour_mc.setCallbackObject(this);
		label_ti.addEventListener("change", Delegate.create(this, changeListener));
		command_cmb.addEventListener("change", Delegate.create(this, changeListener));
		command2_cmb.addEventListener("change", Delegate.create(this, changeListener));
		label2_ti.addEventListener("change", Delegate.create(this, changeListener));
		key_cmb.addEventListener("change", Delegate.create(this, changeListener));
		fontSize_ti.addEventListener("change", Delegate.create(this, changeListener));
	}
	function changeListener() {
		_global.unSaved = true;
		currentAlert.label = label_ti.text;
		currentAlert.label2 = label2_ti.text;
		currentAlert.command = command_cmb.text;
		currentAlert.command2 = command2_cmb.text;
		currentAlert.width = width_ti.text;
		currentAlert.key = key_cmb.text;
		currentAlert.fontSize = fontSize_ti.text;
	}
	function onColourChange(newColour:Number) {
		currentAlert.fontColour = "0x" + fontColour_mc.getColour().toString(16).toUpperCase();
		currentAlert.borderColour = "0x" + borderColour_mc.getColour().toString(16).toUpperCase();
		currentAlert.bgColour = "0x" + bgColour_mc.getColour().toString(16).toUpperCase();
		_global.unSaved = true;
	}
}
