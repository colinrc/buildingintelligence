﻿import mx.controls.*;
import mx.utils.Delegate;
import mdm.Dialogs.BrowseFile;
class Forms.Project.Client.Icon extends Forms.BaseForm {
	private var save_btn:Button;
	private var left_li:List;
	private var right_li:List;
	private var variable_ld:Loader;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var variable_mc:MovieClip;
	private var attributes:Array;
	private var name:String;
	private var name_ti:TextInput;
	private var icon:String;
	private var icon_ti:TextInput;
	private var func:String;
	private var func_cmb:ComboBox;
	private var canOpen:String;
	private var canOpen_chk:CheckBox;
	private var dataObject:Object;
	private var param:String;
	private var param_ti:TextInput;
	private var param_lb:Label;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
			if (func_cmb.text == "runexe") {
				param_ti.visible = true;
				param_lb.visible = true;
			} else {
				param_ti.visible = false;
				param_lb.visible = false;
				param_ti.text = "";
			}
		};
		if (func == "runexe") {
			param_ti.visible = true;
			param_lb.visible = true;
			param_ti.text = param;
		} else {
			param_ti.visible = false;
			param_lb.visible = false;
			param_ti.text = "";
		}
		name_ti.addEventListener("change", Delegate.create(this,changeListener.change));
		icon_ti.addEventListener("change", Delegate.create(this,changeListener.change));
		func_cmb.addEventListener("change", Delegate.create(this,changeListener.change));
		canOpen_chk.addEventListener("change", Delegate.create(this,changeListener.change));
		param_ti.addEventListener("change", Delegate.create(this,changeListener.change));
		var tempNode = _global.overrides_xml.firstChild;
		for (var child in tempNode.childNodes) {
			if (tempNode.childNodes[child].nodeName == "button") {
				for (var index in tempNode.childNodes[child].childNodes) {
					var tempObject = new Object();
					tempObject.label = tempNode.childNodes[child].childNodes[index].attributes["name"];
					tempObject.type = tempNode.childNodes[child].childNodes[index].attributes["type"];
					tempObject.def = tempNode.childNodes[child].childNodes[index].attributes["default"];
					tempObject.description = tempNode.childNodes[child].childNodes[index].attributes["description"];
					left_li.addItem(tempObject);
				}
			}
		}
		name_ti.text = name;
		icon_ti.text = icon;
		func_cmb.text = func;
		if (canOpen == "superuser") {
			canOpen_chk.selected = true;
		} else {
			canOpen_chk.selected = false;
		}
		for (var attribute in attributes) {
			var tempObject = new Object();
			tempObject.label = attributes[attribute].name;
			tempObject.value = attributes[attribute].value;
			for (var override in tempNode.childNodes) {
				if (tempNode.childNodes[override].nodeName == "button") {
					for (var index in tempNode.childNodes[override].childNodes) {
						if (attributes[attribute].name == tempNode.childNodes[override].childNodes[index].attributes["name"]) {
							tempObject.type = tempNode.childNodes[override].childNodes[index].attributes["type"];
							tempObject.def = tempNode.childNodes[override].childNodes[index].attributes["default"];
							tempObject.description = tempNode.childNodes[override].childNodes[index].attributes["description"];
							right_li.addItem(tempObject);
						}
					}
				}
			}
		}
		right_li.addEventListener("change", Delegate.create(this, rightListChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
	}
	private function rightListChange(eventObj) {
		_global.unSaved = true;
		variable_ld.createEmptyMovieClip("form_mc", 0);
		variable_ld.attachMovie("forms.project.client." + eventObj.target.selectedItem.type + "edit", "form_mc", 0, {setting:eventObj.target.selectedItem});
	}
	private function save() {
		var newAttributes = new Array();
		for (var index = 0; index < right_li.length; index++) {
			var newOverride = new Object();
			newOverride.name = right_li.getItemAt(index).label;
			newOverride.value = right_li.getItemAt(index).value;
			newAttributes.push(newOverride);
		}
		if (canOpen_chk.selected) {
			var newCanOpen = "superuser";
		} else {
			var newCanOpen = "";
		}
		dataObject.setData({attributes:newAttributes, name:name_ti.text, icon:icon_ti.text, func:func_cmb.text, param:param_ti.text, canOpen:newCanOpen});
		_global.saveFile("Project");
	}
	private function addSel() {
		_global.unSaved = true;
		if (left_li.selectedItem != undefined) {
			var flag = false;
			for (var index = 0; index < right_li.length; index++) {
				if (left_li.selectedItem.label == right_li.getItemAt(index).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = left_li.selectedItem.label;
				newObject.def = left_li.selectedItem.def;
				newObject.value = left_li.selectedItem.def;
				newObject.type = left_li.selectedItem.type;
				newObject.description = left_li.selectedItem.description;
				right_li.addItem(newObject);
			}
		}
	}
	private function addAll() {
		_global.unSaved = true;
		for (var leftIndex = 0; leftIndex < left_li.length; leftIndex++) {
			var flag = false;
			for (var rightIndex = 0; rightIndex < right_li.length; rightIndex++) {
				if (left_li.getItemAt(leftIndex).label == right_li.getItemAt(rightIndex).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = left_li.getItemAt(leftIndex).label;
				newObject.def = left_li.getItemAt(leftIndex).def;
				newObject.value = left_li.getItemAt(leftIndex).def;
				newObject.type = left_li.getItemAt(leftIndex).type;
				newObject.description = left_li.getItemAt(leftIndex).description;
				right_li.addItem(newObject);
			}
		}
	}
	private function remSel() {
		_global.unSaved = true;
		if (right_li.selectedItem != undefined) {
			right_li.removeItemAt(right_li.selectedIndex);
			variable_ld.createEmptyMovieClip("form_mc", 0);
		}
	}
	private function remAll() {
		_global.unSaved = true;
		right_li.removeAll();
		variable_ld.createEmptyMovieClip("form_mc", 0);
	}
}
