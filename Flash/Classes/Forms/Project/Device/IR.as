import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.IR extends Forms.BaseForm {
	private var save_btn:Button;
	private var irs:Array;
	private var ir_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(ir_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "Key", restrictions,false);
		dataGridHandler.addTextInputColumn("avname", "AV Name", restrictions,false);		
		dataGridHandler.setAdvanced(false);//Debug						
		var DP = new Array();		
		for (var ir in irs) {
			var newIr = new Object();
			newIr.name = "";
			newIr.key = "";
			newIr.avname = "";
			if (irs[ir].attributes["NAME"] != undefined) {
				newIr.name = irs[ir].attributes["NAME"];
			}
			if (irs[ir].attributes["KEY"] != undefined) {
				newIr.key = irs[ir].attributes["KEY"];
			}
			if (irs[ir].attributes["AV_NAME"] != undefined) {
				newIr.avname = irs[ir].attributes["AV_NAME"];
			}
			DP.push(newIr);
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
		dataGridHandler.clearSelection();		
		var newIrs = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var irNode = new XMLNode(1, "IR");
			if (DP[index].name != "") {
				irNode.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].key != "") {
				irNode.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].avname != "") {
				irNode.attributes["AV_NAME"] = DP[index].avname;
			}
			newIrs.push(irNode);
		}
		_global.left_tree.selectedNode.object.setData({irs:newIrs});
	}
}
