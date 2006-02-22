class bi.ui.CoreUI extends MovieClip {
	private var clipParameters:Object = {width:1, height:1, settings:1}; 

	private var mcBoundingBox:MovieClip;
	
	private var __width:Number;
	private var __height:Number;
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	
	public function set width(width:Number):Void {
		setSize(width, null);
	}

	public function get width():Number {
		return __width;
	}
  
	public function set height(height:Number):Void {
		setSize(null, height);
	}

	public function get height():Number {
		return __height;
	}

	public function set settings(settings:Object):Void {
		var i;
		for (i in settings) {
			this[i] = settings[i];
		}
		draw();
	}
	
	public function setSize(width:Number, height:Number):Void {
		_xscale = 100;
		_yscale = 100;
		if (width) __width = width;
		if (height) __height = height;
		draw();
	}
	
	function CoreUI() {
		mx.events.EventDispatcher.initialize(this);
		
		if (!__width) __width = _width;
		if (!__height) __height = _height;
		
		_xscale = 100;
		_yscale = 100;
		
		mcBoundingBox._visible = false;
		mcBoundingBox._width = 0;
		mcBoundingBox._height = 0;
	}
	
	private function init():Void {
	}
	
	private function draw():Void {}
	
	private function initFromClipParameters():Void {
		var key:String;
		var found:Boolean = false;
		for (key in clipParameters) {
			//trace(key);
			if (this.hasOwnProperty(key)) {
				found = true;
				this["def_" + key] = this[key];
				delete this[key];
			}
		}
		if (found) {
			for (key in clipParameters) {
				var v = this["def_" + key];
				if(v != undefined) {
					this[key] = v;
				}
			}
		}
	}
}