class bi.ui.Label extends bi.ui.CoreUI {
	private var clipParameters:Object = {settings:1, width:1, height:1, text:1, align:1, fontSize:1, fontColour:1};   
	
	private var label_txt:TextField;
	private var label_tf:TextFormat;
		
	private var _label:String;
	private var _align:String = "left";
	private var _font:String;
	private var _fontSize:Number;
	private var _fontColour:Number;
	
	/* Getters and Setters */
	
	public function set text(txt:String):Void {
		if (txt != undefined) {
			_label = txt;
			label_txt.text = _label;
		}
	}
	
	public function set align(alignment:String):Void {
		if (alignment != undefined) {
			_align = alignment;
			label_tf = new TextFormat();
			label_tf.align = _align;
			label_txt.setTextFormat(label_tf);
		}
	}

	public function set font(font:String):Void {
		if (font != undefined) {
			_font = font;
		}
	}
	
	public function set fontSize(fontSize:Number):Void {
		if (fontSize != undefined) {
			_fontSize = fontSize;
			label_tf = new TextFormat();
			label_tf.size = _fontSize;
			label_txt.setTextFormat(label_tf);
		}
	}
	
	public function set fontColour(fontColour:Number):Void {
		if (fontColour != undefined) {
			_fontColour = fontColour;
			label_tf = new TextFormat();
			label_tf.color = _fontColour;
			label_txt.setTextFormat(label_tf);
		}
	}
	
	/* Constructor */
	
	function Label() {
		initFromClipParameters();
		
		if (_font == null) _font = _global.settings.labelFont;
		if (_fontColour == null) _fontColour = _global.settings.labelFontColour;
		if (_fontSize == null) _fontSize = _global.settings.labelFontSize;
		
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
		label_txt.wordWrap = true;
		label_txt.autoSize = true;
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			label_txt.filters = [_global.settings.dropShadowFilterSmall];
		}
	}
  
	private function draw():Void {
		if (!__width || !__height) return;
		
		label_txt._width = __width;
		label_txt._height = __height;

		label_tf = new TextFormat();
		label_tf.color = _fontColour;
		label_tf.size = _fontSize;
		label_tf.bold = true;
		label_tf.font = "bi.ui.Fonts:" + _font;
		label_tf.align = _align;
		label_txt.setNewTextFormat(label_tf);
		
		label_txt.text = _label;
	}
}