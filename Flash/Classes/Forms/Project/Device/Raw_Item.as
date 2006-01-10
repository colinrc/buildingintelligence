import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Item {
	private var catalogue_ti:TextInput;
	private var prefix_ti:TextInput;
	private var node:XMLNode;
	private var device:Object;
	private var save_btn:mx.controls.Button;
	private var raw_dg:DataGrid;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	public function init():Void {
		for (var child in node.childNodes) {
			raw_dg.addItem({name:node.childNodes[child].attributes["COMMAND"]});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		raw_dg.addEventListener("change", Delegate.create(this, itemChange));
		catalogue_ti.text = node.attributes["CATALOGUE"];
		prefix_ti.text = node.attributes["PREFIX"];
	}
	private function deleteItem() {
		raw_dg.removeItemAt(raw_dg.selectedIndex);
		raw_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		raw_dg.addItem({name:name_ti.text});
		raw_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = raw_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	private function save():Void {
		_global.left_tree.selectedNode.attributes["CATALOGUE"] = catalogue_ti.text;
		_global.left_tree.selectedNode.attributes["PREFIX"] = prefix_ti.text;
		var newRaws = new Array();
		for (var index = 0; index<raw_dg.length; index++) {
			var found = false;
			for (var raw in node.childNodes) {
				if (node.childNodes[raw].attributes["COMMAND"] == raw_dg.getItemAt(index).name) {
					found = true;
				}
			}
			if (found == false) {
				newRaws.push({name:raw_dg.getItemAt(index).name});
			}
		}
		var deletedRaws = new Array();
		for (var raw in node.childNodes) {
			var found = false;
			for (var index = 0; index<raw_dg.length; index++) {
				if (node.childNodes[raw].attributes["COMMAND"] == raw_dg.getItemAt(index).name) {
					found = true;
				}
			}
			if (found == false) {
				deletedRaws.push({name:node.childNodes[raw].attributes["COMMAND"]});
			}
		}
		for (var delRaw in deletedRaws) {
			for (var raw in node.childNodes) {
				if (deletedRaws[delRaw].name == node.childNodes[raw].attributes["COMMAND"]) {
					node.childNodes[raw].removeNode();
				}
			}
		}
		for (var newRaw in newRaws) {
			var newNode = new XMLNode(1, "RAW");
			newNode.attributes["COMMAND"] = newRaws[newRaw].name;
			newNode.attributes["CODE"] = "";
			newNode.attributes["EXTRA"] = "";
			node.appendChild(newNode);
		}
	}
}
