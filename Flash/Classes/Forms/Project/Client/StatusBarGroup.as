import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.StatusBarGroup extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var icon_ti:TextInput;
	private var show_ti:TextInput;
	private var hide_ti:TextInput;
	private var name:String;
	private var icon:String;
	private var show:String;
	private var hide:String;
	private var save_btn:Button;
	private var keys_left_li:List;
	private var keys_right_li:List;
	private var keys_addSelected_btn:Button;
	private var keys_addAll_btn:Button;
	private var keys_removeSelected_btn:Button;
	private var keys_removeAll_btn:Button;
	private var controls:Array;
	private var attributes:Array;
	private var overrides_left_li:List;
	private var overrides_right_li:List;
	private var overrides_variable_ld:Loader;
	private var overrides_addSelected_btn:Button;
	private var overrides_addAll_btn:Button;
	private var overrides_removeSelected_btn:Button;
	private var overrides_removeAll_btn:Button;
	private var variable_ld:Loader;
	private var variable_mc:MovieClip;
	public function init():Void {
		var tempKeys = _global.server_test.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			keys_left_li.addItem(tempObject);
		}
		for (var control in controls) {
			var tempObject = new Object();
			tempObject.label = controls[control].attributes["key"];
			for (var key in tempKeys) {
				if (controls[control].attributes["key"] == tempKeys[key]) {
					keys_right_li.addItem(tempObject);
				}
			}
		}
		var tempNode = _global.overrides_xml.firstChild;
		for (var child in tempNode.childNodes) {
			var tempObject = new Object();
			tempObject.label = tempNode.childNodes[child].attributes["name"];
			tempObject.type = tempNode.childNodes[child].attributes["type"];
			tempObject.def = tempNode.childNodes[child].attributes["default"];
			tempObject.description = tempNode.childNodes[child].attributes["description"];
			overrides_left_li.addItem(tempObject);
		}
		for (var attribute in attributes) {
			var tempObject = new Object();
			tempObject.label = attributes[attribute].name;
			tempObject.value = attributes[attribute].value;
			for (var override in tempNode.childNodes) {
				if (attributes[attribute].name == tempNode.childNodes[override].attributes["name"]) {
					tempObject.type = tempNode.childNodes[override].attributes["type"];
					tempObject.def = tempNode.childNodes[override].attributes["default"];
					tempObject.description = tempNode.childNodes[override].attributes["description"];
					overrides_right_li.addItem(tempObject);
				}
			}
		}
		name_ti.text = name;
		icon_ti.text = icon;
		show_ti.text = show;
		hide_ti.text = hide;
		save_btn.addEventListener("click", Delegate.create(this, save));
		keys_addSelected_btn.addEventListener("click", Delegate.create(this, keys_addSel));
		keys_addAll_btn.addEventListener("click", Delegate.create(this, keys_addAll));
		keys_removeSelected_btn.addEventListener("click", Delegate.create(this, keys_remSel));
		keys_removeAll_btn.addEventListener("click", Delegate.create(this, keys_remAll));
		overrides_right_li.addEventListener("change", Delegate.create(this, overrides_rightListChange));
		overrides_addSelected_btn.addEventListener("click", Delegate.create(this, overrides_addSel));
		overrides_addAll_btn.addEventListener("click", Delegate.create(this, overrides_addAll));
		overrides_removeSelected_btn.addEventListener("click", Delegate.create(this, overrides_remSel));
		overrides_removeAll_btn.addEventListener("click", Delegate.create(this, overrides_remAll));
	}
	private function save() {
		var newControls = new Array();
		for (var index = 0; index<keys_right_li.length; index++) {
			var newControl = new XMLNode(1, "control");
			newControl.attributes["key"] = keys_right_li.getItemAt(index).label;
			newControls.push(newControl);
		}
		var newOverrides = new Array();
		for (var index = 0; index<overrides_right_li.length; index++) {
			var newOverride = new Object();
			newOverride.name = overrides_right_li.getItemAt(index).label;
			newOverride.value = overrides_right_li.getItemAt(index).value;
			newOverrides.push(newOverride);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({controls:newControls, attributes:newOverrides, name:name_ti.text, icon:icon_ti.text, show:show_ti.text, hide:hide_ti.text}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
	private function keys_addSel() {
		if (keys_left_li.selectedItem != undefined) {
			var flag = false;
			for (var index = 0; index<keys_right_li.length; index++) {
				if (keys_left_li.selectedItem.label == keys_right_li.getItemAt(index).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = keys_left_li.selectedItem.label;
				keys_right_li.addItem(newObject);
			}
		}
	}
	private function keys_addAll() {
		for (var leftIndex = 0; leftIndex<keys_left_li.length; leftIndex++) {
			var flag = false;
			for (var rightIndex = 0; rightIndex<keys_right_li.length; rightIndex++) {
				if (keys_left_li.getItemAt(leftIndex).label == keys_right_li.getItemAt(rightIndex).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = keys_left_li.getItemAt(leftIndex).label;
				keys_right_li.addItem(newObject);
			}
		}
	}
	private function keys_remSel() {
		if (keys_right_li.selectedItem != undefined) {
			keys_right_li.removeItemAt(keys_right_li.selectedIndex);
		}
	}
	private function keys_remAll() {
		keys_right_li.removeAll();
	}
	private function overrides_rightListChange(eventObj) {
		variable_ld.createEmptyMovieClip("form_mc", 0);
		variable_ld.attachMovie("forms.project.client."+eventObj.target.selectedItem.type+"edit", "form_mc", 0, {setting:eventObj.target.selectedItem});
	}
	private function overrides_addSel() {
		if (overrides_left_li.selectedItem != undefined) {
			var flag = false;
			for (var index = 0; index<overrides_right_li.length; index++) {
				if (overrides_left_li.selectedItem.label == overrides_right_li.getItemAt(index).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = overrides_left_li.selectedItem.label;
				newObject.def = overrides_left_li.selectedItem.def;
				newObject.value = overrides_left_li.selectedItem.def;
				newObject.type = overrides_left_li.selectedItem.type;
				newObject.description = overrides_left_li.selectedItem.description;
				overrides_right_li.addItem(newObject);
			}
		}
	}
	private function overrides_addAll() {
		for (var leftIndex = 0; leftIndex<overrides_left_li.length; leftIndex++) {
			var flag = false;
			for (var rightIndex = 0; rightIndex<overrides_right_li.length; rightIndex++) {
				if (overrides_left_li.getItemAt(leftIndex).label == overrides_right_li.getItemAt(rightIndex).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = overrides_left_li.getItemAt(leftIndex).label;
				newObject.def = overrides_left_li.getItemAt(leftIndex).def;
				newObject.value = overrides_left_li.getItemAt(leftIndex).def;
				newObject.type = overrides_left_li.getItemAt(leftIndex).type;
				newObject.description = overrides_left_li.getItemAt(leftIndex).description;
				overrides_right_li.addItem(newObject);
			}
		}
	}
	private function overrides_remSel() {
		if (overrides_right_li.selectedItem != undefined) {
			overrides_right_li.removeItemAt(overrides_right_li.selectedIndex);
			variable_ld.createEmptyMovieClip("form_mc", 0);
		}
	}
	private function overrides_remAll() {
		overrides_right_li.removeAll();
		variable_ld.createEmptyMovieClip("form_mc", 0);
	}
}
