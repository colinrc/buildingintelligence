import mx.controls.*;
class Forms.Project.Client.LoggingLog extends Forms.BaseForm {
	private var label_ta:TextArea;
	private var label:String;
	private var timeformat_ti:TextInput;
	private var timeformat:String;
	public function onLoad() {
		timeformat_ti.text = timeformat;
		label_ta.text = label;
	}
}
