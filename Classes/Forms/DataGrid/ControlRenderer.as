import mx.core.UIComponent;
import mx.utils.Delegate;
class Forms.DataGrid.ControlRenderer extends UIComponent {
	var label:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function ControlRenderer() {
	}
	function createChildren(Void):Void {
		label = createObject("Label", "Label", 1, {styleName:this, owner:this});
		label.editable = false;
		size();
	}
	function size(Void):Void {
		label.setSize(__width, __height);
		label._x = 2;
		label._y = 2;
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
		var itemLocation = getCellIndex();
		var columnName = listOwner.columnNames[itemLocation.columnIndex];
		var itemObject = listOwner.dataProvider[itemLocation.itemIndex][columnName];
		label._visible = false;
		if (item != undefined) {
			if(itemObject.label.length){
				label.text = itemObject.label;
				label._visible = true;
				if (itemObject.sel){
					label.setStyle("fontWeight", "bold");
					label.setStyle("color", "0x000000");
					label.setStyle("textDecoration", "underline");
				}else {
					label.setStyle("fontWeight", "none");
					label.setStyle("color", "0x444444");
					label.setStyle("textDecoration", "none");
				}
			}
		}
	}
	function getPreferredHeight(Void):Number {
		return 25;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
}
