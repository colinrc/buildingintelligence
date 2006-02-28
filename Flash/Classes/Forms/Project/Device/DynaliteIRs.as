import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.DynaliteIRs extends Forms.BaseForm {
	private var save_btn:Button;
	private var irs:Array;
	private var irs_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;	
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(irs_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);		
		dataGridHandler.addTextInputColumn("name", "Descriptions", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "Dynalite Code", restrictions,false);
		dataGridHandler.addTextInputColumn("box", "Box", restrictions, false);
		dataGridHandler.setAdvanced(_global.advanced);					
		dataGridHandler.setDataGridDataProvider(irs);
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
		_global.left_tree.selectedNode.object.setData({irs:dataGridHandler.getDataGridDataProvider()});
	}
}
