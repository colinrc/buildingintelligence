import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Overrides extends Forms.BaseForm {
	private var save_btn:Button;
	private var left_li:List;
	private var right_li:List;
	private var form_mc:MovieClip;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var attributes:Array;
	private var attributeGroups:Array;
	private var dataObject:Object;
	public function onLoad():Void {
		var tempNode = _global.overrides_xml.firstChild;
		for (var child in tempNode.childNodes) {
			var flag = false;
			for(var group in attributeGroups){
				if(tempNode.childNodes[child].nodeName == attributeGroups[group]){
					flag = true;
					break;
				}
			}
			if(flag){
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
		for (var attribute in attributes) {
			var tempObject = new Object();
			tempObject.label = attributes[attribute].name;
			tempObject.value = attributes[attribute].value;
			for (var index in left_li.dataProvider) {
				if (tempObject.label == left_li.dataProvider[index].label) {
						tempObject.type = left_li.dataProvider[index].type;
						tempObject.def = left_li.dataProvider[index].def;
						tempObject.description = left_li.dataProvider[index].description;
						right_li.addItem(tempObject);
						left_li.removeItemAt(index);
						break;
				}
			}
		}
		right_li.multipleSelection = true; 
		left_li.multipleSelection = true; 
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
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
	public function setAdvanced() {
	}
	private function save() {
		var newAttributes = new Array();
		for (var index = 0; index < right_li.length; index++) {
			var newOverride = new Object();
			newOverride.name = right_li.getItemAt(index).label;
			newOverride.value = right_li.getItemAt(index).value;
			newAttributes.push(newOverride);
		}
		dataObject.setAttributes(newAttributes);
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
	private function addSel() {
		_global.unSaved = true;
		if (left_li.selectedItems.length > 0) {
			for(var item = left_li.selectedIndices.length-1; item>=0;item--){
				var newObject = new Object();
				newObject.label = left_li.getItemAt(left_li.selectedIndices[item]).label;
				newObject.def = left_li.getItemAt(left_li.selectedIndices[item]).def;
				newObject.value = left_li.getItemAt(left_li.selectedIndices[item]).def;
				newObject.type = left_li.getItemAt(left_li.selectedIndices[item]).type;
				newObject.description = left_li.getItemAt(left_li.selectedIndices[item]).description;
				left_li.removeItemAt(left_li.selectedIndices[item]);
				right_li.addItem(newObject);
			}			
			right_li.sortItemsBy("label", "ASC");
		}
	}
	private function addAll() {
		_global.unSaved = true;
		var leftLength = left_li.length;
		for (var leftIndex = 0; leftIndex < leftLength; leftIndex++) {
			var newObject = new Object();
			newObject.label = left_li.getItemAt(0).label;
			newObject.def = left_li.getItemAt(0).def;
			newObject.value = left_li.getItemAt(0).def;
			newObject.type = left_li.getItemAt(0).type;
			newObject.description = left_li.getItemAt(0).description;
			left_li.removeItemAt(0);
			right_li.addItem(newObject);
		}
		right_li.sortItemsBy("label", "ASC");
	}
	private function remSel() {
		_global.unSaved = true;
		if (right_li.selectedItems.length > 0) {
			for(var item = right_li.selectedIndices.length-1; item>=0;item--){
				left_li.addItem(right_li.removeItemAt(right_li.selectedIndices[item]));
			}
			left_li.sortItemsBy("label", "ASC");
			form_mc = this.createEmptyMovieClip("form_mc", 0);
		}
	}
	private function remAll() {
		_global.unSaved = true;
		var rightLength = right_li.length;
		for (var rightIndex = 0; rightIndex < rightLength; rightIndex++) {
			left_li.addItem(right_li.removeItemAt(0));
		}
		form_mc = this.createEmptyMovieClip("form_mc", 0);
		left_li.sortItemsBy("label", "ASC");
	}
}
