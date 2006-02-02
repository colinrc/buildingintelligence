import mx.core.UIComponent;
import mx.controls.TextInput;
class Forms.DataGrid.TextInputCellRenderer extends UIComponent {
	var input:MovieClip;
	var label:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function TextInputCellRenderer() {
	}
	function createChildren(Void):Void {
		input = createObject("TextInput", "TextInput", 2, {styleName:this, owner:this});
		input.addEventListener("change", this);
		label = createObject("Label", "Label", 1, {styleName:this, owner:this});
		label._x = -2;
		size();
	}
	function size(Void):Void {
		input.setSize(150, 22);
		//---set this to whatever the width of the column, and the height of the dataGrid rows.
		input._x = -2;
		input._y = 0;
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		var itemObject = listOwner.dataProvider[itemLocation.itemIndex][columnName];
		if (itemObject.sel) {
			label._visible = false;
			input._visible = (item != undefined);
			input.maxChars = itemObject.restrictions.maxChars;
			input.restrict = itemObject.restrictions.restrict;
			input.text = itemObject.label;
		} else {
			input._visible = false;
			label._visible = (item != undefined);
			label.text = itemObject.label;
		}
	}
	function change() {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		listOwner.dataProvider[itemLocation.itemIndex][columnName].label = input.text;
	}
}
