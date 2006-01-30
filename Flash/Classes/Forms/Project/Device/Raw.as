import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw extends Forms.BaseForm {
	private var command:String;
	private var code:String;
	private var extra:String;
	private var variables:Array;
	private var variables_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var command_ti:TextInput;
	private var code_ti:TextInput;
	private var extra_ti:TextInput;
	private var name_ti:TextInput;
	private var value_ti:TextInput;
	public function init() {
		command_ti.text = command;
		code_ti.text = code;
		extra_ti.text = extra;
		for (var variable in variables) {
			var newVariable = new Object();
			newVariable.name = "";
			newVariable.value = "";
			if (variables[variable].attributes["NAME"] != undefined) {
				newVariable.name = variables[variable].attributes["NAME"];
			}
			if (variables[variable].attributes["VALUE"] != undefined) {
				newVariable.value = variables[variable].attributes["VALUE"];
			}
			variables_dg.addItem(newVariable);
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		variables_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		variables_dg.removeItemAt(variables_dg.selectedIndex);
		variables_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (variables_dg.selectedIndex != undefined) {
			variables_dg.getItemAt(variables_dg.selectedIndex).name = name_ti.text;
			variables_dg.getItemAt(variables_dg.selectedIndex).value = value_ti.text;
		} else {
			variables_dg.addItem({name:name_ti.text, value:value_ti.text});
		}
		variables_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		variables_dg.selectedIndex = undefined;
		name_ti.text = "";
		value_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = variables_dg.selectedItem.name;
		value_ti.text = variables_dg.selectedItem.value;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	private function save():Void {
		var newItems = new Array();
		for (var index = 0; index<variables_dg.length; index++) {
			var item = new XMLNode(1, "VARS");
			if (variables_dg.getItemAt(index).name != "") {
				item.attributes["NAME"] = variables_dg.getItemAt(index).name;
			}
			if (variables_dg.getItemAt(index).value != "") {
				item.attributes["VALUE"] = variables_dg.getItemAt(index).value;
			}
			newItems.push(item);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({variables:newItems, command:command_ti.text, code:code_ti.text, extra:extra_ti.text}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
