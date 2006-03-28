import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.StatusBarGroup extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var icon_cmb:ComboBox;
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
	private var attributes:Array;
	private var variable_ld:Loader;
	private var variable_mc:MovieClip;
	private var dataObject:Object;
	public function onLoad():Void {
		icon_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\icons", "*.png");
		for(var myIcon =0; myIcon <myIcons.length; myIcon++){
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path+"lib\\icons\\"+myIcons[myIcon];
			icon_cmb.addItem(newIcon);
		}
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		icon_cmb.addEventListener("change", changeListener);
		show_ti.addEventListener("change", changeListener);
		hide_ti.addEventListener("change", changeListener);
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
		for (var control in controls) {
			var tempObject = new Object();
			tempObject.label = controls[control].attributes["key"];
			var leftLength = left_li.dataProvider.length;
			for (var index = 0; index < leftLength; index++) {
				if (controls[control].attributes["key"] == left_li.getItemAt(index).label) {
					right_li.addItem(tempObject);
					left_li.removeItemAt(index);
					break;
				}
			}
		}
		name_ti.text = name;
		icon_cmb.text = icon;
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
		for (var index = 0; index < right_li.length; index++) {
			var newControl = new XMLNode(1, "control");
			newControl.attributes["key"] = right_li.getItemAt(index).label;
			newControls.push(newControl);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		dataObject.setData({controls:newControls, name:name_ti.text, icon:icon_cmb.text, show:show_ti.text, hide:hide_ti.text});
		_global.saveFile("Project");
	}
	private function addSel() {
		_global.unSaved = true;
		if (left_li.selectedItem != undefined) {
			right_li.addItem(left_li.removeItemAt(left_li.selectedIndex));
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
	private function addAll() {
		_global.unSaved = true;
		right_li.removeAll();
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			right_li.addItem(tempObject);
		}
		left_li.removeAll();
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
	private function remSel() {
		_global.unSaved = true;
		if (right_li.selectedItem != undefined) {
			left_li.addItem(right_li.removeItemAt(right_li.selectedIndex));
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
	private function remAll() {
		_global.unSaved = true;
		left_li.removeAll();
		right_li.removeAll();
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
}
