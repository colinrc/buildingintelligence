import mx.controls.*

class Forms.Project.Settings.StringEdit extends Forms.BaseForm {

	private var label_lb:Label;
	private var variable_ti:TextInput;
	
	private var label:String;
	private var variable:String;
	
	function StringEdit() {
	}
	
	public function init():Void {
		label_lb.text = label + ":";
		variable_ti.text = variable;
	}
}