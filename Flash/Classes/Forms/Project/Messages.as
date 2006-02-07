import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Messages extends Forms.BaseForm {
	private var node:XMLNode;
	private var items_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(items_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("value", "Value", restrictions);		
		var DP = new Array();		
		for (var child in node.childNodes) {
			var newMessage = new Object();
			newMessage.name = node.childNodes[child].attributes["NAME"];
			newMessage.value = node.childNodes[child].attributes["VALUE"];
			DP.push(newMessage);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}	
	private function getData():XMLNode {
		var newItems = new XMLNode(1, "CALENDAR_MESSAGES");
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "ITEM");
			item.attributes["NAME"] = DP[index].name;
			item.attributes["VALUE"] = DP[index].value;
			newItems.appendChild(item);
		}
		return newItems;
	}
}
