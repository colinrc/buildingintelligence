import mx.core.UIComponent;
import mx.controls.ComboBox;
class Forms.DataGrid.ComboBoxCellRenderer extends UIComponent {
	var combo:MovieClip;
	var label:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function ComboBoxCellRenderer() {
	}
	function createChildren(Void):Void {
		//Creates a ComboBox object and listen to changes
		combo = createObject("ComboBox", "Combo"+random(999)+"Box", 2, {styleName:this, owner:this});
		combo._x = 0;
		combo._y = -5;
		combo.addEventListener("change", this);
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
		combo.setSize(w-2, Math.max(h, listOwner.rowHeight-2));
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		var itemObject = listOwner.dataProvider[itemLocation.itemIndex][columnName];
		if (itemObject.sel) {
			label._visible = false;
			combo._visible = (item != undefined);
			combo.dataProvider = itemObject.DP;
			for (var index in combo.dataProvider) {
				if (itemObject.label == combo.dataProvider[index].label) {
					combo.selectedIndex = index;
				}
			}
		} else {
			combo._visible = false;
			label._visible = (item != undefined);
			label.text = itemObject.label;
		}
	}
	function getPreferredHeight(Void):Number {
		return 16;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
	function change() {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		listOwner.dataProvider[itemLocation.itemIndex][columnName].label = combo.selectedItem.label;
	}
}
