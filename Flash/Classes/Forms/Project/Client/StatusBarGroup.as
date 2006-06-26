import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.StatusBarGroup extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var icon_cmb:ComboBox;
	private var icon_ldr:Loader;	
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
	private var canOpen:String;
	private var canOpen_chk:CheckBox;	
	private var groups:XMLNode;
	public function onLoad():Void {
		icon_ldr.autoLoad = true;
		icon_ldr.scaleContent = true;		
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
		show_ti.addEventListener("change", changeListener);
		hide_ti.addEventListener("change", changeListener);
		var tempKeys = _global.serverDesign.getKeys();
		var temp_node = _global.left_tree.selectedNode;
		var client = null;
		while ((temp_node != null) && (client == null)) {
			if (temp_node.nodeName == "Client") {
				client = temp_node.object;
				break;
			} else {
				temp_node = temp_node.parentNode;
			}
		}
		groups = client.getKeyGroups();
		for(var index = 0; index<groups.childNodes.length;index++){
			var tempObject = new Object();
			tempObject.label = "Group: "+groups.childNodes[index].attributes.name;
			left_li.addItem(tempObject);
		}
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
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
		name_ti.text = name;
		if(icon.length){
			icon_cmb.text = icon;
			icon_ldr.load(mdm.Application.path+"lib\\icons\\"+icon+".png");
		} 
		if (canOpen == "superuser") {
			canOpen_chk.selected = true;
		} else {
			canOpen_chk.selected = false;
		}
		right_li.multipleSelection = true; 
		left_li.multipleSelection = true; 
		canOpen_chk.addEventListener("change", Delegate.create(this,changeListener.change));		
		show_ti.text = show;
		hide_ti.text = hide;
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
		icon_cmb.addEventListener("change", Delegate.create(this, loadIcon));			
	}
	public function loadIcon(eventObject){
		_global.unSaved = true;
		icon_ldr.load(icon_cmb.selectedItem.icon);
	}	
	private function save() {
		if (canOpen_chk.selected) {
			var newCanOpen = "superuser";
		} else {
			var newCanOpen = "";
		}		
		var newControls = new Array();
		for (var index = 0; index < right_li.length; index++) {
			var newControl = new XMLNode(1, "control");
			newControl.attributes["key"] = right_li.getItemAt(index).label;
			newControls.push(newControl);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		dataObject.setData({controls:newControls, name:name_ti.text, icon:icon_cmb.text, show:show_ti.text, hide:hide_ti.text, canOpen:newCanOpen});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
	private function addSel() {
		_global.unSaved = true;
		if (left_li.selectedItems.length > 0) {
			for (var item = left_li.selectedIndices.length - 1; item >= 0; item--) {
				if (left_li.getItemAt(left_li.selectedIndices[item]).label.lastIndexOf("Group: ") != -1) {
					for (var group in groups.childNodes) {
						if (groups.childNodes[group].attributes.name == left_li.getItemAt(left_li.selectedIndices[item]).label.substring(left_li.getItemAt(left_li.selectedIndices[item]).label.lastIndexOf(" ") + 1)) {
							icon_cmb.text = groups.childNodes[group].attributes.icon2;
							icon_ldr.load(mdm.Application.path + "lib\\icons\\" + groups.childNodes[group].attributes.icon2 + ".png");
							for (var keyNode in groups.childNodes[group].childNodes) {
								var key = groups.childNodes[group].childNodes[keyNode].attributes.name;
								for (var item in left_li.dataProvider) {
									if (left_li.dataProvider[item].label == key) {
										right_li.addItem(left_li.removeItemAt(item));
										break;
									}
								}
							}
						}
					}
				} else {
					right_li.addItem(left_li.removeItemAt(left_li.selectedIndices[item]));
				}
			}
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
		for(var index = 0; index<groups.childNodes.length;index++){
			var tempObject = new Object();
			tempObject.label = "Group: "+groups.childNodes[index].attributes.name;
			left_li.addItem(tempObject);
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
	private function remSel() {
		_global.unSaved = true;
		if (right_li.selectedItems.length > 0) {
			for(var item = right_li.selectedIndices.length-1; item>=0;item--){
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
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
		for(var index = 0; index<groups.childNodes.length;index++){
			var tempObject = new Object();
			tempObject.label = "Group: "+groups.childNodes[index].attributes.name;
			left_li.addItem(tempObject);
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
	}
}
