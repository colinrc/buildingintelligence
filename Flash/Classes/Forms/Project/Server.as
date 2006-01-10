import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Server {
	private var node:XMLNode;
	private var description:String;
	private var description_ta:TextArea;
	private var devices_dg:DataGrid;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var type_cb:ComboBox;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		description_ta.text = description;
		for (var device in node.childNodes) {
			if (node.childNodes[device].nodeName == "DEVICE") {
				devices_dg.addItem({type:node.childNodes[device].attributes["NAME"], name:node.childNodes[device].attributes["DISPLAY_NAME"]});
			}
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		devices_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		devices_dg.removeItemAt(devices_dg.selectedIndex);
		devices_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		devices_dg.addItem({name:name_ti.text, type:type_cb.selectedItem.label});
		devices_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = devices_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newDevices = new Array();
		for (var index = 0; index<devices_dg.length; index++) {
			var found = false;
			for (var device in node.childNodes) {
				if (node.childNodes[device].attributes["DISPLAY_NAME"] == devices_dg.getItemAt(index).name) {
					found = true;
				}
			}
			if (found == false) {
				newDevices.push({name:devices_dg.getItemAt(index).name, type:devices_dg.getItemAt(index).type});
			}
		}
		var deletedDevices = new Array();
		for (var device in node.childNodes) {
			var found = false;
			for (var index = 0; index<devices_dg.length; index++) {
				if ((node.childNodes[device].attributes["DISPLAY_NAME"] == devices_dg.getItemAt(index).name) && (node.childNodes[device].nodeName == "DEVICE")) {
					found = true;
				}
			}
			if (found == false) {
				deletedDevices.push({name:node.childNodes[device].attributes["DISPLAY_NAME"]});
			}
		}
		for (var delDevice in deletedDevices) {
			for (var device in node.childNodes) {
				if ((deletedDevices[delDevice].name == node.childNodes[device].attributes["DISPLAY_NAME"]) && (node.childNodes[device].nodeName == "DEVICE")) {
					node.childNodes[device].removeNode();
				}
			}
		}
		for (var newDevice in newDevices) {
			var newNode = new XMLNode(1, "DEVICE");
			newNode.attributes["DISPLAY_NAME"] = newDevices[newDevice].name;
			newNode.attributes["NAME"] = newDevices[newDevice].type;
			newNode.attributes["ACTIVE"] = "N";
			switch (newNode.attributes["NAME"]) {
			case "PELCO" :
				var cameraNode = new XMLNode(1, "Cameras");
				newNode.appendChild(cameraNode);
				break;
			case "TUTONDO" :
			case "KRAMER" :
			case "HAL" :
				var audioNode = new XMLNode(1, "Audio/Video Inputs");
				audioNode.audio = new Object({audioName:node.attributes["NAME"]});
				newNode.appendChild(audioNode);
				break;
			case "GC100" :
				var modules = new XMLNode(1, "GC100 Modules");
				newNode.appendChild(modules);
				break;
			case "DYNALITE" :
				newNode.appendChild(new XMLNode(1, "IR Inputs"));
				newNode.appendChild(new XMLNode(1, "Contact Closures"));
				newNode.appendChild(new XMLNode(1, "Dynalite Lights"));
				break;
			case "OREGON" :
				newNode.appendChild(new XMLNode(1, "Sensors"));
				break;
			case "CBUS" :
				newNode.appendChild(new XMLNode(1, "Sensors"));
				newNode.appendChild(new XMLNode(1, "Lights"));
				break;
			case "RAW_CONNECTION" :
				newNode.appendChild(new XMLNode(1, "Custom Inputs"));
				newNode.appendChild(new XMLNode(1, "Raw Interfaces"));
				newNode.appendChild(new XMLNode(1, "Raw Items"));
				break;
			case "COMFORT" :
				newNode.appendChild(new XMLNode(1, "Custom Inputs"));
				newNode.appendChild(new XMLNode(1, "Counters"));
				newNode.appendChild(new XMLNode(1, "Toggle Monitors"));
				newNode.appendChild(new XMLNode(1, "Lights"));
				newNode.appendChild(new XMLNode(1, "X10 Lights"));
				newNode.appendChild(new XMLNode(1, "Toggle Outputs"));
				newNode.appendChild(new XMLNode(1, "Toggle Inputs"));
				newNode.appendChild(new XMLNode(1, "Analogue Inputs"));
				newNode.appendChild(new XMLNode(1, "Comfort Alerts"));
				newNode.appendChild(new XMLNode(1, "Comfort Alarms"));
				newNode.appendChild(new XMLNode(1, "Pulse Outputs"));
				newNode.appendChild(new XMLNode(1, "Raw Interfaces"));
				break;
			}
			var catalogues = new XMLNode(1, "Catalogues");
			newNode.appendChild(catalogues);
			node.appendChild(newNode);
		}
		_global.left_tree.selectedNode.description = description_ta.text;
	}
}
