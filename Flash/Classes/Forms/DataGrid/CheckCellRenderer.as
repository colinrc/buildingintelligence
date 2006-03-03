import mx.core.UIComponent;
import mx.controls.CheckBox;
class Forms.DataGrid.CheckCellRenderer extends UIComponent {
	var check:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function CheckCellRenderer() {
	}
	function createChildren(Void):Void {
		check = createObject("CheckBox", "check", 1, {styleName:this, owner:this});
		check.addEventListener("click", this);
		size();
	}
	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height
	function size(Void):Void {
		check.setSize(20, __height);
		check._x = (__width-20)/2+2;
		check._y = (__height-16)/2+2;
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		var itemObject = listOwner.dataProvider[itemLocation.itemIndex][columnName];
		check._visible = (item != undefined);		
		check.values = itemObject.values;
		if(itemObject.label == check.values.True){
			check.selected = true;
		} else{
			check.selected = false;
		}
	}
	function getPreferredHeight(Void):Number {
		return 16;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
	function click() {
		var Value;
		if(check.selected){
			Value = check.values.True;
		} else{
			Value = check.values.False;
		}
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		listOwner.dataProvider[itemLocation.itemIndex][columnName].label = Value;
	}
}
