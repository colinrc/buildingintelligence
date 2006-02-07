import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Parameters extends Forms.BaseForm {
	private var node:XMLNode;
	private var params_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;	
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(params_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("value", "Value", restrictions);
		var DP = new Array();				
		for (var child in node.childNodes) {
			var newParam = new Object();
			newParam.name = "";
			newParam.value = "";
			if (node.childNodes[child].attributes["NAME"] != undefined) {
				newParam.name = node.childNodes[child].attributes["NAME"];
			}
			if (node.childNodes[child].attributes["VALUE"] != undefined) {
				newParam.value = node.childNodes[child].attributes["VALUE"];
			}
			DP.push(newParam);
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
	public function getData():Object {
		var parameters = new XMLNode(1, "PARAMETERS");
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "ITEM");
			if (DP[index].name != "") {
				item.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].value != "") {
				item.attributes["VALUE"] = DP[index].value;
			}
			parameters.appendChild(item);
		}
		return parameters;
	}
}
