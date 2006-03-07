import mx.controls.*;
class Forms.Project.Client.LoggingLog extends Forms.BaseForm {
	private var label_ta:TextArea;
	private var label:String;
	private var timeformat_ti:TextInput;
	private var timeformat:String;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		timeformat_ti.addEventListener("change", changeListener);
		label_ta.addEventListener("change", changeListener);		
		timeformat_ti.text = timeformat;
		label_ta.text = label;
	}
}
