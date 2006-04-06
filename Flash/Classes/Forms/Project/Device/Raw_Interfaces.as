import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Interfaces extends Forms.BaseForm {
	private var raw_interfaces:Array;
	private var cataloguesNode:XMLNode;
	public var interfaces_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var string_lb:Label;
	private var dataGridHandler:Object;
	private var dataGridHandler2:Object;
	private var catalogueDP:Array;
	private var vars_dg:DataGrid;
	private var dataObject:Object;	
	public function onLoad() {
		catalogueDP = new Array();
		for (var catalogue in cataloguesNode.childNodes) {
			var codes = new Array();
			for (var item in cataloguesNode.childNodes[catalogue].childNodes) {
				codes.push({label:cataloguesNode.childNodes[catalogue].childNodes[item].attributes.CODE, data:cataloguesNode.childNodes[catalogue].childNodes[item].attributes.VALUE});
			}
			catalogueDP.push({label:cataloguesNode.childNodes[catalogue].attributes.NAME, data:codes});
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		interfaces_dg.hScrollPolicy = "auto";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(interfaces_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false,150);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false,150);
		dataGridHandler.addCatalogueComboBoxColumn("catalogue", "Catalogue", catalogueDP, this,100);
		dataGridHandler.addCodeComboBoxColumn("code", "Code", this,100);
		dataGridHandler.addTextInputColumn("command", "Command", restrictions, false,100);
		dataGridHandler.addTextInputColumn("extra", "Extra", restrictions, true,100);
		dataGridHandler.addTextInputColumn("extra2", "Extra2", restrictions, true,100);
		dataGridHandler.addTextInputColumn("extra3", "Extra3", restrictions, true,100);
		dataGridHandler.addTextInputColumn("extra4", "Extra4", restrictions, true,100);
		dataGridHandler.addTextInputColumn("extra5", "Extra5", restrictions, true,100);
		dataGridHandler.addHiddenColumn("vars");
		dataGridHandler2 = new Forms.DataGrid.DynamicDataGrid();
		var restrictions2 = new Object();
		restrictions2.editable = false;
		dataGridHandler2.setDataGrid(vars_dg);	
		dataGridHandler2.addTextInputColumn("name", "Name", restrictions2, false,250);
		dataGridHandler2.addValueInputColumn("value", "Value", restrictions, this,250);
		dataGridHandler2.setAdvanced(_global.advanced);		
		for (var raw_interface in raw_interfaces) {
			var found_catalogue = false;
			for (var catalogue in catalogueDP) {
				if (raw_interfaces[raw_interface].catalogue == catalogueDP[catalogue].label) {
					found_catalogue = true;
					var found_code = false;
					for (var code in catalogueDP[catalogue].data) {
						if (raw_interfaces[raw_interface].code.label == catalogueDP[catalogue].data[code].label) {
							found_code = true;
							raw_interfaces[raw_interface].code.DP = catalogueDP[catalogue].data;
							break;
						}
					}
					if (!found_code) {
						raw_interfaces[raw_interface].code.label = catalogueDP[catalogue].data[0].label;
						raw_interfaces[raw_interface].code.DP = catalogueDP[catalogue].data;
					}
					break;
				}
			}
			if (!found_catalogue) {
				raw_interfaces[raw_interface].catalogue = catalogueDP[0].label;
				raw_interfaces[raw_interface].code.label = catalogueDP[0].data[0].label;
				raw_interfaces[raw_interface].code.DP = catalogueDP[0].data;
				raw_interfaces[raw_interface].vars =  catalogueDP[0].data[0].data;
			}
		}
		dataGridHandler.setDataGridDataProvider(raw_interfaces);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		interfaces_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function setAdvanced() {
		dataGridHandler.setAdvanced();
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
		itemChange();
	}
	private function newItem() {
		dataGridHandler.addBlankRow(catalogueDP[0].data);
		itemChange();		
	}
	private function itemChange(evtObj) {
		var tempCatalogue = interfaces_dg.selectedItem.catalogue.label;
		var tempCode = interfaces_dg.selectedItem.code.label;
		var tempString = new String("");
		for (var catalogue in catalogueDP) {
			if (tempCatalogue == catalogueDP[catalogue].label) {
				for (var code in catalogueDP[catalogue].data) {
					if (tempCode == catalogueDP[catalogue].data[code].label) {
						var splitString = catalogueDP[catalogue].data[code].data.split("%");
						var isEven = false;
						for (var subString in splitString) {
							if (isEven) {
								for (var variable in interfaces_dg.selectedItem.vars) {
									if ((splitString[subString] != "COMMAND") && (splitString[subString] != "EXTRA") && (splitString[subString] != "EXTRA2") && (splitString[subString] != "EXTRA3") && (splitString[subString] != "EXTRA4") && (splitString[subString] != "EXTRA5")) {
										if (interfaces_dg.selectedItem.vars[variable].attributes.NAME == splitString[subString]) {
											splitString[subString] = interfaces_dg.selectedItem.vars[variable].attributes.VALUE;
										}
									}
								}
								isEven = false;
							} else {
								isEven = true;
							}
						}
						tempString = splitString.join("%");
						break;
					}
				}
				break;
			}
		}
		var tempDP = new Array();
		for (var variable in interfaces_dg.selectedItem.vars) {
			var newVariable = new Object();
			newVariable.name = interfaces_dg.selectedItem.vars[variable].attributes.NAME;
			newVariable.value = interfaces_dg.selectedItem.vars[variable].attributes.VALUE;
			tempDP.push(newVariable);
		}
		dataGridHandler2.setDataGridDataProvider(tempDP);
		string_lb.text = tempString;
	}
	public function save():Void {
		dataGridHandler.clearSelection();
		itemChange();		
		dataObject.setData({raw_interfaces:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
