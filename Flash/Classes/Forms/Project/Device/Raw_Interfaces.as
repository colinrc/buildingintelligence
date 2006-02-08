import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Interfaces extends Forms.BaseForm {
	private var raw_interfaces:Array;
	private var cataloguesNode:XMLNode;
	private var interfaces_dg:DataGrid;
	private var save_btn:Button;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var string_lb:Label;
	public function init() {
		interfaces_dg.vScrollPolicy = "auto";
		interfaces_dg.hScrollPolicy = "auto";
		var catalogueDP = new Array();
		var catalogues = new Array();
		for (var catalogue in cataloguesNode.childNodes) {
			catalogueDP.push({label:cataloguesNode.childNodes[catalogue].attributes.NAME});
			var codes = new Array();
			var values = new Array();
			for (var item in cataloguesNode.childNodes[catalogue].childNodes) {
				codes.push({label:cataloguesNode.childNodes[catalogue].childNodes.attributes.CODE});
				values.push(cataloguesNode.childNodes[catalogue].childNodes.attributes.VALUE);
			}
			catalogues.push({codes:codes, values:values});
		}
		for (var raw_interface in raw_interfaces) {
			var newRaw_interface = new Object();
			newRaw_interface.display_name = "";
			newRaw_interface.name = "";
			if (raw_interfaces[raw_interface].attributes.DISPLAY_NAME != undefined) {
				newRaw_interface.display_name = raw_interfaces[raw_interface].attributes.DISPLAY_NAME;
			}
			if (raw_interfaces[raw_interface].attributes.NAME != undefined) {
				newRaw_interface.name = raw_interfaces[raw_interface].attributes.NAME;
			}
			var raw_items = raw_interfaces[raw_interface].childNodes;
			for (var raw_item in raw_items) {
				newRaw_interface.catalogue = "";
				if (raw_items[raw_item].attributes.CATALOGUE != undefined) {
					newRaw_interface.catalogue = raw_items[raw_item].attributes.CATALOGUE;
				}
				var raws = raw_items[raw_item].childNodes;
				for (var raw in raws) {
					newRaw_interface.code = "";
					newRaw_interface.command = "";
					newRaw_interface.extra = "";
					newRaw_interface.extra2 = "";
					newRaw_interface.extra3 = "";
					newRaw_interface.extra4 = "";
					newRaw_interface.extra5 = "";
					if (raws[raw].attributes.CODE != undefined) {
						newRaw_interface.code = raws[raw].attributes.CODE;
					}
					if (raws[raw].attributes.COMMAND != undefined) {
						newRaw_interface.command = raws[raw].attributes.COMMAND;
					}
					if (raws[raw].attributes.EXTRA != undefined) {
						newRaw_interface.extra = raws[raw].attributes.EXTRA;
					}
					if (raws[raw].attributes.EXTRA2 != undefined) {
						newRaw_interface.extra2 = raws[raw].attributes.EXTRA2;
					}
					if (raws[raw].attributes.EXTRA3 != undefined) {
						newRaw_interface.extra3 = raws[raw].attributes.EXTRA3;
					}
					if (raws[raw].attributes.EXTRA4 != undefined) {
						newRaw_interface.extra4 = raws[raw].attributes.EXTRA4;
					}
					if (raws[raw].attributes.EXTRA5 != undefined) {
						newRaw_interface.extra5 = raws[raw].attributes.EXTRA5;
					}
					if (raws[raw].hasChildNodes) {
						var variables = raws[raw].childNodes;
						newRaw_interface.vars = new Array();
						for (var variable in variables) {
							newRaw_interface.vars.push(variables[variable]);
						}
					}
					var actualInterface = new Object();
					for (var attribute in newRaw_interface) {
						actualInterface[attribute] = newRaw_interface[attribute];
					}
					interfaces_dg.addItem(actualInterface);
				}
			}
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		interfaces_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
	}
	private function addItem() {
	}
	private function itemChange(evtObj) {
	}
	public function save():Void {
		/*var newRaw_Interfaces = new Array();
		for(var index = 0; index < interfaces_dg.length; index++){
		var Raw_Interface = new Object();
		Raw_Interface.name = interfaces_dg.getItemAt(index).name;
		newRaw_Interfaces.push(Raw_Interface);
		}
		_global.left_tree.selectedNode.object.setData(new Object({raw_interfaces:newRaw_Interfaces}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for(var child in _global.left_tree.selectedNode.childNodes){
		_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1,"Placeholder"));
		for(var child in newNode.childNodes){
		_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,true);*/
	}
}
