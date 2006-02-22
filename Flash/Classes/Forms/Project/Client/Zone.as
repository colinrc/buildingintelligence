﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Zone extends Forms.BaseForm {
	private var rooms:Array;
	private var panels:Array;
	private var name_ti:TextInput;
	private var name:String;
	private var map_ti:TextInput;
	private var map:String;
	private var setMap_btn:Button;
	private var background_ti:TextInput;
	private var background:String;
	private var cycle_chk:CheckBox;
	private var cycle:String;
	private var alignment_cmb:ComboBox;
	private var alignment:String;
	private var hideFromList_chk:CheckBox;
	private var hideFromList:String;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var rooms_dg:DataGrid;
	private var add_room_btn:Button;
	private var del_room_btn:Button;
	private var dataGridHandler2:Object;
	private var panels_dg:DataGrid;
	private var add_panel_btn:Button;
	private var del_panel_btn:Button;
	public function init() {
		name_ti.text = name;
		map_ti.text = map;
		background_ti.text = background;
		/*********************************/
		for (var align in alignment_cmb.dataProvider) {
			if (alignment_cmb.dataProvider[align].label == alignment) {
				alignment_cmb.selectedIndex = align;
			}
		}
		/********************************/
		if (cycle == "true") {
			cycle_chk.selected = true;
		} else {
			cycle_chk.selected = false;
		}
		if (hideFromList == "true") {
			hideFromList_chk.selected = true;
		} else {
			hideFromList_chk.selected = false;
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(rooms_dg);
		dataGridHandler.addTextInputColumn("name", "Room Name", restrictions);
		var DP = new Array();
		for (var room in rooms) {
			var newRoom = new Object();
			newRoom.name = rooms[room].name;
			DP.push(newRoom);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		dataGridHandler2 = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler2.setDataGrid(panels_dg);
		dataGridHandler2.addTextInputColumn("name", "Panel Name", restrictions);
		var DP2 = new Array();
		for (var panel in panels) {
			var newPanel = new Object();
			newPanel.name = panels[panel].name;
			DP2.push(newPanel);
		}
		dataGridHandler2.setDataGridDataProvider(DP2);
		del_room_btn.addEventListener("click", Delegate.create(this, deleteRoom));
		add_room_btn.addEventListener("click", Delegate.create(this, addRoom));
		del_panel_btn.addEventListener("click", Delegate.create(this, deletePanel));
		add_panel_btn.addEventListener("click", Delegate.create(this, addPanel));
		setMap_btn.addEventListener("click", Delegate.create(this, setMap));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function setMap():Void {
		mdm.Dialogs.BrowseFile.title = "Please select a Map File";
		mdm.Dialogs.BrowseFile.filterList = "";
		mdm.Dialogs.BrowseFile.filterText = "";
		var tempString = mdm.Dialogs.BrowseFile.show();
		if (tempString != "false") {
			map_ti.text = tempString;
		}
	}	
	private function deleteRoom() {
		dataGridHandler.removeRow();
	}
	private function addRoom() {
		dataGridHandler.addBlankRow();
	}
	private function deletePanel() {
		dataGridHandler2.removeRow();
	}
	private function addPanel() {
		dataGridHandler2.addBlankRow();
	}
	public function save():Void {
		var newRooms = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Room = new Object();
			Room.name = DP[index].name;
			newRooms.push(Room);
		}
		var newPanels = new Array();
		var DP = dataGridHandler2.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Panel = new Object();
			Panel.name = DP[index].name;
			newPanels.push(Panel);
		}
		if (cycle_chk.selected) {
			cycle = "true";
		} else {
			cycle = "false";
		}
		if (hideFromList_chk.selected) {
			hideFromList = "true";
		} else {
			hideFromList = "false";
		}
		_global.left_tree.selectedNode.object.setData(new Object({panels:newPanels, rooms:newRooms, name:name_ti.text, map:map_ti.text, background:background_ti.text, cycle:cycle, alignment:alignment_cmb.selectedItem.label, hideFromList:hideFromList}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for (var child in _global.left_tree.selectedNode.childNodes) {
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1, "Placeholder"));
		for (var child in newNode.childNodes) {
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);
	}
}
