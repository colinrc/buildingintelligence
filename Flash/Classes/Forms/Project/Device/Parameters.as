import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Parameters extends Forms.BaseForm {
	private var parameters:Array;
	private var device_type;
	private var params_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;	
	public function onLoad() {
		var DP = new Array();
		for(var child in _global.parameters_xml.childNodes){
			if(_global.parameters_xml.childNodes[child].attributes["TYPE"] == device_type){
				for(var index in _global.parameters_xml.childNodes[child].childNodes){
					DP.push({label:_global.parameters_xml.childNodes[child].childNodes[index].attributes["name"],data:_global.parameters_xml.childNodes[child].childNodes[index].attributes["default"]});
				}
				break;
			}
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(params_dg);
		dataGridHandler.addParameterComboBoxColumn("name", "Name", DP,150);
		dataGridHandler.addTextInputColumn("value", "Value", restrictions,250);
		var DP = new Array();				
		for (var parameter in parameters) {
			var newParam = new Object();
			newParam.name = "";
			newParam.value = "";
			if (parameters[parameter].attributes["NAME"] != undefined) {
				newParam.name = parameters[parameter].attributes["NAME"];
			}
			if (parameters[parameter].attributes["VALUE"] != undefined) {
				newParam.value = parameters[parameter].attributes["VALUE"];
			}
			DP.push(newParam);
		}
		dataGridHandler.setDataGridDataProvider(DP);		
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function getData():Object {
		var newParameters = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "ITEM");
			if (DP[index].name != "") {
				item.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].value != "") {
				item.attributes["VALUE"] = DP[index].value;
			}
			newParameters.push(item);
		}
		return newParameters;
	}
}