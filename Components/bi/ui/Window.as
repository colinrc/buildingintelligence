import bi.ui.Icon;
import flash.geom.*
		
class bi.ui.Window extends bi.ui.CoreUI {
	private var clipParameters:Object = {width:1, height:1, settings:1, title:1, hideClose:1, iconName:1, bgColour1:1, bgColour2:1, bgOpacity:1, shadowOffset:1, borderWidth:1, borderColour:1, cornerRadius:1, contentClip:1};   
	
	private var shadow_mc:MovieClip;
	private var bg_mc:MovieClip;
	private var mask_mc:MovieClip;
	private var content_mc:MovieClip;
	private var close_btn:MovieClip;
	private var icon_mc:Icon;
	
	private var title_txt:TextField;
	
	private var _hideClose:Boolean = false;
	private var _borderColour:Number;
	private var _borderWidth:Number;
	private var _cornerRadius:Number;
	private var _bgColour1:Number;
	private var _bgColour2:Number;
	private var _bgOpacity:Number;
	private var _shadowOffset:Number
	private var _font:String;
	private var _title:String;
	private var _iconName:String;

	/* Getters and Setters */
	
	public function set title(title:String):Void {
		_title = title;
		title_txt.text = _title;
	}
	public function get title():String {
		return _title;
	}

	public function set font(font:String):Void {
		if (font != undefined) {
			_font = font;
		}
	}
	
	public function set hideClose(hideClose:Boolean):Void {
		_hideClose = hideClose;
	}
	
	public function set iconName(iconName:String):Void {
		_iconName = iconName;
	}

	public function set bgColour1(colour:Number):Void {
		_bgColour1 = colour;
	}
	
	public function set bgColour2(colour:Number):Void {
		_bgColour2 = colour;
	}
	
	public function set bgOpacity(opacity:Number):Void {
		_bgOpacity = opacity;
	}
	
	public function set shadowOffset(shadowOffset:Number):Void {
		_shadowOffset = shadowOffset;
	}
	
	public function set borderWidth(borderWidth:Number):Void {
		_borderWidth = borderWidth;
	}
	
	public function set borderColour(borderColour:Number):Void {
		_borderColour = borderColour;
	}
	
	public function set cornerRadius(cornerRadius:Number):Void {
		_cornerRadius = cornerRadius;
	}

	public function get contentClip():MovieClip {
		return content_mc;
	}
	
	/* Constructor */
	
	function Window() {
		initFromClipParameters();
		
		if (_font == null) _font = _global.settings.windowFont;
		if (_borderColour == null) _borderColour = _global.settings.windowBorderColour;
		if (_borderWidth == null) _borderWidth = _global.settings.windowBorderWidth;		
		if (_cornerRadius == null) _cornerRadius = _global.settings.windowCornerRadius;
		if (_bgColour1 == null) _bgColour1 = _global.settings.windowBgColour1;
		if (_bgColour2 == null) _bgColour2 = _global.settings.windowBgColour2;
		if (_bgOpacity == null) _bgOpacity = _global.settings.windowBgOpacity;
		if (_shadowOffset == null) _shadowOffset = _global.settings.windowShadowOffset;
		
		createChildren();
		draw();
	}

	private function init():Void {
	}

	private function createChildren():Void {
		createEmptyMovieClip("mask_mc", 15);
		createEmptyMovieClip("content_mc", 20);

		attachMovie("bi.ui.Icon", "icon_mc", 30, {size:28, iconName:_iconName});
				
		createTextField("title_txt", 35, 10, 16, 10, 28);
		var title_tf = new TextFormat();
		title_tf.color = 0xFFFFFF;
		title_tf.size = 18;
		title_tf.bold = true;
		title_tf.font = "bi.ui.Fonts:" + _font;
		title_txt.embedFonts = true;
		title_txt.selectable = false;
		title_txt.setNewTextFormat(title_tf);
		title_txt.text = _title;
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			title_txt.filters = [_global.settings.dropShadowFilterSmall];
		}
		
		mask_mc.beginFill(0xFFCC00);
		mask_mc.drawRect(0,0,10,10);
		mask_mc.endFill();
		
		//content_mc.setMask(mask_mc);
		mask_mc._visible = false;
	}
  
	private function draw():Void {
		if (!__width || !__height) return;
		
		//trace("drawing window " + __width + ":" + __height);
		
		createEmptyMovieClip("bg_mc", 10);
		
		if (_borderWidth) bg_mc.lineStyle(_borderWidth, _borderColour);
		
		if (_bgColour1 == _bgColour2 || _global.settings.device == "pda" || new Matrix() == undefined) {
			bg_mc.beginFill(_bgColour1, _bgOpacity);
		} else {
			var matrix = new Matrix();
			matrix.createGradientBox(__width, __height, 90/180 * Math.PI, 0, 0);
			bg_mc.beginGradientFill("linear", [_bgColour1, _bgColour2], [_bgOpacity, _bgOpacity], [0, 255], matrix);
		}
		bg_mc.drawRect(0, 0, __width, __height, _cornerRadius);
		bg_mc.endFill();
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			bg_mc.filters = [_global.settings.dropShadowFilterBig];
		}
	
		bg_mc.onPress = function () {};
		bg_mc.useHandCursor = false;

		if (!_hideClose) {
			close_btn._visible = true;
			attachMovie("bi.ui.Window:windowCloseBtn","close_btn", 25);
			close_btn.onPress = function () {
				this._parent.close();
			}
			if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
				close_btn.filters = [_global.settings.dropShadowFilterMedium];
			}
			close_btn._y = 8;
			close_btn._x = __width - close_btn._width - close_btn._y;
		} else {
			close_btn._visible = false;
		}
		
		mask_mc._x = content_mc._x = 5;
		content_mc.width = __width - 10;
		mask_mc._y = content_mc._y = 55;
		content_mc.height = __height - 60;
		mask_mc._width = __width - 10;
		mask_mc._height = __height - 60;
		
		title_txt._x = 10;
		title_txt._width = __width
		
		if (_iconName.length) {
			icon_mc._visible = true;
			icon_mc._x = 10;
			icon_mc._y = title_txt._y;
			icon_mc.iconName = _iconName;
			title_txt._x += 35;
			title_txt._width -= 35;
		} else {
			icon_mc._visible = false;
		}
				
		title_txt._width -= close_btn._width + 30;
	}
}