import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Settings extends Forms.BaseForm {
	private var save_btn:Button;
	private var left_li:List;
	private var right_li:List;
	private var form_mc:MovieClip;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var active_lb:Label;
	private var avail_lb:Label;	
	private var settings:XMLNode;
	private var dataObject:Object;
	private var adminPin:String;
	private var adminPin_ti:TextInput;
	private var applicationXML:String;
	private var applicationXML_ti:TextInput;
	private var integratorHtml:String;
	private var integratorHtml_ti:TextInput;
	public function onLoad():Void {
		adminPin_ti.restrict = "0-9";
		if (adminPin.length) {
			adminPin_ti.text = adminPin;
		}
		if (applicationXML.length) {
			applicationXML_ti.text = applicationXML;
		}
		if (integratorHtml.length) {
			integratorHtml_ti.text = integratorHtml;
		}
		var tempNode = _global.overrides_xml.firstChild;
		for (var child in tempNode.childNodes) {
			for (var index in tempNode.childNodes[child].childNodes) {
				var tempObject = new Object();
				tempObject.label = tempNode.childNodes[child].childNodes[index].attributes["name"];
				tempObject.type = tempNode.childNodes[child].childNodes[index].attributes["type"];
				tempObject.def = tempNode.childNodes[child].childNodes[index].attributes["default"];
				tempObject.description = tempNode.childNodes[child].childNodes[index].attributes["description"];
				left_li.addItem(tempObject);
			}
		}
		for (var child in settings.childNodes) {
			var tempObject = new Object();
			tempObject.label = settings.childNodes[child].attributes["name"];
			tempObject.value = settings.childNodes[child].attributes["value"];
			for (var override in tempNode.childNodes) {
				for (var index in tempNode.childNodes[override].childNodes) {
					if (settings.childNodes[child].attributes["name"] == tempNode.childNodes[override].childNodes[index].attributes["name"]) {
						tempObject.type = tempNode.childNodes[override].childNodes[index].attributes["type"];
						tempObject.def = tempNode.childNodes[override].childNodes[index].attributes["default"];
						tempObject.description = tempNode.childNodes[override].childNodes[index].attributes["description"];
						right_li.addItem(tempObject);
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
		setAdvanced();
	}
	private function rightListChange(eventObj) {
		_global.unSaved = true;
		form_mc = this.createEmptyMovieClip("form_mc", 0);
		form_mc = this.attachMovie("forms.project.client." + eventObj.target.selectedItem.type + "edit", "form_mc", 0, {setting:eventObj.target.selectedItem});
		form_mc._x = 0;
		form_mc._y = 545;
	}
	public function setAdvanced(){
		left_li.visible =_global.advanced;
		left_li.selectedIndex = undefined;
		right_li.visible =_global.advanced;
		right_li.selectedIndex = undefined;
		form_mc = this.createEmptyMovieClip("form_mc", 0);
		addSelected_btn.visible =_global.advanced;
		addAll_btn.visible =_global.advanced;
		removeSelected_btn.visible =_global.advanced;
		removeAll_btn.visible =_global.advanced;
		active_lb.visible =_global.advanced;
		avail_lb.visible =_global.advanced;
	}
	private function save() {
		var newNode = new XMLNode(1, "settings");
		for (var index = 0; index < right_li.length; index++) {
			var newOverride = new XMLNode(1, "setting");
			newOverride.attributes["name"] = right_li.getItemAt(index).label;
			newOverride.attributes["value"] = right_li.getItemAt(index).value;
			newNode.appendChild(newOverride);
		}
		dataObject.setData({settings:newNode, adminPin:adminPin_ti.text, applicationXML:applicationXML_ti.text, integratorHtml:integratorHtml_ti.text});
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
			form_mc = this.createEmptyMovieClip("form_mc", 0);
		}
	}
	private function remAll() {
		_global.unSaved = true;
		right_li.removeAll();
		form_mc = this.createEmptyMovieClip("form_mc", 0);
	}
}
