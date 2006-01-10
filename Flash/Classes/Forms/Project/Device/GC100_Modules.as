import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_Modules {
	private var node:XMLNode;
	private var modules_dg:DataGrid;
	private var type_cb:ComboBox;
	private var save_btn:Button;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var module in node.childNodes) {
			modules_dg.addItem({name:node.childNodes[module].attributes["NAME"], type:node.childNodes[module].nodeName});
		}
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		modules_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		modules_dg.removeItemAt(modules_dg.selectedIndex);
		modules_dg.selectedIndex = undefined;
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
	}
	private function addItem() {
		modules_dg.addItem({name:name_ti.text, type:type_cb.selectedItem.label});
		modules_dg.selectedIndex = undefined;
		name_ti.text = "";
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = modules_dg.selectedItem.name;
		if (modules_dg.selectedItem.type == "GC100_Relay") {
			type_cb.selectedIndex = 1;
		} else {
			type_cb.selectedIndex = 0;
		}
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newModules = new Array();
		for (var index = 0; index<modules_dg.length; index++) {
			var found = false;
			for (var moduleIndex in node.childNodes) {
				if ((node.childNodes[moduleIndex].attributes["NAME"] == modules_dg.getItemAt(index).name) && (node.childNodes[moduleIndex].nodeName == modules_dg.getItemAt(index).type)){
					found = true;
				}
			}
			if (found == false) {
				newModules.push({name:modules_dg.getItemAt(index).name});
			}
		}
		var deletedModules = new Array();
		for (var moduleIndex in node.childNodes) {
			var found = false;
			for (var index = 0; index<modules_dg.length; index++) {
				if ((node.childNodes[moduleIndex].attributes["NAME"] == modules_dg.getItemAt(index).name) && (node.childNodes[moduleIndex].nodeName == modules_dg.getItemAt(index).type)){
					found = true;
				}
			}
			if (found == false) {
				deletedModules.push({name:node.childNodes[moduleIndex].attributes["NAME"]});
			}
		}
		for (var delModule in deletedModules) {
			for (var moduleIndex in node.childNodes) {
				if ((deletedModules[delModule].name == node.childNodes[moduleIndex].attributes["NAME"]) && (node.childNodes[moduleIndex].nodeName == modules_dg.getItemAt(index).type)){
					node.childNodes[moduleIndex].removeNode();
				}
			}
		}
		for (var newModule in newModules) {
			var newNode = new XMLNode(1, newModules[newModule].type);
			newNode.attributes["NAME"] = newModules[newModule].name;
			if (newNode.nodeName == "GC100_Relay") {
				newNode.appendChild(new XMLNode(1, "Toggle Outputs"));
			} else {
				newNode.appendChild(new XMLNode(1, "Toggle Inputs"));
				newNode.appendChild(new XMLNode(1, "IR Inputs"));
			}
			node.appendChild(newNode);
		}
	}
}
