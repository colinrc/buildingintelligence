import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryLabel extends Forms.BaseForm {
	private var fontColour_mc:MovieClip;
	private var label_ti:TextInput;
	private var key_cmb:ComboBox;
	private var defaultState_ti:TextInput;
	private var defaultValue_ti:TextInput;
	private var fontSize_ti:TextInput;
	private var currentAlert:Object;
	public function onLoad():Void {
		if ((currentAlert.fontColour != undefined) && (currentAlert.fontColour != "")) {
			fontColour_mc.setColour(currentAlert.fontColour);
		}
		fontColour_mc.setCallbackObject(this);
		label_ti.text = currentAlert.label;
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
		fontSize_ti.text = currentAlert.fontSize;
		defaultState_ti.text = currentAlert.defaultState;
		defaultValue_ti.text = currentAlert.defaultValue;
		label_ti.addEventListener("change", Delegate.create(this,changeListener));
		key_cmb.addEventListener("change", Delegate.create(this,changeListener));		
		defaultState_ti.addEventListener("change", Delegate.create(this,changeListener));
		defaultValue_ti.addEventListener("change", Delegate.create(this,changeListener));
		fontSize_ti.addEventListener("change", Delegate.create(this,changeListener));
	}
	function changeListener(){
		_global.unSaved = true;
		currentAlert.label = label_ti.text;
		currentAlert.key = key_cmb.text;
		currentAlert.fontSize = fontSize_ti.text ;
		currentAlert.defaultState = defaultState_ti.text;
		currentAlert.defaultValue = defaultValue_ti.text;
	}
	function onColourChange(newColour:Number) {
		currentAlert.fontColour = "0x" + newColour.toString(16).toUpperCase();
		_global.unSaved = true;
	}
}
