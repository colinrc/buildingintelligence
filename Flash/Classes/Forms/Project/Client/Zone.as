﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Zone extends Forms.BaseForm {
	private var rooms:Array;
	private var panels:Array;
	private var name_ti:TextInput;
	private var name:String;
	private var map_cmb:ComboBox;
	private var map:String;
	private var background_cmb:ComboBox;
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
	private var dataObject:Object;	
	public function onLoad() {
		map_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myMaps = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\maps", "*.png");
		myMaps = myMaps.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\maps", "*.swf"));
		myMaps.sort();
		for(var myMap =0; myMap <myMaps.length; myMap++){
			var newMap = new Object();
			newMap.label = myMaps[myMap];
			newMap.icon = mdm.Application.path+"lib\\maps\\"+myMaps[myMap];
			map_cmb.addItem(newMap);
		}
		background_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myBGs = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.jpg");
		myBGs = myBGs.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.png"));
		myBGs = myBGs.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.swf"));		
		myBGs.sort();
		for(var myBG =0; myBG <myBGs.length; myBG++){
			var newBG = new Object();
			newBG.label = myBGs[myBG];
			newBG.icon = mdm.Application.path+"lib\\backgrounds\\"+myBGs[myBG];
			background_cmb.addItem(newBG);
		}		
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);	
		map_cmb.addEventListener("change", changeListener);	
		background_cmb.addEventListener("change", changeListener);	
		cycle_chk.addEventListener("change", changeListener);	
		alignment_cmb.addEventListener("change", changeListener);	
		hideFromList_chk.addEventListener("change", changeListener);			
		name_ti.text = name;
		map_cmb.text = map;
		background_cmb.text = background;
		/*********************************/
		for (var align in alignment_cmb.dataProvider) {
			if (alignment_cmb.dataProvider[align].label == alignment) {
				alignment_cmb.selectedIndex = parseInt(align);
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
		dataGridHandler.addTextInputColumn("name", "Room Name", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");		
		var DP = new Array();
		for (var room in rooms) {
			var newRoom = new Object();
			newRoom.name = rooms[room].name;
			newRoom.id = rooms[room].id;			
			DP.push(newRoom);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		dataGridHandler2 = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler2.setDataGrid(panels_dg);
		dataGridHandler2.addTextInputColumn("name", "Panel Name", restrictions,false,150);
		dataGridHandler2.addHiddenColumn("id");		
		var DP2 = new Array();
		for (var panel in panels) {
			var newPanel = new Object();
			newPanel.name = panels[panel].name;
			newPanel.id = panels[panel].id;			
			DP2.push(newPanel);
		}
		dataGridHandler2.setDataGridDataProvider(DP2);
		del_room_btn.addEventListener("click", Delegate.create(this, deleteRoom));
		add_room_btn.addEventListener("click", Delegate.create(this, addRoom));
		del_panel_btn.addEventListener("click", Delegate.create(this, deletePanel));
		add_panel_btn.addEventListener("click", Delegate.create(this, addPanel));
		save_btn.addEventListener("click", Delegate.create(this, save));
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
			Room.id = DP[index].id;			
			newRooms.push(Room);
		}
		var newPanels = new Array();
		var DP = dataGridHandler2.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Panel = new Object();
			Panel.name = DP[index].name;
			Panel.id = DP[index].id;			
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
		dataObject.setData({panels:newPanels, rooms:newRooms, name:name_ti.text, map:map_cmb.text, background:background_cmb.text, cycle:cycle, alignment:alignment_cmb.selectedItem.label, hideFromList:hideFromList});
		_global.refreshTheTree();				
		_global.saveFile("Project");
	}
}
