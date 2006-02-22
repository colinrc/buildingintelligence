import flash.display.BitmapData;

class bi.ui.Icon extends bi.ui.CoreUI {
	private var clipParameters:Object = {settings:1, size:1, iconName:1, overlay:1};
	
	private var mcBoundingBox:MovieClip;
	private var icons_mc:MovieClip;
	private var _txtOverlay:TextField;
	private var _size:Number;
	private var _iconName:String;
	private var _overlay:String;

	public function set size(size:Number):Void {
		_size = size;
		setSize(_size, _size);
		draw();
	}

	public function get size():Number {
		return _size;
	}

	public function set iconName(iconName:String):Void {
		_iconName = iconName.split(":")[0];
		draw();
	}

	public function get iconName():String {
		return _iconName;
	}

	public function set overlay(overlay:String):Void {
		_overlay = overlay;
		if  (_overlay.length) {
			createTextField("_txtOverlay", 100, 0, 0, 40, 40);
			var label_tf:TextFormat = new TextFormat();
			label_tf.size = 14;
			label_tf.bold = true;
			label_tf.font = "bi.ui.globalFont";
			_txtOverlay.embedFonts = true;
			_txtOverlay.selectable = false;
			_txtOverlay.setNewTextFormat(label_tf);
			_txtOverlay.text = _overlay;
		} else {
			removeMovieClip("_txtOverlay");
		}
		draw();
	}

	public function get overlay():String {
		return _overlay;
	}
	
	function Icon() {
		initFromClipParameters();
		if (!_size) _size = (_width < _height) ? __width : __height;
		createChildren();
		draw();
	}

	private function init():Void {
	}

	private function createChildren():Void {
	}
  
	private function draw():Void {
		if (!_size || !_iconName.length) return;
		
		if (_global.settings.device == "pda" || _global.flashMajorVersion < 8) {
			attachMovie("icons", "icons_mc", 10);
			icons_mc.gotoAndStop(_iconName);
		} else {
			attachBitmap(_global.icons[_iconName], 0, "auto", true);
		}
			
		_width = _size;
		_yscale = _xscale;
	}
}