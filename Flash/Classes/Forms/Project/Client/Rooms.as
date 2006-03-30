import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Rooms extends Forms.BaseForm {
	private var rooms:Array;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var rooms_dg:DataGrid;
	private var add_room_btn:Button;
	private var del_room_btn:Button;
	private var dataObject:Object;	
	public function onLoad() {
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
		del_room_btn.addEventListener("click", Delegate.create(this, deleteRoom));
		add_room_btn.addEventListener("click", Delegate.create(this, addRoom));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteRoom() {
		dataGridHandler.removeRow();
	}
	private function addRoom() {
		dataGridHandler.addBlankRow();
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
		dataObject.setRooms({rooms:newRooms});
		_global.refreshTheTree();				
		_global.saveFile("Project");
	}
}
