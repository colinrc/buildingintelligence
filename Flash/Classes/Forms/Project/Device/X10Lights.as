import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.X10Lights extends Forms.BaseForm {
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
		dataGridHandler.addTextInputColumn("name", "Description", restrictions,false);		
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);		
		dataGridHandler.addComboBoxColumn("x10", "Housecode", [{label:"A"},{label:"B"},{label:"C"},{label:"D"},{label:"E"},{label:"F"},{label:"G"},{label:"H"},{label:"I"},{label:"J"},{label:"K"},{label:"L"},{label:"M"},{label:"N"},{label:"O"},{label:"P"}],false);				
		dataGridHandler.addComboBoxColumn("key", "Unit Number", [{label:"1"},{label:"2"},{label:"3"},{label:"4"},{label:"5"},{label:"6"},{label:"7"},{label:"8"},{label:"9"},{label:"10"},{label:"11"},{label:"12"},{label:"13"},{label:"14"},{label:"15"},{label:"16"}],false);
		dataGridHandler.addTextInputColumn("power", "Power", restrictions,true);
		dataGridHandler.setDataGridDataProvider(lights);
		dataGridHandler.setAdvanced(_global.advanced);
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