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
		};
		label_ti.addEventListener("change", changeListener);	
		key_ti.addEventListener("change", changeListener);		
		defaultState_ti.addEventListener("change", changeListener);
		defaultValue_ti.addEventListener("change", changeListener);		
		fontSize_ti.addEventListener("change", changeListener);
		fontColour_mc.setColour(dataObj.fontColour);
		label_ti.text = dataObj.label;
		key_ti.text = dataObj.key;
		fontSize_ti.text = dataObj.fontSize;
		defaultState_ti.text = dataObj.defaultState;
		defaultValue_ti.text = dataObj.defaultValue;
	}
	private function getData():Object {
		var newObj = new Object();
		newObj.fontColour = "0x" + fontColour_mc.getColour().toString(16);
		newObj.label = label_ti.text;
		newObj.fontSize = fontSize_ti.text;
		newObj.key = key_ti.text;
		newObj.defaultState = defaultState_ti.text;
		newObj.defaultValue = defaultValue_ti.text;
		return newObj;
	}
}
