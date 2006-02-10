import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypes extends Forms.BaseForm {
	private var controls:Array;
	private var controls_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(controls_dg);
		dataGridHandler.addTextInputColumn("type", "Control Type", restrictions);
		var DP = new Array();
		for (var control in controls) {
			var newControl = new Object();
			newControl.type = "";
			if (controls[control].type.length) {
				newControl.type = controls[control].type;
			}
			DP.push(newControl);
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
		var newControls = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Control = new Object();
			Control.type = DP[index].type;
			newControls.push(Control);
		}
		_global.left_tree.selectedNode.object.setData(new Object({controls:newControls}));
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
