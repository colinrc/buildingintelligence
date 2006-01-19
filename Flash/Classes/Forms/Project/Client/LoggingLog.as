import mx.controls.*;
class Forms.Project.Client.LoggingLog{
	private var label_ta:TextArea;
	private var label:String;
	private var timeformat_ti:TextInput;
	private var timeformat:String;
	public function init(){
		timeformat_ti.text = timeformat;
		label_ta.text = label;
	}
}