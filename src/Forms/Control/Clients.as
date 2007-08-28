import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.Clients extends Forms.BaseForm {
	private var clients:Array;
	private var clients_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;	
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var restrictions2 = new Object();
		restrictions2.maxChars = 15;
		restrictions2.restrict = "0-9.";		
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(clients_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions,false,150);
		dataGridHandler.addTextInputColumn("ipAddress", "IP Address", restrictions2,false,150);
		dataGridHandler.addHiddenColumn("id");				
		var DP = new Array();
		for (var client in clients) {
			var newClient = new Object();
			newClient.name = clients[client].description;
			newClient.ipAddress = clients[client].ipAddress;			
			newClient.id = clients[client].id;			
			DP.push(newClient);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function setAdvanced(){
		dataGridHandler.setAdvanced();
	}	
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		dataGridHandler.clearSelection();
		var newClients = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var newClient = new Object();
			newClient.description = DP[index].name;
			newClient.ipAddress = DP[index].ipAddress;			
			newClient.id = DP[index].id;			
			newClients.push(newClient);
		}
		dataObject.setData({clients:newClients});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
