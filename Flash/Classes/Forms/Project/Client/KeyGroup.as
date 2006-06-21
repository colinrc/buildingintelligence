import mx.controls.*;
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
	private var controlType:String;
	private var save_btn:Button;
	private var left_li:List;
	private var right_li:List;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var dataObject:Object;
	public function onLoad():Void {
		icon1_ldr.autoLoad = true;
		icon1_ldr.scaleContent = true;		
		icon1_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		icon2_ldr.autoLoad = true;
		icon2_ldr.scaleContent = true;		
		icon2_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\icons", "*.png");
		for(var myIcon =0; myIcon <myIcons.length; myIcon++){
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path+"lib\\icons\\"+myIcons[myIcon];
			icon1_cmb.addItem(newIcon);
			icon2_cmb.addItem(newIcon);
		}
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		/*POPULATE CONTROL TYPES*/
		control_cmb.addEventListener("change", changeListener);

		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			/*POPULATE LIST BASED ON CONTENTS OF OTHER GROUPS*/
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}

		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
		name_ti.text = name;
		if(icon1.length){
			icon1_cmb.text = icon1;
			icon1_ldr.load(mdm.Application.path+"lib\\icons\\"+icon1+".png");
		} 
		if(icon2.length){
			icon2_cmb.text = icon2;
			icon2_ldr.load(mdm.Application.path+"lib\\icons\\"+icon2+".png");
		} 
		if(controlType.length){
			control_cmb.text = controlType;
		}
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
		icon1_cmb.addEventListener("change", Delegate.create(this, loadIcon1));
		icon2_cmb.addEventListener("change", Delegate.create(this, loadIcon2));
	}
	public function loadIcon1(eventObject){
		_global.unSaved = true;
		icon1_ldr.load(icon1_cmb.selectedItem.icon);
	}	
	public function loadIcon2(eventObject){
		_global.unSaved = true;
		icon2_ldr.load(icon2_cmb.selectedItem.icon);
	}	
	private function save() {
		var newKeys = new Array();
		for (var index = 0; index < right_li.length; index++) {
			newKeys.push(right_li.getItemAt(index).label);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		dataObject.setData({keys:newKeys, name:name_ti.text, icon1:icon1_cmb.text,icon2:icon2_cmb.text, controlType:control_cmb.text});
		_global.refreshTheTree();		
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
