import mx.core.UIComponent;
class Forms.DataGrid.ColourCellRenderer extends UIComponent {
	var label:MovieClip;
	var listOwner:MovieClip;
	var instanceName:String;	
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function ColourCellRenderer() {
	}
	function createChildren(Void):Void {
		//Creates a ComboBox object and listen to changes
		instanceName = "Label";
		label = createObject("Label", "Label"+(_global.formDepth++)+"Box", 1, {styleName:this, owner:this});
		size();
	}
	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height
	function size(Void):Void {
		if (instanceName == "Label") {
			label.setSize(__width, __height);
			label._x = 2;
			label._y = 2;
		} else if (instanceName == "Colour") {
			label.setSize(__width-2, listOwner.rowHeight);
			label._x = 0;
			label._y = 0;
		}		
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		var itemObject = listOwner.dataProvider[itemLocation.itemIndex][columnName];
		if (itemObject.sel) {
			if (instanceName != "Colour") {
				instanceName = "Colour";
				label = createObject("BHColourPickerHex", "Colour"+(_global.formDepth++)+"Box", 1, {styleName:this, owner:this});
				label.setCallbackObject(this);
				label._visible = (item != undefined);
				label.setColour(itemObject.colour);
				size();				
			}
		} else {
			if (instanceName != "Label") {
				instanceName = "Label";
				label = createObject("Label", "Label"+(_global.formDepth++)+"Box", 1, {styleName:this, owner:this});
				size();
			}
			label._visible = (item != undefined);
			label.text = itemObject.colour;
		}
	}
	function getPreferredHeight(Void):Number {
		return 25;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
	function onColourChange(newColour:Number) {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		listOwner.dataProvider[itemLocation.itemIndex][columnName].colour = "0x"+newColour.toString(16).toUpperCase();
		listOwner.dataProvider[itemLocation.itemIndex][columnName].sel = false;	
		_global.unSaved = true;		
	}
}
