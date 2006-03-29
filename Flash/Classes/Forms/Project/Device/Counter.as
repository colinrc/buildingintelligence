import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Counter extends Forms.BaseForm {
	private var save_btn:Button;
	private var counters:Array;
	private var counters_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;	
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();		
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "0-9A-Fa-f";
		var maxRestrictions = new Object();		
		maxRestrictions.maxChars = 3;
		maxRestrictions.restrict = "0-9";		
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(counters_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false,150);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false,150);
		dataGridHandler.addTextInputColumn("key", "Counter\nNo.", keyRestrictions, false,60);
		dataGridHandler.addTextInputColumn("max", "Max", maxRestrictions, false,60);
		dataGridHandler.setAdvanced(_global.advanced);
		dataGridHandler.setDataGridDataProvider(counters);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
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
		dataObject.setData({counters:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
