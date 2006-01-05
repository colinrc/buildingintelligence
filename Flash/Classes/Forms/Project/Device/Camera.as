import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Camera {
	private var node:XMLNode;
	private var cameras_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var zone_ti:TextInput;
	private var name_ti:TextInput;
	private var zoom_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var child in node.childNodes) {
			if (node.childNodes[child].attributes["ACTIVE"] == "N") {
				var active = "N";
			} else {
				var active = "Y";
			}
			cameras_dg.addItem({key:node.childNodes[child].attributes["KEY"], name:node.childNodes[child].attributes["DISPLAY_NAME"], active:active, zoom:node.childNodes[child].attributes["ZOOM"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		cameras_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		cameras_dg.removeItemAt(cameras_dg.selectedIndex);
		cameras_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (cameras_dg.selectedIndex != undefined) {
			cameras_dg.getItemAt(cameras_dg.selectedIndex).key = zone_ti.text;
			cameras_dg.getItemAt(cameras_dg.selectedIndex).name = name_ti.text;
			cameras_dg.getItemAt(cameras_dg.selectedIndex).zoom = zoom_ti.text;
			cameras_dg.getItemAt(cameras_dg.selectedIndex).active = active;
		} else {
			cameras_dg.addItem({key:zone_ti.text, name:name_ti.text, active:active, zoom:zoom_ti.text});
		}
		cameras_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		cameras_dg.selectedIndex = undefined;
		zone_ti.text = "";
		name_ti.text = "";
		zoom_ti.text = "";
		active_chk.selected = true;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		zone_ti.text = cameras_dg.selectedItem.key;
		name_ti.text = cameras_dg.selectedItem.name;
		zoom_ti.text = cameras_dg.selectedItem.zoom;
		var active = cameras_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Object {
		var cameras = new XMLNode(1, "PELCO");
		for (var index = 0; index<cameras_dg.length; index++) {
			var item = new XMLNode(1, "CAMERA");
			item.attributes["KEY"] = cameras_dg.getItemAt(index).key;
			item.attributes["DISPLAY_NAME"] = cameras_dg.getItemAt(index).name;
			item.attributes["ACTIVE"] = cameras_dg.getItemAt(index).active;
			item.attributes["ZOOM"] = cameras_dg.getItemAt(index).zoom;
			cameras.appendChild(item);
		}
		return cameras;
	}
}
