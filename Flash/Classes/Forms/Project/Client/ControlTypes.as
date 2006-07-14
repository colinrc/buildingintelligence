import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypes extends Forms.BaseForm {
	private var controls:Array;
	private var controls_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(controls_dg);
		dataGridHandler.addTextInputColumn("type", "Control Type", restrictions, false, 150);
		dataGridHandler.addHiddenColumn("id");
		var DP = new Array();
		for (var control = 0; control < controls.length; control++) {
			var newControl = new Object();
			newControl.type = "";
			if (controls[control].type.length) {
				newControl.type = controls[control].type;
				newControl.id = controls[control].id;
			}
			DP.push(newControl);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		var newControls = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var Control = new Object();
			Control.type = DP[index].type;
			Control.id = DP[index].id;
			newControls.push(Control);
		}
		dataObject.setData({controls:newControls});
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
