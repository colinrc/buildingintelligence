import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_Modules extends Forms.BaseForm {
	private var modules:Array;
	private var modules_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(modules_dg);
		dataGridHandler.addTextInputColumn("name", "Module\nName", restrictions);
		dataGridHandler.addComboBoxColumn("type", "Module\nType", [{label:"IR"}, {label:"RELAY"}]);
		dataGridHandler.addTextInputColumn("number", "Module\nNo.", restrictions);
		dataGridHandler.setAdvanced(_global.advanced);			
		dataGridHandler.setDataGridDataProvider(modules);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
	}
	public function setAdvanced(){
		if(_global.advanced){
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
		dataGridHandler.clearSelection();		
		_global.left_tree.selectedNode.object.setData({modules:dataGridHandler.getDataGridDataProvider()});
	}
}
