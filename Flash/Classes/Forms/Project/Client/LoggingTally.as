import mx.controls.*;
class Forms.Project.Client.LoggingTally extends Forms.BaseForm {
	private var label_ti:TextInput;
	private var label:String;
	private var timeformat_ti:TextInput;
	private var timeformat:String;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		label_ti.addEventListener("change", changeListener);
		timeformat_ti.addEventListener("change", changeListener);		
		label_ti.text = label;
		timeformat_ti.text = timeformat;
	}
}
