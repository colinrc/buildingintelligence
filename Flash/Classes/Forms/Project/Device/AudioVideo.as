import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.AudioVideo extends Forms.BaseForm {
	private var audiovideos:Array;
	private var container:String;
	private var inputs_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var title_lb:Label;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(inputs_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);
		var itemType:String;
		switch (container) {
		case "HAL" :
		case "TUTONDO" :
			itemType = "Audio Zone";
			title_lb.text = "Audio Zones";
			break;
		case "KRAMER" :
			itemType = "AV Zone";
			title_lb.text = "AV Zones";
			break;
		}
		dataGridHandler.addTextInputColumn("key", itemType, restrictions,false);
		dataGridHandler.addCheckColumn("active", "Active", values,false);
		dataGridHandler.setAdvanced(false);//Debug						
		var DP = new Array();
		for (var audiovideo in audiovideos) {
			var newAudiovideo = new Object();
			newAudiovideo.key = "";
			newAudiovideo.display_name = "";
			newAudiovideo.active = "Y";
			if (audiovideos[audiovideo].attributes["KEY"] != undefined) {
				newAudiovideo.key = audiovideos[audiovideo].attributes["KEY"];
			}
			if (audiovideos[audiovideo].attributes["DISPLAY_NAME"] != undefined) {
				newAudiovideo.display_name = audiovideos[audiovideo].attributes["DISPLAY_NAME"];
			}
			if (audiovideos[audiovideo].attributes["ACTIVE"] != undefined) {
				newAudiovideo.active = audiovideos[audiovideo].attributes["ACTIVE"];
			}
			DP.push(newAudiovideo);
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
		var itemType:String;
		switch (container) {
		case "HAL" :
		case "TUTONDO" :
			itemType = "AUDIO_OUTPUT";
			break;
		case "KRAMER" :
			itemType = "AV_OUTPUT";
			break;
		}
		var inputs = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, itemType);
			if (DP[index].key != "") {
				item.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].display_name != "") {
				item.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].active != "") {
				item.attributes["ACTIVE"] = DP[index].active;
			}
			inputs.push(item);
		}
		_global.left_tree.selectedNode.object.setData({audiovideos:inputs});
	}
}
