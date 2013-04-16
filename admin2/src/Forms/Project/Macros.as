import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Macros extends Forms.BaseForm {
	private var macros:Array;
	private var macros_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(macros_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");				
		var DP = new Array();
		for (var macro in macros) {
			var newMacro = new Object();
			newMacro.name = macros[macro].name;
			newMacro.id = macros[macro].id;			
			DP.push(newMacro);
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
		var newMacros = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Macro = new Object();
			Macro.name = DP[index].name;
			Macro.id = DP[index].id;			
			newMacros.push(Macro);
		}
		dataObject.setData({macros:newMacros});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
