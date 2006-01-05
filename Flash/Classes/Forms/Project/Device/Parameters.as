import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Parameters {
	private var node:XMLNode;
	private var params_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var value_ti:TextInput;
	public function init() {
		params_dg.labelFunction = function(item_obj:Object):String  {
			var label_str:String = "Name: "+item_obj.name+" - Value: "+item_obj.value;
			return label_str;
		};
		for (var child in node.childNodes) {
			params_dg.addItem({name:node.childNodes[child].attributes["NAME"], value:node.childNodes[child].attributes["VALUE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		params_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		params_dg.removeItemAt(params_dg.selectedIndex);
		params_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (params_dg.selectedIndex != undefined) {
			params_dg.getItemAt(params_dg.selectedIndex).name = name_ti.text;
			params_dg.getItemAt(params_dg.selectedIndex).value = value_ti.text;
		} else {
			params_dg.addItem({name:name_ti.text, value:value_ti.text});
		}
		params_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		params_dg.selectedIndex = undefined;
		name_ti.text = "";
		value_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = params_dg.selectedItem.name;
		value_ti.text = params_dg.selectedItem.value;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Object {
		var parameters = new XMLNode(1,"PARAMETERS");
		for(var index = 0; index < params_dg.length; index++){
			var item = new XMLNode(1, "ITEM");
			item.attributes["NAME"] = params_dg.getItemAt(index).name;
			item.attributes["VALUE"] = params_dg.getItemAt(index).value;
			parameters.appendChild(item);
		}
		return parameters;
	}
}
