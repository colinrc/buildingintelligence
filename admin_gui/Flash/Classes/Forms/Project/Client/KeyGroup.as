﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.KeyGroup extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var icon1_cmb:ComboBox;
	private var icon1_ldr:Loader;
	private var icon2_cmb:ComboBox;
	private var icon2_ldr:Loader;
	private var control_cmb:ComboBox;
	private var name:String;
	private var icon1:String;
	private var icon2:String;
	private var keys:Array;
	private var type:String;
	private var save_btn:Button;
	private var left_li:List;
	private var right_li:List;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var dataObject:Object;
	private var available_keys:Array;
	public function onLoad():Void {
		icon1_ldr.autoLoad = true;
		icon1_ldr.scaleContent = true;
		icon1_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		icon2_ldr.autoLoad = true;
		icon2_ldr.scaleContent = true;
		icon2_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		available_keys = new Array();
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path + "lib\\icons", "*.png");
		for (var myIcon = 0; myIcon < myIcons.length; myIcon++) {
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path + "lib\\icons\\" + myIcons[myIcon];
			icon1_cmb.addItem(newIcon);
			icon2_cmb.addItem(newIcon);
		}
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		var foundNode = _global.searchProject(_global.left_tree.dataProvider, dataObject);
		var tempNode = foundNode.parentNode;
		while (tempNode.nodeName != "Client") {
			tempNode = tempNode.parentNode;
		}
		var tempControlTypes = tempNode.object.getControlTypes();
		for (var controlType in tempControlTypes.childNodes) {
			var tempObject = new Object();
			tempObject.label = tempControlTypes.childNodes[controlType].attributes["type"];
			control_cmb.addItem(tempObject);
		}
		control_cmb.addEventListener("change", changeListener);
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			var found = 0;
			if (found == 0) {
				var otherGroups = tempNode.object.getKeyGroups();
				for (var group in otherGroups.childNodes) {
					if (otherGroups.childNodes[group].attributes.name != name) {
						for (var usedKey in otherGroups.childNodes[group].childNodes) {
							if (otherGroups.childNodes[group].childNodes[usedKey].attributes.name == tempKeys[key]) {
								found = 2;
								break;
							}
						}
					} else {
						for (var usedKey in otherGroups.childNodes[group].childNodes) {
							if (otherGroups.childNodes[group].childNodes[usedKey].attributes.name == tempKeys[key]) {
								found = 1;
								break;
							}
						}
					}
					if (found != 0) {
						break;
					}
				}
			}
			if (found == 0) {
				left_li.addItem(tempObject);
			} else if (found == 1) {
				right_li.addItem(tempObject);
			}
			if (found != 2) {
				available_keys.push(tempObject);
			}
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
		name_ti.text = name;
		if (icon1.length) {
			for (var tempIcon = 0; tempIcon < icon1_cmb.dataProvider.length; tempIcon++) {
				if (icon1_cmb.dataProvider[tempIcon].label == icon1) {
					icon1_cmb.selectedIndex = tempIcon;
					icon1_ldr.load(mdm.Application.path + "lib\\icons\\" + icon1 + ".png");
					break;
				}
			}
		}
		if (icon2.length) {
			for (var tempIcon = 0; tempIcon < icon2_cmb.dataProvider.length; tempIcon++) {
				if (icon2_cmb.dataProvider[tempIcon].label == icon2) {
					icon2_cmb.selectedIndex = tempIcon;
					icon2_ldr.load(mdm.Application.path + "lib\\icons\\" + icon2 + ".png");
					break;
				}
			}
		}
		for (var tempIcon = 0; tempIcon < control_cmb.dataProvider.length; tempIcon++) {
			if (control_cmb.dataProvider[tempIcon].label == type) {
				control_cmb.selectedIndex = tempIcon;
				break;
			}
		}
		/*			for(var control in control_cmb.dataProvider){
		if(control_cmb.dataProvider[control].label == controlType){
		control_cmb.text =controlType;
		break;
		}
		}*/
		right_li.multipleSelection = true;
		left_li.multipleSelection = true;
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
		icon1_cmb.addEventListener("change", Delegate.create(this, loadIcon1));
		icon2_cmb.addEventListener("change", Delegate.create(this, loadIcon2));
	}
	public function loadIcon1(eventObject) {
		_global.unSaved = true;
		icon1_ldr.load(icon1_cmb.selectedItem.icon);
	}
	public function loadIcon2(eventObject) {
		_global.unSaved = true;
		icon2_ldr.load(icon2_cmb.selectedItem.icon);
	}
	private function save() {
		var newKeys = new Array();
		for (var index = 0; index < right_li.length; index++) {
			newKeys.push(right_li.getItemAt(index).label);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		dataObject.setData({keys:newKeys, name:name_ti.text, icon1:icon1_cmb.text, icon2:icon2_cmb.text, type:control_cmb.text});
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
	private function addSel() {
		_global.unSaved = true;
		if (left_li.selectedItems.length > 0) {
			for (var item = left_li.selectedIndices.length - 1; item >= 0; item--) {
				right_li.addItem(left_li.removeItemAt(left_li.selectedIndices[item]));
			}
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
	private function addAll() {
		_global.unSaved = true;
		right_li.removeAll();
		for (var key in available_keys) {
			right_li.addItem(available_keys[key]);
		}
		left_li.removeAll();
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
	private function remSel() {
		_global.unSaved = true;
		if (right_li.selectedItems.length > 0) {
			for (var item = right_li.selectedIndices.length - 1; item >= 0; item--) {
				left_li.addItem(right_li.removeItemAt(right_li.selectedIndices[item]));
			}
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
	private function remAll() {
		_global.unSaved = true;
		left_li.removeAll();
		right_li.removeAll();
		for (var key in available_keys) {
			left_li.addItem(available_keys[key]);
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
}
