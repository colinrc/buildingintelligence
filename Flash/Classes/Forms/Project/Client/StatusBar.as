import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.StatusBar extends Forms.BaseForm {
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var groups_dg:DataGrid;
	private var groups:Array;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad():Void {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(groups_dg);
		dataGridHandler.addTextInputColumn("name", "Group Name", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");
		var DP = new Array();
		for (var group in groups) {
			DP.push({name:groups[group].name,id:groups[group].id});
		}
		dataGridHandler.setDataGridDataProvider(DP);
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
		var newGroups = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var Group = new Object();
			if (DP[index].name.length) {
				Group.name = DP[index].name;
				Group.id = DP[index].id;				
			}
			newGroups.push(Group);
		}
		dataObject.setData({groups:newGroups});
		_global.saveFile("Project");
	}
}
