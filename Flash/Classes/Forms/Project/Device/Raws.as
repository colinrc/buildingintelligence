import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raws {
	private var raw:Array;
	private var raw_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var command_ti:TextInput;
	private var code_ti:TextInput;
	private var extra_ti:TextInput;
	public function init() {
		for (var index in raw) {
			raw_dg.addItem({command:raw[index].attributes["COMMAND"],code:raw[index].attributes["CODE"],extra:raw[index].attributes["EXTRA"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		raw_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		raw_dg.removeItemAt(raw_dg.selectedIndex);
		raw_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (raw_dg.selectedIndex != undefined) {
			raw_dg.getItemAt(raw_dg.selectedIndex).command = command_ti.text;
			raw_dg.getItemAt(raw_dg.selectedIndex).code = code_ti.text;
			raw_dg.getItemAt(raw_dg.selectedIndex).extra = extra_ti.text;
		} else {
			raw_dg.addItem({command:command_ti.text, code:code_ti.text, extra:extra_ti.text});
		}
		raw_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		raw_dg.selectedIndex = undefined;
		command_ti.text = "";
		code_ti.text = "";
		extra_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		command_ti.text = raw_dg.selectedItem.command;
		code_ti.text = raw_dg.selectedItem.code;
		extra_ti.text = raw_dg.selectedItem.extra;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Object {
		var newRaw_Items = new Array();
		for (var index = 0; index<raw_dg.length; index++) {
			var item = new XMLNode(1, "RAW");
			item.attributes["COMMAND"] = raw_dg.getItemAt(index).command;
			item.attributes["CODE"] = raw_dg.getItemAt(index).code;
			item.attributes["EXTRA"] = raw_dg.getItemAt(index).extra;
			newRaw_Items.push(item);
		}
		return newRaw_Items;
	}
}
