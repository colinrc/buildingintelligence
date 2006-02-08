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
	public function setDataGrid(new_dg:DataGrid) {
		my_dg = new_dg;
		my_dg.editable = false;
		my_dg.addEventListener("cellPress", Delegate.create(this, clickProcessor));
		my_dg.vScrollPolicy = "auto";		
		my_dg.hScrollPolicy = "auto";
	}
	public function addTextInputColumn(name:String, heading:String, restrictions:Object) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "TextInputCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;
		columns[name] = new Object();
		columns[name].type = "text";
		columns[name].restrictions = restrictions;
	}
	public function addCheckColumn(name:String, heading:String, values:Object) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "CheckCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 50;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;		
		columns[name] = new Object();
		columns[name].type = "check";
		columns[name].values = values;
	}
	public function addComboBoxColumn(name:String, heading:String, DP:Array) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ComboBoxCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;		
		columns[name] = new Object();
		columns[name].type = "combo";
		columns[name].DP = DP;
	}
	public function addColourColumn(name:String, heading:String) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ColourCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;		
		columns[name] = new Object();
		columns[name].type = "colour";
	}
	public function addButtonColumn(name:String, heading:String, attributes:Object, callBack:Function) {
		my_dg.addColumn(name);
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).headerText = heading;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).cellRenderer = "ButtonCellRenderer";
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).width = 100;
		my_dg.getColumnAt(my_dg.getColumnIndex(name)).sortable = false;		
		buttonColumns[name] = new Object();
		buttonColumns[name].attributes = attributes;
		buttonColumns[name].callBack = callBack;
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
				case "colour" :
					var newColour = {colour:new_dp[row][column], sel:false};
					newColour.toString = function():String  {
						return this.colour;
					};
					newRow[column] = newColour;
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
				case "text" :
				case "check" :
				case "combo" :
					newRow[column] = my_dg.dataProvider[row][column].label;
					break;
				case "colour" :
					newRow[column] = my_dg.dataProvider[row][column].colour;
					break;
				}
			}
			processed_dp.push(newRow);
		}
		my_dg.dataProvider.updateViews("change");
		return processed_dp;
	}
	public function addBlankRow() {
		/** jump to bottom of data grid*/
		var newRow = new Object();
		for (var column in columns) {
			switch (columns[column].type) {
			case "text" :
				var newText = {label:"", sel:false, restrictions:columns[column].restrictions};
				newText.toString = function():String  {
					return this.label;
				};
				newRow[column] = newText;
				break;
			case "check" :
				var newCheck = {label:columns[column].values.False, values:columns[column].values};
				newCheck.toString = function():String  {
					return this.label;
				};
				newRow[column] = newCheck;
				break;
			case "combo" :
				var newCombo = {label:columns[column].DP[0].label, sel:false, DP:columns[column].DP};
				newCombo.toString = function():String  {
					return this.label;
				};
				newRow[column] = newCombo;
				break;
			case "colour" :
				var newColour = {colour:"0xFFFFFF", sel:false};
				newColour.toString = function():String  {
					return this.colour;
				};
				newRow[column] = newColour;
				break;
			}
		}
		for (var column in buttonColumns) {
			var newButton = new Object();
			newButton.attributes = buttonColumns[column].attributes;
			newButton.callBack = buttonColumns[column].callBack;
			newRow[column] = newButton;
		}
		my_dg.dataProvider.addItemAt(0,newRow);
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
	function clickProcessor(event) {
		if ((event.itemIndex<my_dg.dataProvider.length) && (event.columnIndex<my_dg.columnNames.length)) {
			for (var item in my_dg.dataProvider) {
				for (var column in my_dg.dataProvider[item]) {
					switch (columns[column].type) {
					case "combo" :
					case "text" :
					case "colour" :
						my_dg.dataProvider[item][column].sel = false;
						break;
					}
				}
			}
			if (lastClick.itemIndex == event.itemIndex){
				switch (columns[my_dg.columnNames[event.columnIndex]].type) {
				case "combo" :
				case "text" :
				case "colour" :
					my_dg.dataProvider[event.itemIndex][my_dg.columnNames[event.columnIndex]].sel = true;
					break;
				}
			}		
		}
		my_dg.dataProvider.updateViews("change");
		lastClick = event;
	}
}
