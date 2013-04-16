import flash.display.BitmapData;

class bi.ui.Icon extends bi.ui.CoreUI {
	private var icons_mc:MovieClip;
	
	private var _overlayContainer:MovieClip;
	private var _overlayBg:MovieClip;
	private var _txtOverlay:TextField;
	private var label_tf:TextFormat;
	
	private var _size:Number;
	private var _iconName:String;
	private var _overlay:String;

	private var _overlayBgColour:Number;
	private var _overlayBgAlpha:Number;
	private var _overlayFont:String
	private var _overlayFontColour:Number;
	private var _overlayFontSize:Number;
	private var _overlayAlign:String;
	
	public function set size(size:Number):Void {
		if (size != undefined) {
			_size = size;
			_width = _size;
			_yscale = _xscale;
		}		
	}

	public function get size():Number {
		return _size;
	}

	public function set overlayBgColour(overlayBgColour:Number):Void {
		if (overlayBgColour != undefined) {
			_overlayBgColour = overlayBgColour;
		}
	}
	
	public function set overlayBgAlpha(overlayBgAlpha:Number):Void {
		if (overlayBgAlpha != undefined) {
			_overlayBgAlpha = overlayBgAlpha;
		}
	}	
	
	public function set overlayFont(overlayFont:String):Void {
		if (overlayFont != undefined) {
			_overlayFont = overlayFont;
		}
	}
	
	public function set overlayFontColour(overlayFontColour:Number):Void {
		if (overlayFontColour != undefined) {
			_overlayFontColour = overlayFontColour;
		}
	}
	
	public function set overlayFontSize(overlayFontSize:Number):Void {
		if (overlayFontSize != undefined) {
			_overlayFontSize = overlayFontSize;
		}
	}
	
	public function set overlayAlign(overlayAlign:String):Void {
		if (overlayAlign != undefined) {
			_overlayAlign = overlayAlign;
		}
	}
	
	public function set iconName(iconName:String):Void {
		_iconName = iconName.split(":")[0];
		if (iconName.split(":")[1].length) overlay = iconName.split(":")[1];
		
		if (_global.settings.device == "pda" || _global.flashMajorVersion < 8) {
			attachMovie("icons", "icons_mc", 10);
			icons_mc.gotoAndStop(_iconName);
		} else {
			attachBitmap(_global.icons[_iconName], 0, "auto", true);
		}
	}

	public function get iconName():String {
		return _iconName;
	}

	public function set overlay(overlay:String):Void {
		_overlay = overlay;
		if  (_overlay.length && _overlayFontSize) {
			createEmptyMovieClip("_overlayContainer", 50);
			
			_txtOverlay = _overlayContainer.createTextField("_txtOverlay", 10, 1, 0, 40, 40);
			label_tf = new TextFormat();
			label_tf.size = _overlayFontSize;
			label_tf.bold = true;
			label_tf.font = "bi.ui.Fonts:" + _overlayFont;
			label_tf.color = _overlayFontColour;
			_txtOverlay.autoSize = true;
			_txtOverlay.embedFonts = true;
			_txtOverlay.selectable = false;
			_txtOverlay.setNewTextFormat(label_tf);
			_txtOverlay.text = _overlay;
			
			_overlayBg = _overlayContainer.createEmptyMovieClip("_overlayBg", 0);
			_overlayBg.beginFill(_overlayBgColour, _overlayBgAlpha);
			_overlayBg.drawRect(0, 0, _txtOverlay._width + 2,_txtOverlay._height);
			_overlayBg.endFill();
			
			if (_overlayAlign.substr(1, 1) == "R") {
				_overlayContainer._x = Math.round(_width - _overlayContainer._width);
			}
			if (_overlayAlign.substr(0, 1) == "B") {
				_overlayContainer._y = Math.round(_height - _overlayContainer._height);
			}			
		} else {
			removeMovieClip("_overlayContainer");
		}
	}

	public function get overlay():String {
		return _overlay;
	}
	
	function Icon() {
		if (_overlayBgColour == null) _overlayBgColour = _global.settings.iconOverlayBgColour;
		if (_overlayBgAlpha == null) _overlayBgAlpha = _global.settings.iconOverlayBgAlpha;
		if (_overlayFont == null) _overlayFont = _global.settings.iconOverlayFont;
		if (_overlayFontColour == null) _overlayFontColour = _global.settings.iconOverlayFontColour;
		if (_overlayFontSize == null) _overlayFontSize = _global.settings.iconOverlayFontSize;
		if (_overlayAlign == null) _overlayAlign = _global.settings.iconOverlayAlign;
		
		createChildren();
		draw();
	}

	private function init():Void {
	}

	private function createChildren():Void {
		overlay(_overlay);
	}
  
	private function draw():Void {
		if (_size) {
			//trace("drawing icon for " + this + ":" + _size);
			_width = _size;
			_yscale = _xscale;
		}
	}
}