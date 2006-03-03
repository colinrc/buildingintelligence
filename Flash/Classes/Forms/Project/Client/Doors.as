import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Doors extends Forms.BaseForm {
	private var doors:Array;
	private var doors_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function onLoad() {
		var tempKeys = _global.server_test.getKeys();
		var DPKey = new Array();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(doors_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions,false,150);
		dataGridHandler.addTextInputColumn("pos", "Position", restrictions,false,100);
		dataGridHandler.addComboBoxColumn("key", "Key", DPKey,false,100);
		dataGridHandler.addColourColumn("colour", "Colour",100);
		var DP = new Array();
		for (var door in doors) {
			var newDoor = new Object();
			if (doors[door].attributes["name"] != undefined) {
				newDoor.name = doors[door].attributes["name"];
			} else {
				newDoor.name = "";
			}
			if (doors[door].attributes["key"] != undefined) {
				newDoor.key = doors[door].attributes["key"];
			} else {
				newDoor.key = "";
			}
			if (doors[door].attributes["pos"] != undefined) {
				newDoor.pos = doors[door].attributes["pos"];
			} else {
				newDoor.pos = "";
			}
			if (doors[door].attributes["colour"] != undefined) {
				newDoor.colour = doors[door].attributes["colour"];
			} else {
				newDoor.colour = "";
			}
			DP.push(newDoor);
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
		var newDoors = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var item = new XMLNode(1, "door");
			if (DP[index].name != "") {
				item.attributes["name"] = DP[index].name;
			}
			if (DP[index].key != "") {
				item.attributes["key"] = DP[index].key;
			}
			if (DP[index].pos != "") {
				item.attributes["pos"] = DP[index].pos;
			}
			if (DP[index].colour != "") {
				item.attributes["colour"] = DP[index].colour;
			}
			newDoors.push(item);
		}
		_global.left_tree.selectedNode.object.setData({doors:newDoors});
		_global.needSave();						
	}
}
