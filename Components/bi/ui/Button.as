import bi.ui.Icon;

class bi.ui.Button extends bi.ui.CoreUI {
	private var buttonBg_mc:MovieClip;
	private var buttonHighlight_mc:MovieClip;
	private var buttonFace_mc:MovieClip;
	private var icon_mc:Icon;
	
	private var label_txt:TextField;
	private var label_tf:TextFormat;
		
	private var _enabled:Boolean = true;
	private var _label:String;
	private var _font:String;
	private var _fontSize:Number;
	private var _fontColour:Number;
	private var _iconName:String;
	private var _bgColour:Number;
	private var _borderColour:Number;
	
	private var _showHighlight:Boolean = true;
	private var _toggle:Boolean = false;
	
	private var onPress2:Function;

	/* Getters and Setters */
	
	public function set label(label:String):Void {
		_label = label;

		if (_label.length && label_txt) {
			label_txt.text = " " + _label + " ";
			label_txt.filters = null;
			label_txt._visible = true;
			label_tf.size = _fontSize;
			while (label_txt.textWidth > __width - 4) {
				label_tf.size--;
				label_txt.setTextFormat(label_tf);
			}
			label_txt._x = Math.round((__width/2) - (label_txt._width/2));
			label_txt._y = Math.round((__height/2) - (label_txt._height/2));
			
			if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
				label_txt.filters = [_global.settings.dropShadowFilterSmall];
			}
		} else {
			label_txt._visible = false;
		}
	}

	public function get label():String {
		return _label;
	}
	
	public function set iconName(iconName:String):Void {
		_iconName = iconName;
		
		icon_mc.iconName = _iconName;
	}

	public function get iconName():String {
		return _iconName;
	}
	
	public function set enabled(enabled:Boolean):Void {
		_enabled = enabled;
		this._alpha = (_enabled) ? 100 : 30;
		this.useHandCursor = _enabled;
		if (!enabled && buttonHighlight_mc._visible) {
			//if (!this.showOn) showHighlight();
		}
	}

	public function get enabled():Boolean {
		return _enabled;
	}

	public function set toggle(toggle:Boolean):Void {
		_toggle = toggle;
	}

	public function get toggle():Boolean {
		return _toggle;
	}
	
	public function set highlight(show:Boolean):Void {
		_showHighlight = show;
		if (_showHighlight && !buttonHighlight_mc._visible) {
			buttonHighlight_mc._visible = true;
		} else if (!_showHighlight && buttonHighlight_mc._visible) {
			// fade out the highlight
			buttonHighlight_mc.onEnterFrame = function () {
				_alpha -= 20;
				if (_alpha < 0) {
					_visible = false;
					_alpha = 100;
					delete this.onEnterFrame;
				}
			}
		}
	}
	
	public function get highlight():Boolean {
		return _showHighlight;
	}
	
	public function set font(font:String):Void {
		if (font != undefined) {
			_font = font;
		}
	}
	
	public function set fontSize(fontSize:Number):Void {
		if (fontSize != undefined) {
			_fontSize = fontSize;
		}
	}
	
	public function set fontColour(fontColour:Number):Void {
		if (fontColour != undefined) {
			_fontColour = fontColour;
		}
	}
	
	public function set bgColour(bgColour:Number):Void {
		if (bgColour != undefined) {
			_bgColour = bgColour;
			new Color(buttonFace_mc).setRGB(_bgColour);
		}
	}

	public function set borderColour(borderColour:Number):Void {
		if (borderColour != undefined) {
			_borderColour = borderColour;
			new Color(buttonBg_mc).setRGB(_borderColour);
		}
	}

	/* Constructor */
	
	function Button() {
		if (_bgColour == null) bgColour = _global.settings.buttonBgColour;
		if (_borderColour == null) borderColour = _global.settings.buttonBorderColour;
		if (_font == null) _font = _global.settings.buttonFont
		if (_fontColour == null) _fontColour = _global.settings.buttonFontColour;
		if (_fontSize == null) _fontSize = _global.settings.buttonFontSize;
		
		createChildren();
		draw();
	}

	/* Private functions */
	
	private function init():Void {
	}

	private function createChildren():Void {
		//this.label_txt.removeMovieClip();
		//attachMovie("bi.ui.Button:buttonBg", "buttonBg_mc", 10);
		//attachMovie("bi.ui.Button:buttonHighlight", "buttonHighlight_mc", 20);
		//attachMovie("bi.ui.Button:buttonFace", "buttonFace_mc", 30);
		
		attachMovie("bi.ui.Icon", "icon_mc", 100, {iconName:_iconName});
				
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			this.filters = [_global.settings.dropShadowFilterSmall];
		}

		createTextField("label_txt", 200, 0, 0, 1, 1);
		label_tf = new TextFormat();
		label_tf.color = _fontColour;
		label_tf.size = _fontSize;
		label_tf.bold = true;
		label_tf.font = "bi.ui.Fonts:" + _font;
		label_txt.autoSize = true;
		label_txt.embedFonts = true;
		label_txt.selectable = false;
		label_txt.setNewTextFormat(label_tf);
		label = label;
				
	    onPress2 = function():Void {
			if (_enabled) {
				if (!_toggle) highlight = true;
				dispatchEvent({type:"onPress", target:this});
				dispatchEvent({type:"press", target:this});
			}
		}
	    onRelease = function():Void {
			if (!_toggle) highlight = false;
			dispatchEvent({type:"onRelease", target:this});
			dispatchEvent({type:"release", target:this});
		}
	    onDragOut = function():Void {
			if (!_toggle) highlight = false;
			dispatchEvent({type:"onDragOut", target:this});
			dispatchEvent({type:"dragout", target:this});
			dispatchEvent({type:"release", target:this});
		}
	}
  
	private function draw():Void {
		if (!__width || !__height) return;
		
		//trace("drawing button " + this);
		
		buttonBg_mc._width = buttonHighlight_mc._width = buttonFace_mc._width = __width;
		buttonBg_mc._height = buttonHighlight_mc._height = buttonFace_mc._height = __height;
		buttonFace_mc._width -= 4;
		buttonFace_mc._height -= 4;
		buttonFace_mc._x = buttonFace_mc._y = 2;
		buttonHighlight_mc._visible = false;

		//new Color(buttonFace_mc).setRGB(_bgColour);
		//new Color(buttonBg_mc).setRGB(_borderColour);
		
		if (_iconName.length) {
			if (__width < __height) {
				var size = __width - 10;
			} else {
				var size = __height - 10;
			}
			icon_mc.size = size;
			icon_mc._x = Math.round((__width / 2) - (icon_mc._height / 2));
			icon_mc._y = Math.round((__height / 2) - (icon_mc._height / 2));
		}
	}
}