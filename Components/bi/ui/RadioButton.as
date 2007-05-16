import bi.ui.RadioButtonGroup;

class bi.ui.RadioButton extends bi.ui.CoreUI {
	private var clipParameters:Object = {settings:1, width:1, height:1, text:1};   

	private var label_txt:TextField;
	private var label_tf:TextFormat;
	private var icon_mc:MovieClip
	private var bg_mc:MovieClip;
		
	private var _tickIcon:String = "check2";

	private var _label:String;
	private var _font:String;
	private var _fontSize:Number = 16;
	private var _fontColour:Number = 0xFFFFFF;
	
	private var _borderWidth:Number = 0;
	private var _borderColour:Number = 0xFFFFFF;
	private var _bgColour:Number = 0x7488A7;
	private var _bgOpacity:Number = 100;
	private var _cornerRadius:Number = 7;
	
	private var _selected:Boolean = false;
	private var _enabled:Boolean = true;
	private var _data;
	private var _group:String = "";
	
	private var onPress2:Function;
	
	/* Getters and Setters */
	
	public function get selected():Boolean {
		return _selected;
	}
	
	public function set selected(select:Boolean):Void {
		_selected = select;
		if (_group.length) {
			_parent[_group].selectedClip = this;
		}
		icon_mc._visible = _selected;
	}
	
	public function set groupName(group:String):Void {
		_group = group;
		if (_parent[_group] == undefined) {
			_parent[_group] = new RadioButtonGroup();
		}
		_parent[_group].addClip(this);
	}
	
	public function set label(label:String):Void {
		_label = label;
		label_txt.text = _label;
	}
	
	public function get data() {
		return _data;
	}
	
	public function set data(data):Void {
		_data = data;
	}
	
	/* Constructor */
	
	function RadioButton() {
		if (_font == null) _font = _global.settings.buttonFont;
		if (_fontColour == null) _fontColour = _global.settings.buttonFontColour;
		if (_fontSize == null) _fontSize = _global.settings.buttonFontSize;

		createChildren();
		draw();
	}

	/* Private functions */
	
	private function init():Void {
	}

	private function createChildren():Void {
		createTextField("label_txt", 0, 0, 0, __width, __height);
		label_txt.embedFonts = true;
		label_txt.selectable = false;
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			label_txt.filters = [_global.settings.dropShadowFilterSmall];
		}
			
		attachMovie("bi.ui.Icon", "icon_mc", 100, {iconName:_tickIcon});
		
		onPress2 = function():Void {
			if (_enabled && (!selected || _group.length == 0)) {
				selected = !selected;
				dispatchEvent({type:"click", target:this});
				_parent[_group].click();
			}
		}
	}
  
	private function draw():Void {
		if (!__width) return;
		
		createEmptyMovieClip("bg_mc", 10);
		
		if (_borderWidth) bg_mc.lineStyle(_borderWidth, _borderColour);
		
		bg_mc.beginFill(_bgColour, _bgOpacity);
		bg_mc.drawRect(0, 0, __height, __height, _cornerRadius);
		bg_mc.endFill();
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			bg_mc.filters = [_global.settings.dropShadowFilterSmall];
		}
		
		label_txt._x = bg_mc._width + 5;
		label_txt._y = 2;
		label_txt._width = __width - label_txt._x;
		label_txt._height = __height - 2;

		label_tf = new TextFormat();
		label_tf.color = _fontColour;
		label_tf.size = _fontSize;
		label_tf.bold = true;
		label_tf.font = "bi.ui.Fonts:" + _font;
		label_txt.setNewTextFormat(label_tf);
		
		label_txt.text = _label;
		
		icon_mc._visible = _selected;
		icon_mc.size = Math.round(bg_mc._height * .8);
		icon_mc._x = Math.round((bg_mc._width / 2) - (icon_mc._width / 2));
		icon_mc._y = Math.round((bg_mc._height/ 2) - (icon_mc._height / 2));
	}
}