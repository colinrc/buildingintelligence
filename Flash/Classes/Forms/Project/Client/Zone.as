import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Zone extends Forms.BaseForm  {
	private var rooms:Array;
	private var panels:Array;
	private var name_ti:TextInput;
	private var name:String;
	private var map_ti:TextInput;
	private var map:String;
	private var background_ti:TextInput;
	private var background:String;
	private var cycle_chk:CheckBox;
	private var cycle:String;
	private var alignment_ti:TextInput;
	private var alignment:String;
	private var hideFromList_chk:CheckBox;
	private var hideFromList:String;
	private var rooms_li:List;
	private var add_room_btn:Button;
	private var del_room_btn:Button;
	private var roomName_ti:TextInput;
	private var panels_li:List;
	private var add_panel_btn:Button;
	private var del_panel_btn:Button;
	private var panelName_ti:TextInput;	
	private var save_btn:Button;
	public function init() {
		name_ti.text = name;
		map_ti.text = map;
		background_ti.text = background;
		alignment_ti.text = alignment;
		if(cycle == "true"){
			cycle_chk.selected = true;
		}
		else{
			cycle_chk.selected = false;
		}
		if(hideFromList == "true"){
			hideFromList_chk.selected = true;
		}
		else{
			hideFromList_chk.selected = false;
		}
		for (var room in rooms) {
			rooms_li.addItem({name:rooms[room].name});
		}
		for (var panel in panels) {
			panels_li.addItem({name:panels[panel].name});
		}		
		del_room_btn.enabled = false;
		del_panel_btn.enabled = false;		
		del_room_btn.addEventListener("click", Delegate.create(this, deleteRoom));
		add_room_btn.addEventListener("click", Delegate.create(this, addRoom));
		rooms_li.addEventListener("change", Delegate.create(this, roomChange));
		del_panel_btn.addEventListener("click", Delegate.create(this, deletePanel));
		add_panel_btn.addEventListener("click", Delegate.create(this, addPanel));
		panels_li.addEventListener("change", Delegate.create(this, panelChange));		
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteRoom() {
		rooms_li.removeItemAt(rooms_li.selectedIndex);
		rooms_li.selectedIndex = undefined;
		del_room_btn.enabled = false;
	}
	private function addRoom() {
		rooms_li.addItem({name:roomName_ti.text});
		rooms_li.selectedIndex = undefined;
		roomName_ti.text = "";
		del_room_btn.enabled = false;
	}
	private function roomChange(evtObj) {
		del_room_btn.enabled = true;
	}
	private function deletePanel() {
		panels_li.removeItemAt(panels_li.selectedIndex);
		panels_li.selectedIndex = undefined;
		del_panel_btn.enabled = false;
	}
	private function addPanel() {
		panels_li.addItem({name:panelName_ti.text});
		panels_li.selectedIndex = undefined;
		panelName_ti.text = "";
		del_panel_btn.enabled = false;
	}
	private function panelChange(evtObj) {
		del_panel_btn.enabled = true;
	}
	public function save():Void {
		var newRooms = new Array();
		for(var index = 0; index < rooms_li.length; index++){
			var Room = new Object();
			Room.name = rooms_li.getItemAt(index).name;
			newRooms.push(Room);
		}
		var newPanels = new Array();
		for(var index = 0; index < panels_li.length; index++){
			var Panel = new Object();
			Panel.name = panels_li.getItemAt(index).name;
			newPanels.push(Panel);
		}		
		if(cycle_chk.selected){
			cycle = "true";
		}
		else{
			cycle = "false";
		}
		if(hideFromList_chk.selected){
			hideFromList = "true";
		}
		else{
			hideFromList = "false";
		}
		_global.left_tree.selectedNode.object.setData(new Object({panels:newPanels,rooms:newRooms,name:name_ti.text,map:map_ti.text,background:background_ti.text,cycle:cycle,alignment:alignment_ti.text,hideFromList:hideFromList}));
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
