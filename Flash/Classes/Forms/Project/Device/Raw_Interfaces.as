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
	public function init() {
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
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(interfaces_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("display_name", "eLife Name", restrictions);
		dataGridHandler.addCatalogueComboBoxColumn("catalogue", "Catalogue", catalogueDP, this);
		dataGridHandler.addCodeComboBoxColumn("code", "Code", this);
		dataGridHandler.addTextInputColumn("command", "Command", restrictions);
		dataGridHandler.addTextInputColumn("extra", "Extra", restrictions);
		dataGridHandler.addTextInputColumn("extra2", "Extra2", restrictions);
		dataGridHandler.addTextInputColumn("extra3", "Extra3", restrictions);
		dataGridHandler.addTextInputColumn("extra4", "Extra4", restrictions);
		dataGridHandler.addTextInputColumn("extra5", "Extra5", restrictions);
		dataGridHandler.addHiddenColumn("vars");
		dataGridHandler2 = new Forms.DataGrid.DynamicDataGrid();
		var restrictions2 = new Object();
		restrictions2.editable = false;
		dataGridHandler2.setDataGrid(vars_dg);
		dataGridHandler2.addTextInputColumn("name", "Name", restrictions2);
		dataGridHandler2.addValueInputColumn("value", "Value", restrictions, this);
		var DP = new Array();
		for (var raw_interface in raw_interfaces) {
			var newRaw_interface = new Object();
			newRaw_interface.display_name = "";
			newRaw_interface.name = "";
			if (raw_interfaces[raw_interface].attributes.DISPLAY_NAME != undefined) {
				newRaw_interface.display_name = raw_interfaces[raw_interface].attributes.DISPLAY_NAME;
			}
			if (raw_interfaces[raw_interface].attributes.NAME != undefined) {
				newRaw_interface.name = raw_interfaces[raw_interface].attributes.NAME;
			}
			var raw_items = raw_interfaces[raw_interface].childNodes;
			for (var raw_item in raw_items) {
				newRaw_interface.catalogue = "";
				if (raw_items[raw_item].attributes.CATALOGUE != undefined) {
					newRaw_interface.catalogue = raw_items[raw_item].attributes.CATALOGUE;
				}
				var raws = raw_items[raw_item].childNodes;
				for (var raw in raws) {
					newRaw_interface.code = new Object();
					newRaw_interface.command = "";
					newRaw_interface.extra = "";
					newRaw_interface.extra2 = "";
					newRaw_interface.extra3 = "";
					newRaw_interface.extra4 = "";
					newRaw_interface.extra5 = "";
					if (raws[raw].attributes.CODE != undefined) {
						for (var catalogue in catalogueDP) {
							if (newRaw_interface.catalogue == catalogueDP[catalogue].label) {
								for (var code in catalogueDP[catalogue].data) {
									if (raws[raw].attributes.CODE == catalogueDP[catalogue].data[code].label) {
										newRaw_interface.code.label = catalogueDP[catalogue].data[code].label;
										newRaw_interface.code.DP = catalogueDP[catalogue].data;
										break;
									}
								}
								break;
							}
						}
					}
					if (raws[raw].attributes.COMMAND != undefined) {
						newRaw_interface.command = raws[raw].attributes.COMMAND;
					}
					if (raws[raw].attributes.EXTRA != undefined) {
						newRaw_interface.extra = raws[raw].attributes.EXTRA;
					}
					if (raws[raw].attributes.EXTRA2 != undefined) {
						newRaw_interface.extra2 = raws[raw].attributes.EXTRA2;
					}
					if (raws[raw].attributes.EXTRA3 != undefined) {
						newRaw_interface.extra3 = raws[raw].attributes.EXTRA3;
					}
					if (raws[raw].attributes.EXTRA4 != undefined) {
						newRaw_interface.extra4 = raws[raw].attributes.EXTRA4;
					}
					if (raws[raw].attributes.EXTRA5 != undefined) {
						newRaw_interface.extra5 = raws[raw].attributes.EXTRA5;
					}
					if (raws[raw].hasChildNodes()) {
						newRaw_interface.vars = new Array();
						for (var variable in raws[raw].childNodes) {
							newRaw_interface.vars.push(raws[raw].childNodes[variable]);
						}
					}
					var actualInterface = new Object();
					for (var attribute in newRaw_interface) {
						actualInterface[attribute] = newRaw_interface[attribute];
					}
					actualInterface.vars = new Array();
					for (var variable in newRaw_interface.vars) {
						actualInterface.vars.push(newRaw_interface.vars[variable]);
					}
					DP.addItem(actualInterface);
				}
			}
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		interfaces_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow(catalogueDP[0].data);
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
		var newRaw_Interfaces = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		DP.sortOn(["display_name", "name", "catalogue", "code", "command"]);
		for (var index = 0; index<DP.length; index++) {
			var foundInterface = false;
			for (var rawInterface in newRaw_Interfaces) {
				if ((newRaw_Interfaces[rawInterface].attributes.NAME == DP[index].name) && (newRaw_Interfaces[rawInterface].attributes.DISPLAY_NAME == DP[index].display_name)) {
					foundInterface = true;
					var foundItems = false;
					for (var rawItem in newRaw_Interfaces[rawInterface].childNodes) {
						if (newRaw_Interfaces[rawInterface].childNodes[rawItem].attributes.CATALOGUE == DP[index].catalogue) {
							foundItems = true;
							var Raw = new XMLNode(1, "RAW");
							if (DP[index].code.length) {
								Raw.attributes.CODE = DP[index].code;
							}
							if (DP[index].command.length) {
								Raw.attributes.COMMAND = DP[index].command;
							}
							if (DP[index].extra.length) {
								Raw.attributes.EXTRA = DP[index].extra;
							}
							if (DP[index].extra2.length) {
								Raw.attributes.EXTRA2 = DP[index].extra2;
							}
							if (DP[index].extra3.length) {
								Raw.attributes.EXTRA3 = DP[index].extra3;
							}
							if (DP[index].extra4.length) {
								Raw.attributes.EXTRA4 = DP[index].extra4;
							}
							if (DP[index].extra5.length) {
								Raw.attributes.EXTRA5 = DP[index].extra5;
							}
							for (var variable in DP[index].vars) {
								Raw.appendChild(DP[index].vars[variable]);
							}
							newRaw_Interfaces[rawInterface].childNodes[rawItem].appendChild(Raw);
						}
					}
					if (!foundItems) {
						var Raw_Items = new XMLNode(1, "RAW_ITEMS");
						if (DP[index].catalogue.length) {
							Raw_Items.attributes.CATALOGUE = DP[index].catalogue;
						}
						var Raw = new XMLNode(1, "RAW");
						if (DP[index].code.length) {
							Raw.attributes.CODE = DP[index].code;
						}
						if (DP[index].command.length) {
							Raw.attributes.COMMAND = DP[index].command;
						}
						if (DP[index].extra.length) {
							Raw.attributes.EXTRA = DP[index].extra;
						}
						if (DP[index].extra2.length) {
							Raw.attributes.EXTRA2 = DP[index].extra2;
						}
						if (DP[index].extra3.length) {
							Raw.attributes.EXTRA3 = DP[index].extra3;
						}
						if (DP[index].extra4.length) {
							Raw.attributes.EXTRA4 = DP[index].extra4;
						}
						if (DP[index].extra5.length) {
							Raw.attributes.EXTRA5 = DP[index].extra5;
						}
						for (var variable in DP[index].vars) {
							Raw.appendChild(DP[index].vars[variable]);
						}
						Raw_Items.appendChild(Raw);
						newRaw_Interfaces[rawInterface].appendChild(Raw_Items);
					}
				}
			}
			if (!foundInterface) {
				var Raw_Interface = new XMLNode(1, "RAW_INTERFACE");
				if (DP[index].name.length) {
					Raw_Interface.attributes.NAME = DP[index].name;
				}
				if (DP[index].display_name.length) {
					Raw_Interface.attributes.DISPLAY_NAME = DP[index].display_name;
				}
				var Raw_Items = new XMLNode(1, "RAW_ITEMS");
				if (DP[index].catalogue.length) {
					Raw_Items.attributes.CATALOGUE = DP[index].catalogue;
				}
				var Raw = new XMLNode(1, "RAW");
				if (DP[index].code.length) {
					Raw.attributes.CODE = DP[index].code;
				}
				if (DP[index].command.length) {
					Raw.attributes.COMMAND = DP[index].command;
				}
				if (DP[index].extra.length) {
					Raw.attributes.EXTRA = DP[index].extra;
				}
				if (DP[index].extra2.length) {
					Raw.attributes.EXTRA2 = DP[index].extra2;
				}
				if (DP[index].extra3.length) {
					Raw.attributes.EXTRA3 = DP[index].extra3;
				}
				if (DP[index].extra4.length) {
					Raw.attributes.EXTRA4 = DP[index].extra4;
				}
				if (DP[index].extra5.length) {
					Raw.attributes.EXTRA5 = DP[index].extra5;
				}
				for (var variable in DP[index].vars) {
					Raw.appendChild(DP[index].vars[variable]);
				}
				Raw_Items.appendChild(Raw);
				Raw_Interface.appendChild(Raw_Items);
				newRaw_Interfaces.push(Raw_Interface);
			}
		}
		_global.left_tree.selectedNode.object.setData({raw_interfaces:newRaw_Interfaces});
	}
}
