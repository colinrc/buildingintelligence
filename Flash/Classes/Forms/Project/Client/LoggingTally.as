import mx.controls.*;
class Forms.Project.Client.LoggingTally extends Forms.BaseForm {
	private var label_ti:TextInput;
	private var label:String;
	private var timeformat_cmb:ComboBox;
	private var timeformat:String;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		label_ti.addEventListener("change", changeListener);
		timeformat_cmb.addEventListener("change", changeListener);		
		if(label.length)	{
			label_ti.text = label;
		} 
		if(timeformat.length){
			timeformat_cmb.text = timeformat;
		}
	}
}
