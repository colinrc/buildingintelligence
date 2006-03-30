import mx.core.UIComponent;
class Forms.DataGrid.ComboBoxCellRenderer extends UIComponent {
	var label:MovieClip;
	var instanceName:String;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function ComboBoxCellRenderer() {
	}
	function createChildren(Void):Void {
		instanceName = "Label";
		label = createObject("Label", "Label"+(_global.formDepth++)+"Box", 1, {styleName:this, owner:this});
		size();
	}
	function size(Void):Void {
		if (instanceName == "Label") {
			label.setSize(__width, __height);
			label._x = 2;
			label._y = 2;
		} else if (instanceName == "ComboBox") {
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
			if (instanceName != "ComboBox") {
				instanceName = "ComboBox";
				label = createObject("ComboBox", "Combo"+(_global.formDepth++)+"Box", 1, {styleName:this, owner:this});
				label.addEventListener("change", this);
				label._visible = (item != undefined);
				label.dataProvider = itemObject.DP;
				for (var index in label.dataProvider) {
					if ((itemObject.label == label.dataProvider[index].label)&&(itemObject.label != undefined)){
						label.selectedIndex = index;
					}
				}
				listOwner.dataProvider[itemLocation.itemIndex][columnName].label = label.selectedItem.label;
				_global.unSaved = true;		
				size();
			}
		} else {
			if (instanceName != "Label") {
				instanceName = "Label";
				label = createObject("Label", "Label"+(_global.formDepth++)+"Box", 1, {styleName:this, owner:this});
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
		listOwner.dataProvider[itemLocation.itemIndex][columnName].label = label.selectedItem.label;
		listOwner.dataProvider[itemLocation.itemIndex][columnName].sel = false;
		_global.unSaved = true;		
	}
}
