﻿import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.StatusBar extends Forms.BaseForm {
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var groups_dg:DataGrid;
	private var groups:Array;
	private var dataGridHandler:Object;	
	public function init():Void{
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(groups_dg);
		dataGridHandler.addTextInputColumn("name", "Group Name", restrictions);
		var DP = new Array();		
		for(var group in groups){
			DP.push({name:groups[group].name});
		}
		dataGridHandler.setDataGridDataProvider(DP);
		save_btn.addEventListener("click", Delegate.create(this, save));
		new_btn.addEventListener("click", Delegate.create(this,newItem));
		delete_btn.addEventListener("click", Delegate.create(this,deleteItem));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}	
	private function save(){
		var newGroups = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Group = new Object();
			if(DP[index].name.length){
				Group.name = DP[index].name;
			}
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
}
