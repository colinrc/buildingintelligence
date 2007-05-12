import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Row extends Forms.BaseForm {
	private var object:Object;
	private var cases_ti:TextInput;
	private var type_cmb:ComboBox;
	private var delete_btn:Button;
	private var add_item_btn:Button;
	public function onLoad() {
		cases_ti.addEventListener("change", Delegate.create(this, changeListener));
		type_cmb.addEventListener("change", Delegate.create(this, changeListener));
		if (object.cases != undefined) {
			cases_ti.text = object.cases;
		} else {
			cases_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteRow));
		add_item_btn.addEventListener("click", Delegate.create(this, addItem));
	}
	public function deleteRow() {
	}
	public function addItem() {
	}
	public function changeListener(eventObject:Object) {
			_global.unSaved = true;
			object.cases = cases_ti.text;
	};	
}
