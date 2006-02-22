import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Catalogue extends Forms.BaseForm {
	private var name:String;
	private var items:Array;
	private var items_dg:DataGrid;
	private var dataGridHandler:Object;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		name_ti.text = name;
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(items_dg);
		dataGridHandler.addTextInputColumn("code", "Code", restrictions,false);
		dataGridHandler.addTextInputColumn("value", "Value", restrictions,false);
		dataGridHandler.setAdvanced(false);//Debug						
		var DP = new Array();
		for (var item in items) {
			var newItem = new Object();
			newItem.code = "";
			newItem.value = "";
			if (items[item].attributes["CODE"] != undefined) {
				newItem.code = items[item].attributes["CODE"];
			}
			if (items[item].attributes["VALUE"] != undefined) {
				newItem.value = items[item].attributes["VALUE"];
			}
			DP.push(newItem);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newRow));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newRow() {
		dataGridHandler.addBlankRow();
	}
	private function save():Void {
		dataGridHandler.clearSelection();		
		var newItems = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "ITEM");
			if (DP[index].code != undefined) {
				item.attributes["CODE"] = DP[index].code;
			}
			if (DP[index].value != undefined) {
				item.attributes["VALUE"] = DP[index].value;
			}
			newItems.push(item);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData({name:name_ti.text, items:newItems});
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
