import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.AppsBar extends Forms.BaseForm {
	private var icons:Array;
	private var icon_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	private var dataGridHandler:Object;	
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(icon_dg);
		dataGridHandler.addTextInputColumn("name", "Icon Name", restrictions);
		var DP = new Array();		
		for (var icon in icons) {
			DP.push({name:icons[icon].name});
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function moveUp() {
		if (icon_dg.selectedIndex != undefined) {
			if (icon_dg.selectedIndex != icon_dg.length-1) {
				var tempObj = icon_dg.getItemAt(icon_dg.selectedIndex+1);
				icon_dg.replaceItemAt(icon_dg.selectedIndex+1, icon_dg.selectedItem);
				icon_dg.replaceItemAt(icon_dg.selectedIndex, tempObj);
				var tempIndex = icon_dg.selectedIndex+1;
				icon_dg.dataProvider.updateViews("change");
				icon_dg.selectedIndex = undefined;
				icon_dg.selectedIndices = undefined;
				//icon_dg.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		if (icon_dg.selectedIndex != undefined) {
			if (icon_dg.selectedIndex != 0) {
				var tempObj = icon_dg.getItemAt(icon_dg.selectedIndex-1);
				icon_dg.replaceItemAt(icon_dg.selectedIndex-1, icon_dg.selectedItem);
				icon_dg.replaceItemAt(icon_dg.selectedIndex, tempObj);
				var tempIndex = icon_dg.selectedIndex-1;
				icon_dg.dataProvider.updateViews("change");
				icon_dg.selectedIndex = undefined;
				icon_dg.selectedIndices = undefined;
				//icon_dg.selectedIndex = tempIndex;
			}
		}
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		var newIcons = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Icon = new Object();
			Icon.name = DP[index].name;
			newIcons.push(Icon);
		}
		_global.left_tree.selectedNode.object.setData({icons:newIcons});
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
