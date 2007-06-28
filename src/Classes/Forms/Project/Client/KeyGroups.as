import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.KeyGroups extends Forms.BaseForm {
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var keygroups_dg:DataGrid;
	private var keygroups:Array;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad():Void {	
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(keygroups_dg);
		dataGridHandler.addTextInputColumn("name", "Key Group Name", restrictions,false,200);
		dataGridHandler.addHiddenColumn("id");
		dataGridHandler.setDataGridDataProvider(keygroups);
		save_btn.addEventListener("click", Delegate.create(this, save));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	private function save() {
		dataObject.setData({keygroups:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
