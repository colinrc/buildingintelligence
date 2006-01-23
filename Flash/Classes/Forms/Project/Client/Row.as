import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Row {
	private var cases:String;
	private var items:Array;
	private var row_li:List;
	private var cases_ti:TextInput;
	private var type_cmb:ComboBox;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var save_btn:Button;
	public function init() {
		for (var item in items) {
			row_li.addItem(items[item]);
		}
		cases_ti.text = cases;
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		row_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
		row_li.labelFunction = function(item_obj:Object):String  {
			var label_str:String = item_obj.type;
			var name = "";
			for(var attribute in item_obj.attributes){
				if((item_obj.attributes[attribute].name == "label")||(item_obj.attributes[attribute].name == "icon")){
					name +=": "+ item_obj.attributes[attribute].value;
				}
			}
			if (name == "") {
				name = ": No Name";
			} 
			label_str += name;
			return label_str;
		};
	}
	private function moveUp() {
		if (row_li.selectedIndex != undefined) {
			if (row_li.selectedIndex != row_li.length-1) {
				var tempObj = row_li.getItemAt(row_li.selectedIndex+1);
				row_li.replaceItemAt(row_li.selectedIndex+1, row_li.selectedItem);
				row_li.replaceItemAt(row_li.selectedIndex, tempObj);
				var tempIndex = row_li.selectedIndex+1;
				row_li.selectedIndex = undefined;
				row_li.selectedIndices = undefined;
				row_li.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		if (row_li.selectedIndex != undefined) {
			if (row_li.selectedIndex != 0) {
				var tempObj = row_li.getItemAt(row_li.selectedIndex-1);
				row_li.replaceItemAt(row_li.selectedIndex-1, row_li.selectedItem);
				row_li.replaceItemAt(row_li.selectedIndex, tempObj);
				var tempIndex = row_li.selectedIndex-1;
				row_li.selectedIndex = undefined;
				row_li.selectedIndices = undefined;
				row_li.selectedIndex = tempIndex;
			}
		}
	}
	private function deleteItem() {
		row_li.removeItemAt(row_li.selectedIndex);
		row_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		var newItemNode = new XMLNode(1,"item");
		newItemNode.attributes["type"] = type_cmb.selectedItem.label;
		var newItemObject = new Objects.Client.Item();
		newItemObject.setXML(newItemNode);
		row_li.addItem(newItemObject);
		row_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newItems = new Array();
		for (var index = row_li.length-1; index>=0; index--) {
			newItems.push(row_li.getItemAt(index));
		}
		_global.left_tree.selectedNode.object.setData(new Object({items:newItems,cases:cases_ti.text}));
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
