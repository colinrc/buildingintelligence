import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.StatusBar extends Forms.BaseForm {
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
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
		dataGridHandler.addTextInputColumn("name", "Group Name", restrictions, false, 150);
		dataGridHandler.addHiddenColumn("id");
		var DP = new Array();
		for (var group = 0; group < groups.length; group++) {
			DP.push({name:groups[group].name, id:groups[group].id});
		}
		dataGridHandler.setDataGridDataProvider(DP);
		save_btn.addEventListener("click", Delegate.create(this, save));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	private function moveUp() {
		if (groups_dg.selectedIndex != undefined) {
			if (groups_dg.selectedIndex != groups_dg.length - 1) {
				var tempObj = groups_dg.getItemAt(groups_dg.selectedIndex + 1);
				groups_dg.replaceItemAt(groups_dg.selectedIndex + 1, groups_dg.selectedItem);
				groups_dg.replaceItemAt(groups_dg.selectedIndex, tempObj);
				var tempIndex = groups_dg.selectedIndex + 1;
				groups_dg.dataProvider.updateViews("change");
				groups_dg.selectedIndex = undefined;
				groups_dg.selectedIndices = undefined;
				//groups_dg.selectedIndex = tempIndex;
			}
			_global.unSaved = true;
		}
	}
	private function moveDown() {
		if (groups_dg.selectedIndex != undefined) {
			if (groups_dg.selectedIndex != 0) {
				var tempObj = groups_dg.getItemAt(groups_dg.selectedIndex - 1);
				groups_dg.replaceItemAt(groups_dg.selectedIndex - 1, groups_dg.selectedItem);
				groups_dg.replaceItemAt(groups_dg.selectedIndex, tempObj);
				var tempIndex = groups_dg.selectedIndex - 1;
				groups_dg.dataProvider.updateViews("change");
				groups_dg.selectedIndex = undefined;
				groups_dg.selectedIndices = undefined;
				//groups_dg.selectedIndex = tempIndex;
			}
			_global.unSaved = true;
		}
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
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
