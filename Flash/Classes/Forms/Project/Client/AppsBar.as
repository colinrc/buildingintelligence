import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.AppsBar extends Forms.BaseForm {
	private var icons:Array;
	private var icon_li:List;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		for (var icon in icons) {
			icon_li.addItem({label:icons[icon].name});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		icon_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function moveUp() {
		if (icon_li.selectedIndex != undefined) {
			if (icon_li.selectedIndex != icon_li.length-1) {
				var tempObj = icon_li.getItemAt(icon_li.selectedIndex+1);
				icon_li.replaceItemAt(icon_li.selectedIndex+1, icon_li.selectedItem);
				icon_li.replaceItemAt(icon_li.selectedIndex, tempObj);
				var tempIndex = icon_li.selectedIndex+1;
				icon_li.selectedIndex = undefined;
				icon_li.selectedIndices = undefined;
				icon_li.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		if (icon_li.selectedIndex != undefined) {
			if (icon_li.selectedIndex != 0) {
				var tempObj = icon_li.getItemAt(icon_li.selectedIndex-1);
				icon_li.replaceItemAt(icon_li.selectedIndex-1, icon_li.selectedItem);
				icon_li.replaceItemAt(icon_li.selectedIndex, tempObj);
				var tempIndex = icon_li.selectedIndex-1;
				icon_li.selectedIndex = undefined;
				icon_li.selectedIndices = undefined;
				icon_li.selectedIndex = tempIndex;
			}
		}
	}
	private function deleteItem() {
		icon_li.removeItemAt(icon_li.selectedIndex);
		icon_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		icon_li.addItem({label:name_ti.text});
		icon_li.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newIcons = new Array();
		for (var index = 0; index<icon_li.length; index++) {
			var Icon = new Object();
			Icon.name = icon_li.getItemAt(index).label;
			newIcons.push(Icon);
		}
		_global.left_tree.selectedNode.object.setData(new Object({icons:newIcons}));
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
