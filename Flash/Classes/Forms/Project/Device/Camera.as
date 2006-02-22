import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Camera extends Forms.BaseForm {
	private var cameras:Array;
	private var cameras_dg:DataGrid;
	private var save_btn:Button;
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
		dataGridHandler.setDataGrid(cameras_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "Camera Zone", restrictions,false);
		dataGridHandler.addTextInputColumn("zoom", "Camera Zoom", restrictions,false);		
		dataGridHandler.addCheckColumn("active", "Active", values,false);
		dataGridHandler.setAdvanced(false);//Debug						
		var DP = new Array();
		for (var camera in cameras) {
			var newCamera = new Object();
			newCamera.active = "Y";
			newCamera.key = "";
			newCamera.display_name = "";
			newCamera.zoom = "";
			if (cameras[camera].attributes["KEY"] != undefined) {
				newCamera.key = cameras[camera].attributes["KEY"];
			}
			if (cameras[camera].attributes["DISPLAY_NAME"] != undefined) {
				newCamera.display_name = cameras[camera].attributes["DISPLAY_NAME"];
			}
			if (cameras[camera].attributes["ZOOM"] != undefined) {
				newCamera.zoom = cameras[camera].attributes["ZOOM"];
			}
			if (cameras[camera].attributes["ACTIVE"] != undefined) {
				newCamera.active = cameras[camera].attributes["ACTIVE"];
			}
			DP.push(newCamera);
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
		var newCameras = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "CAMERA");
			if (DP[index].key != "") {
				item.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].display_name != "") {
				item.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].active != "") {
				item.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].zoom != "") {
				item.attributes["ZOOM"] = DP[index].zoom;
			}
			newCameras.push(item);
		}
		_global.left_tree.selectedNode.object.setData({cameras:newCameras});
	}
}
