import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Analogue extends Forms.BaseForm {
	private var save_btn:Button;
	private var analogues:Array;
	private var analogues_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(analogues_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("display_name", "eLife Name", restrictions);
		dataGridHandler.addTextInputColumn("key", "Key", restrictions);
		dataGridHandler.addCheckColumn("active", "Active", values);
		var DP = new Array();
		for (var analogue in analogues) {
			var newAnalogue = new Object();
			newAnalogue.key = "";
			newAnalogue.name = "";
			newAnalogue.display_name = "";
			newAnalogue.active = "Y";			
			if (analogues[analogue].attributes["KEY"] != undefined) {
				newAnalogue.key = analogues[analogue].attributes["KEY"];
			}
			if (analogues[analogue].attributes["NAME"] != undefined) {
				newAnalogue.name = analogues[analogue].attributes["NAME"];
			}	
			if (analogues[analogue].attributes["DISPLAY_NAME"] != undefined) {
				newAnalogue.display_name = analogues[analogue].attributes["DISPLAY_NAME"];
			}
			if (analogues[analogue].attributes["ACTIVE"] != undefined) {
				newAnalogue.active = analogues[analogue].attributes["ACTIVE"];
			}			
			DP.push(newAnalogue);
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
		var newAnalogues = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "ANALOG");
			if (DP[index].key != "") {
				item.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].name != "") {
				item.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].active != "") {
				item.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].display_name != "") {
				item.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			newAnalogues.push(item);
		}
		_global.left_tree.selectedNode.object.setData({analogues:newAnalogues});
	}
}
