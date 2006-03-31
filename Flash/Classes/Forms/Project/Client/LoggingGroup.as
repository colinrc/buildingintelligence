import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.LoggingGroup extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var icon_cmb:ComboBox;
	private var icon_ldr:Loader;	
	private var listenTo_ti:TextInput;
	private var type_cmb:ComboBox;
	private var logType_ld:Loader;
	private var form_mc:MovieClip;
	private var name:String;
	private var icon:String;
	private var listenTo:String;
	private var type:String;
	private var save_btn:Button;
	private var left_li:List;
	private var right_li:List;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var controls:Array;
	private var attributes:Array;
	private var dataObject:Object;
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
			for (var index = 0; index<leftLength;index++) {
				if (controls[control].attributes["key"] == left_li.getItemAt(index).label) {
					right_li.addItem(tempObject);
					left_li.removeItemAt(index);
					break;
				}
			}
		}
		name_ti.text = name;
		if(icon.length){
			icon_cmb.text = icon;
			icon_ldr.load(mdm.Application.path+"lib\\icons\\"+icon+".png");
		} 
		listenTo_ti.text = listenTo;
		for (var index = 0; index < type_cmb.length; index++) {
			if (type == type_cmb.getItemAt(index).label) {
				type_cmb.selectedIndex = index;
			}
		}
		typeChange();
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
		type_cmb.addEventListener("change", Delegate.create(this, typeChange));
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		listenTo_ti.addEventListener("change", changeListener);
		type_cmb.addEventListener("change", changeListener);
		icon_cmb.addEventListener("change", Delegate.create(this, loadIcon));			
	}
	public function loadIcon(eventObject){
		_global.unSaved = true;
		icon_ldr.load(icon_cmb.selectedItem.icon);
	}	
	private function typeChange() {
		//_global.unSaved = true;
		logType_ld.createEmptyMovieClip("form_mc", 0);
		var dataObj = new Object();
		switch (type_cmb.selectedItem.label) {
		case "web" :
			for (var attribute in attributes) {
				if (attributes[attribute].name == "url") {
					dataObj.url = attributes[attribute].value;
				}
			}
			break;
		case "tally" :
		case "log" :
			for (var attribute in attributes) {
				if (attributes[attribute].name == "label") {
					dataObj.label = attributes[attribute].value;
				}
				if (attributes[attribute].name == "timeformat") {
					dataObj.timeformat = attributes[attribute].value;
				}
			}
			break;
		}
		form_mc = logType_ld.attachMovie("forms.project.client.logging" + type_cmb.selectedItem.label, "form"+random(999)+"_mc", 0, dataObj);
	}
	private function save() {
		var newControls = new Array();
		for (var index = 0; index < right_li.length; index++) {
			var newControl = new XMLNode(1, "control");
			newControl.attributes["key"] = right_li.getItemAt(index).label;
			newControls.push(newControl);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		attributes = new Array();
		switch (type_cmb.selectedItem.label) {
		case "web" :
			attributes.push({name:"url", value:form_mc.url_ti.text});
			break;
		case "tally" :
			attributes.push({name:"label", value:form_mc.label_ti.text});
			attributes.push({name:"timeformat", value:form_mc.timeformat_cmb.text});
			break;
		case "log" :
			attributes.push({name:"label", value:form_mc.label_ta.text});
			attributes.push({name:"timeformat", value:form_mc.timeformat_cmb.text});
			break;
		}
		dataObject.setData({controls:newControls, name:name_ti.text, icon:icon_cmb.text, listenTo:listenTo_ti.text, type:type_cmb.selectedItem.label, attributes:attributes});
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
