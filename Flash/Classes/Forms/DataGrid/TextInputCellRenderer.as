﻿import mx.core.UIComponent;
//import mx.controls.TextInput;
class Forms.DataGrid.TextInputCellRenderer extends UIComponent {
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
		label = createObject("Label", "Label", 1, {styleName:this, owner:this});
		size();
	}
	function size(Void):Void {
		if (label._name == "Label") {
			label.setSize(__width, __height);
			label._x = 2;
			label._y = 2;
		} else if (label._name == "TextInput") {
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
			if (label._name != "TextInput") {
				label = createObject("TextInput", "TextInput", 1, {styleName:this, owner:this});
				label.addEventListener("change", this);
				label._visible = (item != undefined);
				for (var restriction in itemObject.restrictions) {
					label[restriction] = itemObject.restrictions[restriction];
				}
				label.text = itemObject.label;
				label.setFocus();
				size();
			}
		} else {
			if (label._name != "Label") {
				label = createObject("Label", "Label", 1, {styleName:this, owner:this});
				size();
			}
			label._visible = (item != undefined);
			label.text = itemObject.label;
		}
	}
	function getPreferredHeight(Void):Number {
		return 25;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
	function change() {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		listOwner.dataProvider[itemLocation.itemIndex][columnName].label = label.text;
	}
}
