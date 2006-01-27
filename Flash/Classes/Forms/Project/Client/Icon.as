import mx.controls.*;
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
	private var func_ti:TextInput;
	private var canOpen:String;
	private var canOpen_ti:TextInput;
	
	public function init():Void{
		var tempNode = _global.overrides_xml.firstChild;
		for(var child in tempNode.childNodes){
			var tempObject = new Object();
			tempObject.label = tempNode.childNodes[child].attributes["name"];
			tempObject.type = tempNode.childNodes[child].attributes["type"];
			tempObject.def = tempNode.childNodes[child].attributes["default"];
			tempObject.description = tempNode.childNodes[child].attributes["description"];
			left_li.addItem(tempObject);
		}
		name_ti.text = name;
		icon_ti.text = icon;
		func_ti.text = func;
		canOpen_ti.text = canOpen;
		for(var attribute in attributes){
			var tempObject = new Object();
			tempObject.label = attributes[attribute].name;
			tempObject.value = attributes[attribute].value;
			for(var override in tempNode.childNodes){
				if(attributes[attribute].name == tempNode.childNodes[override].attributes["name"]){
					tempObject.type = tempNode.childNodes[override].attributes["type"];
					tempObject.def = tempNode.childNodes[override].attributes["default"];
					tempObject.description = tempNode.childNodes[override].attributes["description"];
					right_li.addItem(tempObject);
				}
			}
		}
		right_li.addEventListener("change", Delegate.create(this, rightListChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this,addSel));
		addAll_btn.addEventListener("click", Delegate.create(this,addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this,remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this,remAll));
	}
	private function rightListChange(eventObj){
		variable_ld.createEmptyMovieClip("form_mc",0);
		variable_ld.attachMovie("forms.project.client."+eventObj.target.selectedItem.type+"edit", "form_mc", 0, {setting:eventObj.target.selectedItem});
	}
	private function save(){
		var newAttributes = new Array();
		for (var index = 0; index<right_li.length; index++) {
			var newOverride = new Object();
			newOverride.name = right_li.getItemAt(index).label;
			newOverride.value = right_li.getItemAt(index).value;
			newAttributes.push(newOverride);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({attributes:newAttributes,name:name,icon:icon,func:func,canOpen:canOpen}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
	private function addSel(){
		if(left_li.selectedItem != undefined){
			var flag = false;
			for (var index = 0; index<right_li.length; index++) {
				if(left_li.selectedItem.label == right_li.getItemAt(index).label){
					flag =true;
				}
			}
			if(!flag){
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
	private function addAll(){
		for (var leftIndex = 0; leftIndex<left_li.length; leftIndex++) {
			var flag = false;
			for (var rightIndex = 0; rightIndex<right_li.length; rightIndex++) {
				if(left_li.getItemAt(leftIndex).label == right_li.getItemAt(rightIndex).label){
					flag =true;
				}
			}
			if(!flag){
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
	private function remSel(){
		if(right_li.selectedItem != undefined){
			right_li.removeItemAt(right_li.selectedIndex);
			variable_ld.createEmptyMovieClip("form_mc",0);
		}
	}
	private function remAll(){
		right_li.removeAll();
		variable_ld.createEmptyMovieClip("form_mc",0);
	}
}
