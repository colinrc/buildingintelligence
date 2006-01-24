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
	private var left_li:List;
	private var right_li:List;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var controls:Array;
	public function init():Void {
		var tempKeys = _global.server_test.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
		for (var control in controls) {
			var tempObject = new Object();
			tempObject.label = controls[control].attributes["key"];
			for (var key in tempKeys) {
				if (controls[control].attributes["key"] == tempKeys[key]) {
					right_li.addItem(tempObject);
				}
			}
		}
		name_ti.text = name;
		icon_ti.text = icon;
		show_ti.text = show;
		hide_ti.text = hide;
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
	}
	private function save() {
		var newControls = new Array();
		for (var index = 0; index<right_li.length; index++) {
			var newControl = new XMLNode(1, "control");
			newControl.attributes["key"] = right_li.getItemAt(index).label;
			newControls.push(newControl);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({controls:newControls, name:name, icon:icon, show:show, hide:hide}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
	private function addSel() {
		if (left_li.selectedItem != undefined) {
			var flag = false;
			for (var index = 0; index<right_li.length; index++) {
				if (left_li.selectedItem.label == right_li.getItemAt(index).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = left_li.selectedItem.label;
				right_li.addItem(newObject);
			}
		}
	}
	private function addAll() {
		for (var leftIndex = 0; leftIndex<left_li.length; leftIndex++) {
			var flag = false;
			for (var rightIndex = 0; rightIndex<right_li.length; rightIndex++) {
				if (left_li.getItemAt(leftIndex).label == right_li.getItemAt(rightIndex).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = left_li.getItemAt(leftIndex).label;
				right_li.addItem(newObject);
			}
		}
	}
	private function remSel() {
		if (right_li.selectedItem != undefined) {
			right_li.removeItemAt(right_li.selectedIndex);
		}
	}
	private function remAll() {
		right_li.removeAll();
	}
}
