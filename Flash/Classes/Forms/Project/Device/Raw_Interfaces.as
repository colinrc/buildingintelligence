import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Interfaces {
	private var node:XMLNode;
	private var interfaces_dg:DataGrid;
	private var save_btn:Button;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var child in node.childNodes) {
			interfaces_dg.addItem({name:node.childNodes[child].attributes["NAME"]});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		interfaces_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		interfaces_dg.removeItemAt(interfaces_dg.selectedIndex);
		interfaces_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		interfaces_dg.addItem({name:name_ti.text});
		interfaces_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = interfaces_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newInterfaces = new Array();
		for(var index = 0; index < interfaces_dg.length; index++){
			var found = false;
			for(var interfaceIndex in node.childNodes){
				if (node.childNodes[interfaceIndex].attributes["NAME"] == interfaces_dg.getItemAt(index).name){
					found = true;
				}
			}
			if(found == false){
				newInterfaces.push({name:interfaces_dg.getItemAt(index).name});
			}
		}
		var deletedInterfaces = new Array();
		for(var interfaceIndex in node.childNodes){
			var found = false;
			for(var index = 0; index<interfaces_dg.length; index++){
				if (node.childNodes[interfaceIndex].attributes["NAME"] == interfaces_dg.getItemAt(index).name){
					found = true;
				}
			}
			if(found == false){
				deletedInterfaces.push({name:node.childNodes[interfaceIndex].attributes["NAME"]});
			}
		}
		for(var delInterface in deletedInterfaces){
			for(var interfaceIndex in node.childNodes){
				if(deletedInterfaces[delInterface].name == node.childNodes[interfaceIndex].attributes["NAME"]){
					node.childNodes[interfaceIndex].removeNode();
				}
			}
		}
		for(var newInterface in newInterfaces){
			var newNode = new XMLNode(1, "RAW_INTERFACE");
			newNode.attributes["NAME"] = newInterfaces[newInterface].name;
			newNode.attributes["DISPLAY_NAME"] = "";
			newNode.attributes["POWER_RATING"] = "";
			newNode.appendChild(new XMLNode(1,"Custom Inputs"));
			newNode.appendChild(new XMLNode(1,"Raw Items"));
			node.appendChild(newNode);
		}
	}
}
