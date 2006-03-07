import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Row extends Forms.BaseForm {
	private var cases:String;
	private var cases_ti:TextInput;
	private var type_cmb:ComboBox;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		cases_ti.addEventListener("change", changeListener);
		type_cmb.addEventListener("change", changeListener);		
		if(cases!=undefined){
			cases_ti.text = cases;
		}
		else{
			cases_ti.text ="";
		}
	}
}
