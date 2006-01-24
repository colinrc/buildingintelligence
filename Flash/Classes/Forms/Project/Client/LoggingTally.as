import mx.controls.*;

class Forms.Project.Client.LoggingTally extends Forms.BaseForm {
	private var label_ti:TextInput;
	private var label:String;
	private var timeformat_ti:TextInput;
	private var timeformat:String;
	public function init(){
		label_ti.text = label;
		timeformat_ti.text = timeformat;
	}
}