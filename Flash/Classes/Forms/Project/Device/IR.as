import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.IR {
	private var save_btn:Button;
	private var irs:Array;
	private var ir_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var key_ti:TextInput;
	private var avname_ti:TextInput;	
	public function init() {
		for (var ir in irs) {
			ir_dg.addItem({name:irs[ir].attributes["NAME"], key:irs[ir].attributes["KEY"], avname:irs[ir].attributes["AV_NAME"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		ir_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		ir_dg.removeItemAt(ir_dg.selectedIndex);
		ir_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (ir_dg.selectedIndex != undefined) {
			ir_dg.getItemAt(ir_dg.selectedIndex).name = name_ti.text;
			ir_dg.getItemAt(ir_dg.selectedIndex).key = key_ti.text;
			ir_dg.getItemAt(ir_dg.selectedIndex).avname = avname_ti.text;
		} else {
			ir_dg.addItem({name:name_ti.text, key:key_ti.text, avname:avname_ti.text});
		}
		ir_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		ir_dg.selectedIndex = undefined;
		name_ti.text = "";
		key_ti.text = "";
		avname_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = ir_dg.selectedItem.name;
		key_ti.text = ir_dg.selectedItem.key;
		avname_ti.text = ir_dg.selectedItem.avname;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newIrs = new Array();
		for(var index = 0; index < ir_dg.length; index++){
			var irNode = new XMLNode(1, "IR");
			irNode.attributes["NAME"] = ir_dg.getItemAt(index).name;
			irNode.attributes["KEY"] = ir_dg.getItemAt(index).key;
			irNode.attributes["AV_NAME"] = ir_dg.getItemAt(index).avname;
			newIrs.push(irNode);
		}
		_global.left_tree.selectedNode.irs = newIrs;
	}
}
