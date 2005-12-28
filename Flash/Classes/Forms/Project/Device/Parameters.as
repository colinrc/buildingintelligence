import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Parameters {
	private var node:XMLNode;
	private var params_list:List;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var value_ti:TextInput;
	public function init() {
		params_list.labelFunction = function(item_obj:Object):String  {
			var label_str:String = "Name: "+item_obj.name+" - Value: "+item_obj.value;
			return label_str;
		};
		for (var child in node.childNodes) {
			params_list.addItem({name:node.childNodes[child].attributes["NAME"], value:node.childNodes[child].attributes["VALUE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		params_list.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		params_list.removeItemAt(params_list.selectedIndex);
		params_list.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (params_list.selectedIndex != undefined) {
			params_list.getItemAt(params_list.selectedIndex).name = name_ti.text;
			params_list.getItemAt(params_list.selectedIndex).value = value_ti.text;
		} else {
			params_list.addItem({name:name_ti.text, value:value_ti.text});
		}
		params_list.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		params_list.selectedIndex = undefined;
		name_ti.text = "";
		value_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = params_list.selectedItem.name;
		value_ti.text = params_list.selectedItem.value;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Object {
		var parameters = new XMLNode(1,"PARAMETERS");
		for(var index = 0; index < params_list.length; index++){
			var item = new XMLNode(1, "ITEM");
			item.attributes["NAME"] = params_list.getItemAt(index).name;
			item.attributes["VALUE"] = params_list.getItemAt(index).value;
			parameters.appendChild(item);
		}
		return parameters;
	}
}
