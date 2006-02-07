import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Server extends Forms.BaseForm {
	private var devices:Array;
	private var description:String;
	private var description_ta:TextArea;
	private var devices_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		description_ta.text = description;
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(devices_dg);
		dataGridHandler.addComboBoxColumn("device_type", "Device Type", [{label:"IR_LEARNER"}, {label:"PELCO"}, {label:"GC100"}, {label:"TUTONDO"}, {label:"DYNALITE"}, {label:"COMFORT"}, {label:"RAW_CONNECTION"}, {label:"HAL"}, {label:"OREGON"}, {label:"KRAMER"}, {label:"CBUS"}]);
		dataGridHandler.addTextInputColumn("description", "Description", restrictions);
		var DP = new Array();
		for (var device in devices) {
			var newDevice = new Object();
			newDevice.device_type = devices[device].device_type;
			newDevice.description = devices[device].description;
			DP.push(newDevice);
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
		var newDevices = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var device = new Object();
			device.device_type = DP[index].device_type;
			device.description = DP[index].description;
			newDevices.push(device);
		}
		_global.left_tree.selectedNode.object.setData({description:description_ta.text, devices:newDevices});
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for (var child in _global.left_tree.selectedNode.childNodes) {
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1, "Placeholder"));
		for (var child in newNode.childNodes) {
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);
	}
}
