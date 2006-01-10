import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Variables {
	private var variables:XMLNode;
	private var variables_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var title_lb:Label;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;	
	private var command_ti:TextInput;
	private var extra_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var child in variables.childNodes){
			variables_dg.addItem({name:variables.childNodes[child].attributes["NAME"],display_name:variables.childNodes[child].attributes["DISPLAY_NAME"], command:variables.childNodes[child].attributes["INIT_COMMAND"], extra:variables.childNodes[child].attributes["INIT_EXTRA"], active:variables.childNodes[child].attributes["ACTIVE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		variables_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		variables_dg.removeItemAt(variables_dg.selectedIndex);
		variables_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		name_ti.text = "";
		dname_ti.text = "";
		command_ti.text ="";
		extra_ti.text = "";
	}
	private function updateItem() {
		if(active_chk.selected){
			var active = "Y";
		}
		else{
			var active = "N";
		}
		if (variables_dg.selectedIndex != undefined) {
			variables_dg.getItemAt(variables_dg.selectedIndex).name = name_ti.text;
			variables_dg.getItemAt(variables_dg.selectedIndex).command = command_ti.text;
			variables_dg.getItemAt(variables_dg.selectedIndex).display_name = dname_ti.text;
			variables_dg.getItemAt(variables_dg.selectedIndex).extra = extra_ti.text;
			variables_dg.getItemAt(variables_dg.selectedIndex).active = active;			
		} else {
			variables_dg.addItem({name:name_ti.text, command:command_ti.text, display_name:dname_ti.text, extra:extra_ti.text, active:active});
		}
		variables_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		variables_dg.selectedIndex = undefined;
		active_chk.selected = false;
		name_ti.text = "";
		dname_ti.text = "";
		command_ti.text ="";
		extra_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = variables_dg.selectedItem.name;
		command_ti.text = variables_dg.selectedItem.command;
		dname_ti.text = variables_dg.selectedItem.display_name;
		extra_ti.text = variables_dg.selectedItem.extra;
		if(variables_dg.selectedItem.active == "N"){
			active_chk.selected = false;
		}
		else{
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():XMLNode {
		var newToggles = new XMLNode(1,"VARIABLES");
		for(var index = 0; index < variables_dg.length; index++){
			var variableNode = new XMLNode(1, "VARIABLE");
			variableNode.attributes["NAME"] = variables_dg.getItemAt(index).name;
			variableNode.attributes["INIT_COMMAND"] = variables_dg.getItemAt(index).command;
			variableNode.attributes["DISPLAY_NAME"] = variables_dg.getItemAt(index).display_name;
			variableNode.attributes["ACTIVE"] = variables_dg.getItemAt(index).active;
			variableNode.attributes["INIT_EXTRA"] = variables_dg.getItemAt(index).extra;
			newToggles.appendChild(variableNode);
		}
		return newToggles;
	}
}
