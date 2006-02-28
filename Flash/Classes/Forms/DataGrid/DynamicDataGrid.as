import mx.controls.*;
import mx.utils.Delegate;
class Forms.DataGrid.DynamicDataGrid {
	private var my_dg:DataGrid;
	private var columns:Object;
	private var buttonColumns:Object;
	private var lastClick:Object;
	public function DynamicDataGrid() {
		columns = new Object();
		buttonColumns = new Object();
		lastClick = undefined;
	}
	public function setAdvanced(advanced:Boolean) {
		if (advanced) {
			for (var name in columns) {
				if (columns[name].advanced) {
					my_dg.addColumnAt(columns[name].colNo, name);
					my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = columns[name].heading;
					my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
					switch (columns[name].type) {
					case "text" :
						my_dg.getColumnAt(columns[name].colNo-1).width = 100;
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "TextInputCellRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
						break;
					case "check" :
						my_dg.getColumnAt(columns[name].colNo-1).width = 100;					
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "CheckCellRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
						break;
					case "combo" :
						my_dg.getColumnAt(columns[name].colNo-1).width = 100;					
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ComboBoxCellRenderer";
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
						break;
					case "colour" :
						my_dg.getColumnAt(columns[name].colNo-1).width = 100;					
						my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ColourCellRenderer";
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
	}
	public function addTextInputColumn(name:String, heading:String, restrictions:Object, advanced:Boolean) {
		columns[name] = new Object();
		columns[name].type = "text";
		columns[name].restrictions = restrictions;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = my_dg.columnCount;
		if (!advanced) {
			my_dg.addColumn(name);
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "TextInputCellRenderer";
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		}
	}
	public function addValueInputColumn(name:String, heading:String, restrictions:Object, rawInterFaceForm:MovieClip) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ValueInputCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		columns[name] = new Object();
		columns[name].type = "value";
		columns[name].restrictions = restrictions;
		columns[name].rawInterFaceForm = rawInterFaceForm;
		columns[name].advanced = false;
	}
	public function addActiveColumn(name:String, values:Object) {
		columns[name] = new Object();
		columns[name].type = "active";
		columns[name].values = values;
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerRenderer = "ActiveHeaderRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "CheckCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 20;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
	}
	public function addCheckColumn(name:String, heading:String, values:Object, advanced:Boolean) {
		columns[name] = new Object();
		columns[name].type = "check";
		columns[name].values = values;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = my_dg.columnCount;
		if (!advanced) {
			my_dg.addColumn(name);
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "CheckCellRenderer";
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		}
	}
	public function addComboBoxColumn(name:String, heading:String, DP:Array, advanced:Boolean) {
		columns[name] = new Object();
		columns[name].type = "combo";
		columns[name].DP = DP;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = my_dg.columnCount;
		if (!advanced) {
			my_dg.addColumn(name);
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ComboBoxCellRenderer";
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		}
	}
	public function addCodeComboBoxColumn(name:String, heading:String, rawInterFaceForm:MovieClip) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "CodeComboBoxCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		columns[name] = new Object();
		columns[name].type = "codecombo";
		columns[name].rawInterFaceForm = rawInterFaceForm;
		columns[name].advanced = false;
	}
	public function addCatalogueComboBoxColumn(name:String, heading:String, DP:Array, rawInterFaceForm:MovieClip) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "CatalogueComboBoxCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		columns[name] = new Object();
		columns[name].type = "cataloguecombo";
		columns[name].DP = DP;
		columns[name].rawInterFaceForm = rawInterFaceForm;
		columns[name].advanced = false;
	}
	public function addColourColumn(name:String, heading:String, advanced:Boolean) {
		columns[name] = new Object();
		columns[name].type = "colour";
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = my_dg.columnCount;
		if (!advanced) {
			my_dg.addColumn(name);
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ColourCellRenderer";
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		}
	}
	public function addButtonColumn(name:String, heading:String, attributes:Object, callBack:Function, advanced:Boolean) {
		buttonColumns[name] = new Object();
		buttonColumns[name].attributes = attributes;
		buttonColumns[name].callBack = callBack;
		columns[name].heading = heading;
		columns[name].advanced = advanced;
		columns[name].colNo = my_dg.columnCount;
		if (!advanced) {
			my_dg.addColumn(name);
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ButtonCellRenderer";
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
			my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		}
	}
	public function addHiddenColumn(name:String) {
		columns[name] = new Object();
		columns[name].type = "hidden";
	}
	public function setDataGridDataProvider(new_dp:Array) {
		var processed_dp = new Array();
		for (var row in new_dp) {
			var newRow = new Object();
			for (var column in new_dp[row]) {
				switch (columns[column].type) {
				case "text" :
					var newText = {label:new_dp[row][column], sel:false, restrictions:columns[column].restrictions};
					newText.toString = function():String  {
						return this.label;
					};
					newRow[column] = newText;
					break;
				case "value" :
					var newText = {label:new_dp[row][column], sel:false, restrictions:columns[column].restrictions, form:columns[column].rawInterFaceForm};
					newText.toString = function():String  {
						return this.label;
					};
					newRow[column] = newText;
					break;
				case "active":
				case "check" :
					var newCheck = {label:new_dp[row][column], values:columns[column].values};
					newCheck.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCheck;
					break;
				case "combo" :
					var newCombo = {label:new_dp[row][column], sel:false, DP:columns[column].DP};
					newCombo.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCombo;
					break;
				case "cataloguecombo" :
					var newCombo = {label:new_dp[row][column], sel:false, DP:columns[column].DP, form:columns[column].rawInterFaceForm};
					newCombo.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCombo;
					break;
				case "colour" :
					var newColour = {colour:new_dp[row][column], sel:false};
					newColour.toString = function():String  {
						return this.colour;
					};
					newRow[column] = newColour;
					break;
				case "codecombo" :
					var newCombo = {label:new_dp[row][column].label, sel:false, DP:new_dp[row][column].DP, form:columns[column].rawInterFaceForm};
					newCombo.toString = function():String  {
						return this.label;
					};
					newRow[column] = newCombo;
					break;
				case "hidden" :
					newRow[column] = new_dp[row][column];
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
	public function getDataGridDataProvider():Array {
		var processed_dp = new Array();
		for (var row in my_dg.dataProvider) {
			var newRow = new Object();
			for (var column in columns) {
				switch (columns[column].type) {
				case "active" :
				case "value" :
				case "text" :
				case "check" :
				case "combo" :
				case "cataloguecombo" :
					newRow[column] = my_dg.dataProvider[row][column].label;
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
				var newCheck = {label:columns[column].values.False, values:columns[column].values};
				newCheck.toString = function():String  {
					return this.label;
				};
				newRow[column] = newCheck;
				break;
			case "codecombo" :
				var newCombo = {label:codeDP[0].label, sel:false, DP:codeDP, form:columns[column].rawInterFaceForm};
				newCombo.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newCombo.sel = true;
				}
				newRow[column] = newCombo;
				break;
			case "combo" :
				var newCombo = {label:columns[column].DP[0].label, sel:false, DP:columns[column].DP, form:columns[column].rawInterFaceForm};
				newCombo.toString = function():String  {
					return this.label;
				};
				if (my_dg.getColumnIndex(column) == 0) {
					newCombo.sel = true;
				}
				newRow[column] = newCombo;
				break;
			case "cataloguecombo" :
				var newCombo = {label:columns[column].DP[0].label, sel:false, DP:columns[column].DP};
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
				newRow[column] = new Object();
				break;
			}
		}
		for (var column in buttonColumns) {
			var newButton = new Object();
			newButton.attributes = buttonColumns[column].attributes;
			newButton.callBack = buttonColumns[column].callBack;
			newRow[column] = newButton;
		}
		my_dg.dataProvider.addItemAt(0, newRow);
		my_dg.dataProvider.updateViews("change");
		my_dg.vPosition = 0;
		my_dg.selectedIndex = 0;
		lastClick.itemIndex = my_dg.selectedIndex;
	}
	public function removeRow() {
		my_dg.dataProvider.removeItemAt(my_dg.selectedIndex);
		my_dg.selectedIndex = undefined;
		lastClick = undefined;
		my_dg.dataProvider.updateViews("change");
	}
	public function clearEdit() {
		for (var item in my_dg.dataProvider) {
			for (var column in my_dg.dataProvider[item]) {
				switch (columns[column].type) {
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
		if ((event.itemIndex < my_dg.dataProvider.length) && (event.columnIndex < my_dg.columnNames.length)) {
			clearEdit();
			if (lastClick.itemIndex == event.itemIndex) {
				switch (columns[my_dg.columnNames[event.columnIndex]].type) {
				case "combo" :
				case "text" :
				case "value" :
				case "colour" :
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
