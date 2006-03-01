import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100IR extends Forms.BaseForm {
	private var save_btn:Button;
	private var irs:Array;
	private var ir_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var modules:Array;
	public function onLoad() {
		var DP = new Array();
		for(var module in modules){
			if(modules[module].type =="IR"){
				DP.push({label:modules[module].number});
			}
		}		
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();		
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "0-9A-Fa-f";			
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(ir_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "Key", keyRestrictions,false);
		dataGridHandler.addTextInputColumn("avname", "AV\nName", restrictions,false);		
		dataGridHandler.addComboBoxColumn("module", "Module\nNo.", DP,false);				
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
