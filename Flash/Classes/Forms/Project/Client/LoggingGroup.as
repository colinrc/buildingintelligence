import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.LoggingGroup extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var icon_ti:TextInput;
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
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		icon_ti.addEventListener("change", changeListener);
		listenTo_ti.addEventListener("change", changeListener);
		type_cmb.addEventListener("change", changeListener);		
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
	}
	private function typeChange() {
		_global.unSaved = true;		
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
		form_mc = logType_ld.attachMovie("forms.project.client.logging" + type_cmb.selectedItem.label, "form_mc", 0, dataObj);
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
			attributes.push({name:"timeformat", value:form_mc.timeformat_ti.text});
			break;
		case "log" :
			attributes.push({name:"label", value:form_mc.label_ta.text});
			attributes.push({name:"timeformat", value:form_mc.timeformat_ti.text});
			break;
		}
		dataObject.setData({controls:newControls, name:name_ti.text, icon:icon_ti.text, listenTo:listenTo_ti.text, type:type_cmb.selectedItem.label, attributes:attributes});
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
				right_li.addItem(newObject);
			}
		}
	}
	private function remSel() {
		_global.unSaved = true;
		if (right_li.selectedItem != undefined) {
			right_li.removeItemAt(right_li.selectedIndex);
		}
	}
	private function remAll() {
		_global.unSaved = true;
		right_li.removeAll();
	}
}
