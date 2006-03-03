import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Window extends Forms.BaseForm {
	private var tabs:Array;
	private var tab_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(tab_dg);
		dataGridHandler.addTextInputColumn("name", "Tab Name", restrictions,false,150);
		var DP = new Array();
		for (var tab in tabs) {
			var newTab = new Object();
			newTab.name = tabs[tab].name;
			DP.push(newTab);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function moveUp() {
		if (tab_dg.selectedIndex != undefined) {
			if (tab_dg.selectedIndex != tab_dg.length - 1) {
				var tempObj = tab_dg.getItemAt(tab_dg.selectedIndex + 1);
				tab_dg.replaceItemAt(tab_dg.selectedIndex + 1, tab_dg.selectedItem);
				tab_dg.replaceItemAt(tab_dg.selectedIndex, tempObj);
				var tempIndex = tab_dg.selectedIndex + 1;
				tab_dg.selectedIndex = undefined;
				tab_dg.selectedIndices = undefined;
				tab_dg.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		if (tab_dg.selectedIndex != undefined) {
			if (tab_dg.selectedIndex != 0) {
				var tempObj = tab_dg.getItemAt(tab_dg.selectedIndex - 1);
				tab_dg.replaceItemAt(tab_dg.selectedIndex - 1, tab_dg.selectedItem);
				tab_dg.replaceItemAt(tab_dg.selectedIndex, tempObj);
				var tempIndex = tab_dg.selectedIndex - 1;
				tab_dg.selectedIndex = undefined;
				tab_dg.selectedIndices = undefined;
				tab_dg.selectedIndex = tempIndex;
			}
		}
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		var newTabs = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var Tab = new Object();
			Tab.name = DP[index].name;
			newTabs.push(Tab);
		}
		_global.left_tree.selectedNode.object.setData(new Object({tabs:newTabs}));
		_global.needSave();						
		_global.refreshTheTree();		
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);
	}
}
