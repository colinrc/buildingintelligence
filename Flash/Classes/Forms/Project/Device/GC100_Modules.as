import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_Modules extends Forms.BaseForm {
	private var modules:Array;
	private var modules_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(modules_dg);
		dataGridHandler.addTextInputColumn("name", "Module Name", restrictions);
		dataGridHandler.addComboBoxColumn("type", "Module Type", [{label:"GC100_IR"}, {label:"GC100_Relay"}]);
		var DP = new Array();
		for (var module in modules) {
			var newModule = new Object();
			newModule.name = "";
			newModule.type = "";
			if (modules[module].name != undefined) {
				newModule.name = modules[module].name;
			}
			if (modules[module].type != undefined) {
				newModule.type = modules[module].type;
			}
			DP.push(newModule);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		var newModules = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var module = new Object();
			module.type = DP[index].type;
			module.name = DP[index].name;
			newModules.push(module);
		}
		_global.left_tree.selectedNode.object.setData({modules:newModules});
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
