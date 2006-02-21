﻿import mx.core.UIComponent;
import mx.utils.Delegate;
class Forms.DataGrid.ValueInputCellRenderer extends UIComponent {
	var label:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	var rawInterFaceForm:MovieClip;
	function ValueInputCellRenderer() {
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
		if ((itemObject.sel) && (itemObject.restrictions.editable != false)) {
			if (label._name != "TextInput") {
				label = createObject("TextInput", "TextInput", 1, {styleName:this, owner:this});
				label.addEventListener("enter", Delegate.create(this, enterText));
				label._visible = (item != undefined);
				rawInterFaceForm = itemObject.form;
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
	function enterText() {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		listOwner.dataProvider[itemLocation.itemIndex][columnName].label = label.text;
		listOwner.dataProvider.updateViews("change");
		listOwner.dataProvider[itemLocation.itemIndex][columnName].sel = false;
		var valueName = listOwner.dataProvider[itemLocation.itemIndex].name.label;
		var tempVars = rawInterFaceForm.interfaces_dg.dataProvider[rawInterFaceForm.interfaces_dg.selectedIndex].vars;
		for (var child in tempVars) {
			if (tempVars[child].attributes.NAME == valueName) {
				tempVars[child].attributes.VALUE = label.text;
			}
		}
		rawInterFaceForm.itemChange({});
	}
}
