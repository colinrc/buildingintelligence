class bi.ui.CheckBox extends bi.ui.CoreUI {
	private var icon_mc:MovieClip
	private var bg_mc:MovieClip;
		
	private var _tickIcon:String = "check2";

	private var _borderWidth:Number = 0;
	private var _borderColour:Number = 0xFFFFFF;
	private var _bgColour:Number = 0x7488A7;
	private var _bgOpacity:Number = 100;
	private var _cornerRadius:Number = 7;
	
	private var _selected:Boolean = false;
	private var _enabled:Boolean = true;
	
	private var onPress2:Function;
	
	/* Getters and Setters */
	
	public function get selected():Boolean {
		return _selected;
	}
	
	public function set selected(select:Boolean):Void {
		_selected = select;
		icon_mc._visible = _selected;
	}
	
	/* Constructor */
	
	function CheckBox() {
		createChildren();
		draw();
	}

	/* Private functions */
	
	private function init():Void {
	}

	private function createChildren():Void {

		attachMovie("bi.ui.Icon", "icon_mc", 100, {iconName:_tickIcon});
		
		onPress2 = function():Void {
			if (_enabled) {
				selected = !selected;
				dispatchEvent({type:"click", target:this});
				dispatchEvent({type:"change", target:this});
			}
		}
	}
  
	private function draw():Void {
		if (!__width) return;

		createEmptyMovieClip("bg_mc", 10);
		
		if (_borderWidth) bg_mc.lineStyle(_borderWidth, _borderColour);
		
		bg_mc.beginFill(_bgColour, _bgOpacity);
		bg_mc.drawRect(0, 0, __width, __height, _cornerRadius);
		bg_mc.endFill();
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			bg_mc.filters = [_global.settings.dropShadowFilterSmall];
		}
		
		icon_mc._visible = _selected;
		icon_mc.size = Math.round(__width * .8);
		icon_mc._x = Math.round((__width / 2) - (icon_mc._width / 2));
		icon_mc._y = Math.round((__height/ 2) - (icon_mc._height / 2));
	}
}