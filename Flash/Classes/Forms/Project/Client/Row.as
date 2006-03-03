import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Row extends Forms.BaseForm {
	private var cases:String;
	private var cases_ti:TextInput;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var add_item_btn:Button;
	private var type_cmb:ComboBox;
	public function onLoad() {
		if(cases!=undefined){
			cases_ti.text = cases;
		}
		else{
			cases_ti.text ="";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteRow));
		update_btn.addEventListener("click", Delegate.create(this, updateRow));
		add_item_btn.addEventListener("click", Delegate.create(this, addItem));
	}
	public function deleteRow(){
	}
	public function updateRow(){
	}
	public function addItem(){
	}
}
