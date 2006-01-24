import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.StatusBar extends Forms.BaseForm {
	private var save_btn:Button;
	private var add_grp_btn:Button;
	private var del_grp_btn:Button;
	private var update_grp_btn:Button;
	private var group_name_ti:TextInput;
	private var left_li:List;
	private var right_li:List;
	private var variable_ld:Loader;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var variable_mc:MovieClip;
	private var groups_cmb:ComboBox;
	private var groups:Array;
	
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
		for(var group in groups){
			groups_cmb.addItem({label:groups[group].name,data:groups[group].attributes});
		}
		right_li.addEventListener("change", Delegate.create(this, rightListChange));
		groups_cmb.addEventListener("change", Delegate.create(this, groupChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
		addSelected_btn.addEventListener("click", Delegate.create(this,addSel));
		addAll_btn.addEventListener("click", Delegate.create(this,addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this,remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this,remAll));
		update_grp_btn.addEventListener("click", Delegate.create(this,updateGroup));
		add_grp_btn.addEventListener("click", Delegate.create(this,addGroup));
		del_grp_btn.addEventListener("click", Delegate.create(this,delGroup));
		groupChange(new Object());
	}
	private function updateGroup(){
		var newAttributes = new Array();
		for (var index = 0; index<right_li.length; index++) {
			var newOverride = new Object();
			newOverride.name = right_li.getItemAt(index).label;
			newOverride.value = right_li.getItemAt(index).value;
			newAttributes.push(newOverride);
		}
		groups_cmb.selectedItem.data = newAttributes;
	}
	private function addGroup(){
		groups_cmb.addItem({label:group_name_ti.text});
	}
	private function delGroup(){
		groups_cmb.removeItemAt(groups_cmb.selectedIndex);
		groups_cmb.selectedIndex = 0;
		groupChange(new Object());
	}
	private function groupChange(eventObj){
		var tempAttributes = groups_cmb.selectedItem.data;
		right_li.removeAll();
		variable_ld.createEmptyMovieClip("form_mc",0);
		for(var attribute in tempAttributes){
			var tempObject = new Object();
			tempObject.label = tempAttributes[attribute].name;
			tempObject.value = tempAttributes[attribute].value;
			for(var index =0; index<left_li.length; index++){
				if(tempAttributes[attribute].name == left_li.getItemAt(index).label){
					tempObject.type = left_li.getItemAt(index).type;
					tempObject.def = left_li.getItemAt(index).def;
					tempObject.description = left_li.getItemAt(index).description;
					right_li.addItem(tempObject);
				}
			}
		}
	}
	private function rightListChange(eventObj){
		variable_ld.createEmptyMovieClip("form_mc",0);
		variable_ld.attachMovie("forms.project.client."+eventObj.target.selectedItem.type+"edit", "form_mc", 0, {setting:eventObj.target.selectedItem});
	}
	private function save(){
		var newGroups = new Array();
		for(var index = 0; index < groups_cmb.length; index++){
			var Group = new Object();
			Group.name = groups_cmb.getItemAt(index).label;
			Group.attributes = groups_cmb.getItemAt(index).data;
			newGroups.push(Group);
		}
		_global.left_tree.selectedNode.object.setData(new Object({groups:newGroups}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for(var child in _global.left_tree.selectedNode.childNodes){
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1,"Placeholder"));
		for(var child in newNode.childNodes){
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,true);
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
