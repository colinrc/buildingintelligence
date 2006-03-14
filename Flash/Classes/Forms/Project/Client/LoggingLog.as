﻿import mx.controls.*;
class Forms.Project.Client.LoggingLog extends Forms.BaseForm {
	private var label_ta:TextArea;
	private var label:String;
	private var timeformat_cmb:ComboBox;
	private var timeformat:String;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		timeformat_cmb.addEventListener("change", changeListener);
		label_ta.addEventListener("change", changeListener);		
		if(label.length)	{
			label_ta.text = label;
		} 
		if(timeformat.length){
			timeformat_cmb.text = timeformat;
		}
	}
}
