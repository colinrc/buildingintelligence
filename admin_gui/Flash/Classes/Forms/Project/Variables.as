import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Variables extends Forms.BaseForm {
	private var variables:XMLNode;
	private var variables_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var save_btn:mx.controls.Button;
	private var dataObject:Object;
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(variables_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false, 150);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false, 150);
		dataGridHandler.addTextInputColumn("command", "Init\nCommand", restrictions, false, 100);
		dataGridHandler.addTextInputColumn("extra", "Init\nExtra", restrictions, false, 100);
		var DP = new Array();
		for (var child in variables.childNodes) {
			var newVariable = new Object();
			newVariable.name = "";
			newVariable.display_name = "";
			newVariable.command = "";
			newVariable.extra = "";
			newVariable.active = "Y";
			if (variables.childNodes[child].attributes["NAME"] != undefined) {
				newVariable.name = variables.childNodes[child].attributes["NAME"];
			}
			if (variables.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newVariable.display_name = variables.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (variables.childNodes[child].attributes["INIT_COMMAND"] != undefined) {
				newVariable.command = variables.childNodes[child].attributes["INIT_COMMAND"];
			}
			if (variables.childNodes[child].attributes["INIT_EXTRA"] != undefined) {
				newVariable.extra = variables.childNodes[child].attributes["INIT_EXTRA"];
			}
			if (variables.childNodes[child].attributes["ACTIVE"] != undefined) {
				newVariable.active = variables.childNodes[child].attributes["ACTIVE"];
			}
			DP.push(newVariable);
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
	private function save():Void {
		var newVariables = new XMLNode(1, "VARIABLES");
		var DP = dataGridHandler.getDataGridDataProvider();
		dataGridHandler.clearSelection();
		for (var index = 0; index < DP.length; index++) {
			var variableNode = new XMLNode(1, "VARIABLE");
			if (DP[index].name != "") {
				variableNode.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].command != "") {
				variableNode.attributes["INIT_COMMAND"] = DP[index].command;
			}
			if (DP[index].display_name != "") {
				variableNode.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].active != "") {
				variableNode.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].extra != "") {
				variableNode.attributes["INIT_EXTRA"] = DP[index].extra;
			}
			newVariables.appendChild(variableNode);
		}
		dataObject.setData({variables:newVariables});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
