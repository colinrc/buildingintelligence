import mx.core.UIComponent;
import mx.controls.ComboBox;
class Forms.DataGrid.ColourCellRenderer extends UIComponent {
	var colour:MovieClip;
	var label:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function ColourCellRenderer() {
	}
	function createChildren(Void):Void {
		//Creates a ComboBox object and listen to changes
		colour = createObject("BHColourPickerHex", "Colour"+random(999)+"Box", 2, {styleName:this, owner:this});
		colour._x = 0;
		colour._y = -5;
		colour.addEventListener("change", this);
		label = createObject("Label", "Label"+random(999)+"Box", 1, {styleName:this, owner:this});
		label._x = 0;
		label._y = -5;
		size();
	}
	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height
	function size(Void):Void {
		var h = __height;
		var w = __width;
		colour.setSize(w-2, Math.max(h, listOwner.rowHeight-2));
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		var itemObject = listOwner.dataProvider[itemLocation.itemIndex][columnName];
		if (itemObject.sel) {
			label._visible = false;
			colour._visible = (item != undefined);
			colour.setCallbackObject(this);
			colour.setColour(itemObject.colour);
		} else {
			colour._visible = false;
			label._visible = (item != undefined);
			label.text = itemObject.colour;
		}
	}
	function getPreferredHeight(Void):Number {
		return 16;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
	function onColourChange(newColour:Number) {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		listOwner.dataProvider[itemLocation.itemIndex][columnName].colour = "0x"+newColour.toString(16).toUpperCase();;
	}
}
