import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryLabel extends Forms.BaseForm {
	private var fontColour_mc:MovieClip;
	private var label_ti:TextInput;
	private var key_ti:TextInput;
	private var defaultState_ti:TextInput;
	private var defaultValue_ti:TextInput;
	private var fontSize_ti:TextInput;
	private var dataObj:Object;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
			dataObj.label = label_ti.text;
			dataObj.key = key_ti.text;
			dataObj.fontSize = fontSize_ti.text ;
			dataObj.defaultState = defaultState_ti.text;
			dataObj.defaultValue = defaultValue_ti.text;
		};
		if ((dataObj.fontColour != undefined) && (dataObj.fontColour != "")) {
			fontColour_mc.setColour(dataObj.fontColour);
		}
		label_ti.text = dataObj.label;
		key_ti.text = dataObj.key;
		fontSize_ti.text = dataObj.fontSize;
		defaultState_ti.text = dataObj.defaultState;
		defaultValue_ti.text = dataObj.defaultValue;
		label_ti.addEventListener("change", changeListener);	
		key_ti.addEventListener("change", changeListener);		
		defaultState_ti.addEventListener("change", changeListener);
		defaultValue_ti.addEventListener("change", changeListener);		
		fontSize_ti.addEventListener("change", changeListener);
	}
}
