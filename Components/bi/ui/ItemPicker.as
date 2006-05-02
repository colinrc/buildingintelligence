import bi.ui.TextInput;
import bi.ui.Button;
import mx.utils.Delegate;

class bi.ui.ItemPicker extends bi.ui.CoreUI {

	private var items_ti:TextInput;
	private var up_btn:Button;
	private var down_btn:Button;
	
	private var _items:Array;
	private var _selectedIndex:Number;
	
	private var _repeatInterval;

	/* Getters and Setters */

	public function get selectedIndex():Number {
		return _selectedIndex;
	}
	
	public function set selectedIndex(index:Number):Void {
		if (index != undefined) {
			_selectedIndex = index;
			items_ti.text = _items[_selectedIndex].label;
		}
	}
	
	public function get selectedItem():Object {
		return _items[_selectedIndex];
	}
		
	public function set selectedValue(val):Void {
		for (var i=0; i<_items.length; i++) {
			if (_items[i].value == val) {
				selectedIndex = i;
				break;
			}
		}
	}
	
	public function set items(items:Array):Void {
		if (items != undefined) {
			_items = items;
			selectedIndex = 0;
		}
	}
	
	
	/* Constructor */
	
	function ItemPicker() {
		createChildren();
		draw();
	}

	/* Private functions */

	private function init():Void {
	}

	private function createChildren():Void {
		attachMovie("bi.ui.TextInput", "items_ti", 10, {settings:{width:__width - 93, readOnly:true}});
		attachMovie("bi.ui.Button", "up_btn", 40, {settings:{width:42, iconName:"up-arrow"}});
		attachMovie("bi.ui.Button", "down_btn", 50, {settings:{width:42, iconName:"down-arrow"}});
		
		up_btn.addEventListener("press", Delegate.create(this, buttonPress));
		down_btn.addEventListener("press", Delegate.create(this, buttonPress));
		up_btn.addEventListener("release", Delegate.create(this, buttonRelease));
		down_btn.addEventListener("release", Delegate.create(this, buttonRelease));
		
		selectedIndex = 0;
	}
  
	private function draw():Void {
		if (!__width) return;
		
		items_ti.width = __width - up_btn._width - down_btn._width;
		up_btn._x = __width - up_btn._width - down_btn._width - 4;
		down_btn._x = __width - down_btn._width;
	}
		
	private function buttonPress(eventObj):Void {
		if (eventObj.target == up_btn) {
			_repeatInterval = setInterval(this, "buttonAction", 200, "up");
			buttonAction("up");
		} else {
			_repeatInterval = setInterval(this, "buttonAction", 200, "down");
			buttonAction("down");
		}
	}
	
	private function buttonRelease(eventObj):Void {
		clearInterval(_repeatInterval);
	}
	
	private function buttonAction(direction):Void {
		var index = _selectedIndex;
		if (direction == "up") {
			var amt = 1;
		} else {
			var amt = - 1;
		}
		index += amt;
		if (index == _items.length) index = 0;
		if (index < 0) index = _items.length - 1;
		
		selectedIndex = index;
	}
}