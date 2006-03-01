import mx.core.UIComponent;
class Forms.DataGrid.ActiveHeaderRenderer extends UIComponent {
	var bulb:MovieClip;
	var listOwner:MovieClip;
	// the reference we receive to the list
	var getCellIndex:Function;
	// the function we receive from the list
	var getDataLabel:Function;
	// the function we receive from the list
	function CheckCellRenderer() {
	}
	function createChildren(Void):Void {
		bulb = createObject("active", "bulb", 1, {styleName:this, owner:this});
		size();
	}
	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height
	function size(Void):Void {
		bulb.setSize(20, __height);
		bulb._x = (__width-20)/2+3;
		bulb._y = (__height-16)/2+3;
	}
	function setValue(str:String, item:Object, sel:Boolean):Void {
	}
	function getPreferredHeight(Void):Number {
		return 16;
	}
	function getPreferredWidth(Void):Number {
		return 20;
	}
}
