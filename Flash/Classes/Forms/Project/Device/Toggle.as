import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Toggle extends Forms.BaseForm {
	private var save_btn:Button;
	private var toggle_type:String;
	private var toggles:Array;
	private var toggle_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var title_lb:Label;
	public function onLoad() {
		switch (toggle_type) {
		case "TOGGLE_INPUT" :
			title_lb.text = "Toggle Inputs:";
			var keyType = "Input\nNumber";
			break;
		case "TOGGLE_OUTPUT" :
			title_lb.text = "Toggle Outputs:";
			var keyType = "Output\nNumber";
			break;
		case "PULSE_OUTPUT" :
			title_lb.text = "Pulse Outputs:";
			var keyType = "Output\nNumber";
			break;
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "0-9A-Fa-f";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(toggle_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false, 150);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false, 150);
		dataGridHandler.addTextInputColumn("key", keyType, restrictions, false, 40);
		dataGridHandler.addTextInputColumn("power", "Power\nRating", restrictions, true, 50);
		dataGridHandler.setAdvanced(_global.advanced);
		dataGridHandler.setDataGridDataProvider(toggles);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function setAdvanced() {
		if (_global.advanced) {
			dataGridHandler.setAdvanced(_global.advanced);
		} else {
			dataGridHandler.setAdvanced(_global.advanced);
		}
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		_global.needSave();				
		dataGridHandler.clearSelection();
		_global.left_tree.selectedNode.object.setData(new Object({toggles:dataGridHandler.getDataGridDataProvider()}));
	}
}
