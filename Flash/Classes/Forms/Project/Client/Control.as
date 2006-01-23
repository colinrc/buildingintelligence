import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Control {
	private var type:String;
	private var rows:Array;
	private var rows_li:List;
	private var type_ti:TextInput;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var save_btn:Button;
	public function init() {
		for (var row in rows) {
			rows_li.addItem(rows[row]);
		}
		type_ti.text = type;
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		rows_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
		rows_li.labelFunction = function(item_obj:Object):String  {
			return item_obj.getName();
		};
	}
	private function moveUp() {
		if (rows_li.selectedIndex != undefined) {
			if (rows_li.selectedIndex != rows_li.length-1) {
				var tempObj = rows_li.getItemAt(rows_li.selectedIndex+1);
				rows_li.replaceItemAt(rows_li.selectedIndex+1, rows_li.selectedItem);
				rows_li.replaceItemAt(rows_li.selectedIndex, tempObj);
				var tempIndex = rows_li.selectedIndex+1;
				rows_li.selectedIndex = undefined;
				rows_li.selectedIndices = undefined;
				rows_li.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		if (rows_li.selectedIndex != undefined) {
			if (rows_li.selectedIndex != 0) {
				var tempObj = rows_li.getItemAt(rows_li.selectedIndex-1);
				rows_li.replaceItemAt(rows_li.selectedIndex-1, rows_li.selectedItem);
				rows_li.replaceItemAt(rows_li.selectedIndex, tempObj);
				var tempIndex = rows_li.selectedIndex-1;
				rows_li.selectedIndex = undefined;
				rows_li.selectedIndices = undefined;
				rows_li.selectedIndex = tempIndex;
			}
		}
	}
	private function deleteItem() {
		rows_li.removeItemAt(rows_li.selectedIndex);
		rows_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		var newRowNode = new XMLNode(1,"row");
		var newRowObject = new Objects.Client.Row();
		newRowObject.setXML(newRowNode);
		rows_li.addItem(newRowObject);
		rows_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newRows = new Array();
		for (var index = rows_li.length-1; index>=0; index--) {
			newRows.push(rows_li.getItemAt(index));
		}
		_global.left_tree.selectedNode.object.setData(new Object({rows:newRows,type:type_ti.text}));
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
