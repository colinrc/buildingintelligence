import mx.core.UIComponent;
import mx.controls.Button;
class Forms.DataGrid.ButtonCellRenderer extends UIComponent {
	var button:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function ButtonCellRenderer() {
	}
	function createChildren(Void):Void {
		button = createObject("Button", "button", 1, {styleName:this, owner:this});
		button.addEventListener("click", this);
		button._x = 0;
		button._y = 0;
		size();
	}
	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height
	function size(Void):Void {
		button.setSize(__width-2, listOwner.rowHeight-2);
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		var itemObject = listOwner.dataProvider[itemLocation.itemIndex][columnName];
		button._visible = (item != undefined);
		for (var attribute in itemObject.attributes) {
			button[attribute] = itemObject.attributes[attribute];
		}
		button.callBack = itemObject.callBack;
	}
	function getPreferredHeight(Void):Number {
		return 16;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
	function click() {
		button.callBack(getCellIndex());
	}
}
