class bi.ui.TextInput extends bi.ui.CoreUI {
	private var text_txt:TextField;
	private var text_tf:TextFormat;
	private var bg_mc:MovieClip;
	private var highlight_mc:MovieClip;
		
	private var _text:String = "";
	private var _font:String;
	private var _fontSize:Number;
	private var _fontColour:Number;
	private var _maxValue:Number = 10;
	private var _minValue:Number = 1;
	private var _maxChars:Number = 10;
	private var _minChars:Number = 1;
	private var _inputType:String;
	private var _readOnly:Boolean = false;
	private var _password:Boolean = false;
	private var _wordWrap:Boolean = true;
	
	private var _borderWidth:Number = 0;
	private var _borderColour:Number = 0xFFFFFF;
	private var _bgColour:Number = 0x7488A7;
	private var _bgOpacity:Number = 100;
	private var _cornerRadius:Number = 7;
	
	private var onPress2:Function;
	
	/* Getters and Setters */
	
	public function get text():String {
		return _text;
	}
	
	public function set text(txt:String):Void {
		if (txt != undefined) {
			_text = txt;
			text_txt.text = _text;
		}
	}

	public function get readOnly():Boolean {
		return _readOnly;
	}
	
	public function set readOnly(readOnly:Boolean):Void {
		_readOnly = readOnly;
	}
	
	public function set restrict(chars:String):Void {
		text_txt.restrict = chars;
	}
	
	public function set wordWrap(wrap:Boolean):Void {
		_wordWrap = wrap;
		text_txt.wordWrap = wrap;
	}
	
	public function set password(pwd:Boolean):Void {
		_password = pwd;
		text_txt.password = pwd;
	}
	
	public function get length():Number {
		return text_txt.length;
	}
	
	public function get minValue():Number {
		return _minValue;
	}
	
	public function set minValue(min:Number):Void {
		_minValue = min;
	}
	
	public function get maxValue():Number {
		return _maxValue;
	}
	
	public function set maxValue(max:Number):Void {
		_maxValue = max;
	}
	
	public function get minChars():Number {
		return _minChars;
	}
	
	public function set minChars(min:Number):Void {
		_minChars = min;
	}
	
	public function get maxChars():Number {
		return _maxChars;
	}
	
	public function set maxChars(max:Number):Void {
		_maxChars = max;
	}
	
	public function set inputType(type:String):Void {
		_inputType = type;
	}
	
	public function set font(font:String):Void {
		if (font != undefined) {
			_font = font;
		}
	}
	
	public function set fontSize(fontSize:Number):Void {
		if (fontSize != undefined) {
			_fontSize = fontSize;
			text_tf = new TextFormat();
			text_tf.size = _fontSize;
			text_txt.setNewTextFormat(text_tf);
		}
	}
	
	public function set fontColour(fontColour:Number):Void {
		if (fontColour != undefined) {
			_fontColour = fontColour;
			text_tf = new TextFormat();
			text_tf.color = _fontColour;
			text_txt.setNewTextFormat(text_tf);

		}
	}
	
	public function set highlight(highlight:Boolean):Void {
		highlight_mc._visible = highlight;
	}
	
	/* Constructor */
	
	function TextInput() {
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
		createTextField("text_txt", 30, 2, 2, __width - 4, __height - 4);
		text_txt.embedFonts = true;
		text_txt.selectable = false;
		text_txt.wordWrap = _wordWrap;
		text_txt.password = _password;
			
		onPress2 = function () {
			if (!_readOnly) {
				var updateTitle = function (txt, caller) {
					if ((caller._inputType != "numeric" && txt.length >= caller._minChars) || (caller._inputType == "numeric" && Number(txt) >= caller._minValue && Number(txt) <= caller._maxValue)) {
						caller.text = txt;
					}
				}
				_root.showKeyboard(_maxChars, updateTitle, this, _text, false, _inputType);
			}
			dispatchEvent({type:"focus", target:this});
		}
	}
  
	private function draw():Void {
		if (!__width) return;
				
		text_txt._width = __width - 4;
		text_txt._height = __height - 4;

		text_tf = new TextFormat();
		text_tf.color = _fontColour;
		text_tf.size = _fontSize;
		text_tf.bold = true;
		text_tf.font = "bi.ui.Fonts:" + _font;
		text_txt.setNewTextFormat(text_tf);
		
		text_txt.text = _text;
		
		createEmptyMovieClip("bg_mc", 10);
		
		if (_borderWidth) bg_mc.lineStyle(_borderWidth, _borderColour);
		
		bg_mc.beginFill(_bgColour, _bgOpacity);
		bg_mc.drawRect(0, 0, __width, __height, _cornerRadius);
		bg_mc.endFill();
		
		createEmptyMovieClip("highlight_mc", 20);
		highlight_mc._visible = false;
		
		highlight_mc.lineStyle(1, 0xFFCC00, 100, true);
		highlight_mc.drawRect(0, 0, __width, __height, _cornerRadius);
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			text_txt.filters = [_global.settings.dropShadowFilterSmall];
			bg_mc.filters = [_global.settings.dropShadowFilterSmall];
		}
	}
}