import mx.controls.*;
import mx.controls.gridclasses.DataGridColumn;
import mx.utils.Delegate;
class Forms.DataGrid.DynamicDataGrid {
	private var my_dg:DataGrid;
	private var columns:Object;
	private var buttonColumns:Object;
	private var lastClick:Object;
	private var tempDP:Array;
	private var columnCount;
	public function DynamicDataGrid() {
		columns = new Object();
		buttonColumns = new Object();
		lastClick = undefined;
		columnCount = 0;
	}
	public function setAdvanced() {
		var advanced = _global.advanced;
		if (advanced) {
			for (var name in columns) {
				if (columns[name].advanced) {
					my_dg.addColumnAt(columns[name].colNo, name);
					my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = columns[name].heading;
					my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
					switch (columns[name].type) {
					case "text" :
						my_dg.getColumnAt(columns[name].colNo - 1).width = 100;
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "TextInputCellRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerRenderer = "MultiLineHeaderRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
						break;
					case "check" :
						my_dg.getColumnAt(columns[name].colNo - 1).width = 100;
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "CheckCellRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerRenderer = "MultiLineHeaderRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
						break;
					case "combo" :
						my_dg.getColumnAt(columns[name].colNo - 1).width = 100;
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ComboBoxCellRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerRenderer = "MultiLineHeaderRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
						break;
					case "colour" :
						my_dg.getColumnAt(columns[name].colNo - 1).width = 100;
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ColourCellRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerRenderer = "MultiLineHeaderRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
						break;
					}
				}
			}
		} else {
			for (var name in columns) {
				if (columns[name].advanced) {
					my_dg.removeColumnAt(my_dg.getColumnIndex(name));
				}
			}
		}
		my_dg.dataProvider.updateViews("change");
	}
	public function setDataGrid(new_dg:DataGrid) {
		my_dg = new_dg;
		my_dg.editable = false;
		my_dg.addEventListener("cellPress", Delegate.create(this, clickProcessor));
		my_dg.vScrollPolicy = "auto";
		my_dg.hScrollPolicy = "auto";
		my_dg.headerHeight = 35;
		my_dg.rowHeight = 22;
	}
	public function addTextInputColumn(name:String, heading:String, restrictions:Object, advanced:Boolean, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "text";
		columns[name].restrictions = restrictions;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = columnCount - 1;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "TextInputCellRenderer";
		columns[name].column.sortable = false;
	}
	public function addValueInputColumn(name:String, heading:String, restrictions:Object, rawInterFaceForm:MovieClip, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "value";
		columns[name].restrictions = restrictions;
		columns[name].rawInterFaceForm = rawInterFaceForm;
		columns[name].advanced = false;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "ValueInputCellRenderer";
		columns[name].column.sortable = false;
	}
	public function addActiveColumn(name:String, values:Object) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "active";
		columns[name].values = values;
		columns[name].column = new DataGridColumn(name);
		columns[name].width = 20;
		columns[name].column.headerRenderer = "ActiveHeaderRenderer";
		columns[name].column.cellRenderer = "CheckCellRenderer";
		columns[name].column.resizable = false;
		columns[name].column.sortable = false;
	}
	public function addCheckColumn(name:String, heading:String, values:Object, advanced:Boolean, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "check";
		columns[name].values = values;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = columnCount - 1;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "CheckCellRenderer";
		columns[name].column.sortable = false;
	}
	public function addParameterComboBoxColumn(name:String, heading:String, DP:Array, advanced:Boolean, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "paramcombo";
		columns[name].DP = DP;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = columnCount - 1;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "ParameterComboBoxCellRenderer";
		columns[name].column.sortable = false;
	}
	public function addComboBoxColumn(name:String, heading:String, DP:Array, advanced:Boolean, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "combo";
		columns[name].DP = DP;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = columnCount - 1;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "ComboBoxCellRenderer";
		columns[name].column.sortable = false;
	}
	public function addCodeComboBoxColumn(name:String, heading:String, rawInterFaceForm:MovieClip, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "codecombo";
		columns[name].rawInterFaceForm = rawInterFaceForm;
		columns[name].advanced = false;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "CodeComboBoxCellRenderer";
		columns[name].column.sortable = false;
	}
	public function addCatalogueComboBoxColumn(name:String, heading:String, DP:Array, rawInterFaceForm:MovieClip, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "cataloguecombo";
		columns[name].DP = DP;
		columns[name].rawInterFaceForm = rawInterFaceForm;
		columns[name].advanced = false;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "CatalogueComboBoxCellRenderer";
		columns[name].column.sortable = false;
	}
	public function addColourColumn(name:String, heading:String, advanced:Boolean, width:Number) {
		columnCount++;
		columns[name] = new Object();
		columns[name].type = "colour";
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = columnCount - 1;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "ColourCellRenderer";
		columns[name].column.sortable = false;
		//}
	}
	public function addButtonColumn(name:String, heading:String, attributes:Object, callBack:Function, advanced:Boolean, width:Number) {
		columnCount++;
		buttonColumns[name] = new Object();
		buttonColumns[name].attributes = attributes;
		buttonColumns[name].callBack = callBack;
		columns[name] = new Object();		
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = columnCount - 1;
		columns[name].width = width;
		columns[name].column = new DataGridColumn(name);		
		columns[name].column.headerText = heading;
		columns[name].column.headerRenderer = "MultiLineHeaderRenderer";
		columns[name].column.cellRenderer = "ButtonCellRenderer";
		columns[name].column.width = width;
		columns[name].column.sortable = false;
	}
	public function addHiddenColumn(name:String) {
		columns[name] = new Object();
		columns[name].type = "hidden";
	}
	private function buildDG() {
		var processed_dp = new Array();
		for (var row = 0; row < tempDP.length; row++) {
			var newRow = new Object();
			for (var column in tempDP[row]) {
				switch (columns[column].type) {
				case "text" :
					var newText = {label:tempDP[row][column], sel:false, restrictions:columns[column].restrictions};
					newText.toString = function():String  {
						return this.label;
					};
					newRow[column] = newText;
					break;
				case "value" :
					var newText = {label:tempDP[row][column], sel:false, restrictions:columns[column].restrictions, form:columns[column].rawInterFaceForm};
					newText.toString = function():String  {
						return this.label;
					};
					newRow[column] = newText;
					break;
				case "active" :
				case "check" :
					var newCheck = {label:tempDP[row][column], values:columns[column].values};
					newCheck.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCheck;
					break;
				case "paramcombo" :
				case "combo" :
					var newCombo = {label:tempDP[row][column], sel:false, DP:columns[column].DP};
					newCombo.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCombo;
					break;
				case "cataloguecombo" :
					var newCombo = {label:tempDP[row][column], sel:false, DP:columns[column].DP, form:columns[column].rawInterFaceForm};
					newCombo.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCombo;
					break;
				case "colour" :
					var newColour = {colour:tempDP[row][column], sel:false};
					newColour.toString = function():String  {
						return this.colour;
					};
					newRow[column] = newColour;
					break;
				case "codecombo" :
					var newCombo = {label:tempDP[row][column].label, sel:false, DP:tempDP[row][column].DP, form:columns[column].rawInterFaceForm};
					newCombo.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCombo;
					break;
				case "hidden" :
					newRow[column] = tempDP[row][column];
					break;
				}
			}
			for (var column in buttonColumns) {
				var newButton = new Object();
				newButton.attributes = buttonColumns[column].attributes;
				newButton.callBack = buttonColumns[column].callBack;
				newRow[column] = newButton;
			}
			processed_dp.push(newRow);
		}
		my_dg.dataProvider = processed_dp;
	}
	public function setDataGridDataProvider(new_dp:Array) {
		/*Reverse properties of columns object*/
		var newColumns = new Object();
		for(var name in columns){
			newColumns[name] = columns[name];
		}
		columns = newColumns;
		for (var name in columns) {
			if (columns[name].column != undefined) {
				if (((_global.advanced) && (columns[name].advanced)) || (!columns[name].advanced)) {
					my_dg.addColumn(columns[name].column);
					my_dg.getColumnAt(my_dg.columnCount-1).width = columns[name].width;
				}
			}
		}
		my_dg.dataProvider.updateViews("change");
		tempDP = new_dp;
		my_dg.doLater(this, "buildDG");
	}
	public function getDataGridDataProvider():Array {
		clearSelection();
		var processed_dp = new Array();
		for (var row = 0; row < my_dg.dataProvider.length; row++) {
			var newRow = new Object();
			for (var column in columns) {
				switch (columns[column].type) {
				case "active" :
				case "value" :
				case "text" :
				case "check" :
					newRow[column] = my_dg.dataProvider[row][column].label;
					break;
				case "paramcombo" :
				case "combo" :
				case "cataloguecombo" :
					if (my_dg.dataProvider[row][column].label != "") {
						newRow[column] = my_dg.dataProvider[row][column].label;
					} else {
						newRow[column] = undefined;
					}
					break;
				case "codecombo" :
					newRow[column] = new Object();
					newRow[column].label = my_dg.dataProvider[row][column].label;
					break;
				case "colour" :
					newRow[column] = my_dg.dataProvider[row][column].colour;
					break;
				case "hidden" :
					newRow[column] = my_dg.dataProvider[row][column];
					break;
				}
			}
			processed_dp.push(newRow);
		}
		my_dg.dataProvider.updateViews("change");
		return processed_dp;
	}
	public function addBlankRow(codeDP:Array) {
		clearEdit();
		/** jump to bottom of data grid*/
		var newRow = new Object();
		for (var column in columns) {
			switch (columns[column].type) {
			case "text" :
				var newText = {label:"", sel:false, restrictions:columns[column].restrictions};
				newText.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newText.sel = true;
				}
				newRow[column] = newText;
				break;
			case "value" :
				var newText = {label:"", sel:false, restrictions:columns[column].restrictions, form:columns[column].rawInterFaceForm};
				newText.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newText.sel = true;
				}
				newRow[column] = newText;
				break;
			case "active" :
			case "check" :
				var newCheck = {label:columns[column].values.True, values:columns[column].values};
				newCheck.toString = function():String  {
					return this.label;
				};
				newRow[column] = newCheck;
				break;
			case "codecombo" :
				if (codeDP[0].label != undefined) {
					var label = codeDP[0].label;
				} else {
					var label = "";
				}
				var newCombo = {label:label, sel:false, DP:codeDP, form:columns[column].rawInterFaceForm};
				newCombo.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newCombo.sel = true;
				}
				var blankVars = new Array();
				var splitString = codeDP[0].data.split("%");
				var isEven = false;
				for (var subString in splitString) {
					if (isEven) {
						if ((splitString[subString] != "COMMAND") && (splitString[subString] != "EXTRA") && (splitString[subString] != "EXTRA2") && (splitString[subString] != "EXTRA3") && (splitString[subString] != "EXTRA4") && (splitString[subString] != "EXTRA5")) {
							var newVar = new XMLNode(1, "VARS");
							newVar.attributes.NAME = splitString[subString];
							newVar.attributes.VALUE = "";
							blankVars.push(newVar);
						}
						isEven = false;
					} else {
						isEven = true;
					}
				}
				newRow.vars = new Array();
				for (var variable in blankVars) {
					newRow.vars.push(blankVars[variable]);
				}
				newRow[column] = newCombo;
				break;
			case "paramcombo" :
				if (columns[column].DP[0].label != undefined) {
					var label = columns[column].DP[0].label;
				} else {
					var label = "";
				}
				var newCombo = {label:label, sel:false, DP:columns[column].DP};
				newCombo.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newCombo.sel = true;
				}
				newRow[column] = newCombo;
				newRow["value"].label = columns[column].DP[0].data;
				break;
			case "combo" :
				if (columns[column].DP[0].label != undefined) {
					var label = columns[column].DP[0].label;
				} else {
					var label = "";
				}
				var newCombo = {label:label, sel:false, DP:columns[column].DP};
				newCombo.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newCombo.sel = true;
				}
				newRow[column] = newCombo;
				break;
			case "cataloguecombo" :
				if (columns[column].DP[0].label != undefined) {
					var label = columns[column].DP[0].label;
				} else {
					var label = "";
				}
				var newCombo = {label:label, sel:false, DP:columns[column].DP};
				newCombo.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newCombo.sel = true;
				}
				newRow[column] = newCombo;
				break;
			case "colour" :
				var newColour = {colour:"0xFFFFFF", sel:false};
				newColour.toString = function():String  {
					return this.colour;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newColour.sel = true;
				}
				newRow[column] = newColour;
				break;
			case "hidden" :
				//newRow[column] = new Object();
				break;
			}
		}
		for (var column in buttonColumns) {
			var newButton = new Object();
			newButton.attributes = buttonColumns[column].attributes;
			newButton.callBack = buttonColumns[column].callBack;
			newRow[column] = newButton;
		}
		my_dg.dataProvider.addItemAt(my_dg.dataProvider.length, newRow);
		//my_dg.dataProvider.addItemAt(0, newRow);
		my_dg.dataProvider.updateViews("change");
		my_dg.vPosition = my_dg.maxVPosition;
		my_dg.selectedIndex = my_dg.dataProvider.length - 1;
		lastClick.itemIndex = my_dg.selectedIndex;
		_global.unSaved = true;
		my_dg.vPosition = my_dg.maxVPosition;
	}
	public function removeRow() {
		my_dg.dataProvider.removeItemAt(my_dg.selectedIndex);
		my_dg.selectedIndex = undefined;
		lastClick = undefined;
		my_dg.dataProvider.updateViews("change");
		_global.unSaved = true;
	}
	public function clearEdit() {
		for (var item in my_dg.dataProvider) {
			for (var column in my_dg.dataProvider[item]) {
				switch (columns[column].type) {
				case "paramcombo" :
				case "combo" :
				case "codecombo" :
				case "text" :
				case "value" :
				case "colour" :
				case "cataloguecombo" :
					my_dg.dataProvider[item][column].sel = false;
					break;
				}
			}
		}
	}
	public function clearSelection() {
		my_dg.selectedIndex = undefined;
		lastClick = undefined;
		clearEdit();
	}
	function clickProcessor(event) {
		clearEdit();
		if ((event.itemIndex < my_dg.dataProvider.length) && (event.columnIndex < my_dg.columnNames.length)) {
			if (lastClick.itemIndex == event.itemIndex) {
				switch (columns[my_dg.columnNames[event.columnIndex]].type) {
				case "combo" :
				case "text" :
				case "value" :
				case "colour" :
				case "paramcombo" :
				case "codecombo" :
				case "cataloguecombo" :
					my_dg.dataProvider[event.itemIndex][my_dg.columnNames[event.columnIndex]].sel = true;
					break;
				}
			}
		}
		my_dg.dataProvider.updateViews("change");
		lastClick = event;
	}
}
