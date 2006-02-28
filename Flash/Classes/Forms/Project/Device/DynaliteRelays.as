import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.DynaliteRelays extends Forms.BaseForm {
	private var save_btn:Button;
	private var lights:Array;
	private var lights_dg:DataGrid;
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
		dataGridHandler.setDataGrid(lights_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);		
		dataGridHandler.addTextInputColumn("name", "Descriptions", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "Dynalite Code", restrictions,false);
		dataGridHandler.addTextInputColumn("area", "Area", restrictions,false);		
		dataGridHandler.addTextInputColumn("bla", "BLA", restrictions, true);		
		dataGridHandler.addTextInputColumn("power", "Power Rating", restrictions,true);
		dataGridHandler.addHiddenColumn("relay");
		dataGridHandler.setAdvanced(_global.advanced);					
		dataGridHandler.setDataGridDataProvider(lights);
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
		_global.left_tree.selectedNode.object.setData({lights:dataGridHandler.getDataGridDataProvider()});
	}
}
