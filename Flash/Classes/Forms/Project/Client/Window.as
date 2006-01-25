import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Window extends Forms.BaseForm {
	private var tabs:Array;
	private var tab_li:List;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		for (var tab in tabs) {
			tab_li.addItem({label:tabs[tab].name});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		tab_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function moveUp() {
		if (tab_li.selectedIndex != undefined) {
			if (tab_li.selectedIndex != tab_li.length-1) {
				var tempObj = tab_li.getItemAt(tab_li.selectedIndex+1);
				tab_li.replaceItemAt(tab_li.selectedIndex+1, tab_li.selectedItem);
				tab_li.replaceItemAt(tab_li.selectedIndex, tempObj);
				var tempIndex = tab_li.selectedIndex+1;
				tab_li.selectedIndex = undefined;
				tab_li.selectedIndices = undefined;
				tab_li.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		if (tab_li.selectedIndex != undefined) {
			if (tab_li.selectedIndex != 0) {
				var tempObj = tab_li.getItemAt(tab_li.selectedIndex-1);
				tab_li.replaceItemAt(tab_li.selectedIndex-1, tab_li.selectedItem);
				tab_li.replaceItemAt(tab_li.selectedIndex, tempObj);
				var tempIndex = tab_li.selectedIndex-1;
				tab_li.selectedIndex = undefined;
				tab_li.selectedIndices = undefined;
				tab_li.selectedIndex = tempIndex;
			}
		}
	}
	private function deleteItem() {
		tab_li.removeItemAt(tab_li.selectedIndex);
		tab_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		tab_li.addItem({label:name_ti.text});
		tab_li.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newTabs = new Array();
		for (var index = 0; index<tab_li.length; index++) {
			var Tab = new Object();
			Tab.name = tab_li.getItemAt(index).label;
			newTabs.push(Tab);
		}
		_global.left_tree.selectedNode.object.setData(new Object({tabs:newTabs}));
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
