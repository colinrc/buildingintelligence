import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.ToggleMonitor extends Forms.BaseForm {
	private var monitors:Array;
	private var monitors_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(monitors_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false);
		dataGridHandler.addTextInputColumn("key", "?", restrictions, false);
		dataGridHandler.addCheckColumn("active", "Active", values, false);
		dataGridHandler.setAdvanced(false);
		//Debug						
		dataGridHandler.setDataGridDataProvider(monitors);
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
		dataGridHandler.clearSelection();
		var DP = dataGridHandler.getDataGridDataProvider();
		_global.left_tree.selectedNode.object.setData({monitors:DP});
	}
}
