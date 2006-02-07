class bi.ui.ItemPicker extends MovieClip {

	private var mcBoundingBox:MovieClip;
	private var __width:Number;
	private var __height:Number;
	private var dispatchEvent:Function;

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
  
	public function setSize(width:Number, height:Number):Void {
		_xscale = 100;
		_yscale = 100;
		__width = width;
		__height = height;
		arrange();
	}

	function ItemPicker() {
		init();
		createChildren();
		arrange();
	}

	private function init():Void {
		__width = _width;
		__height = _height;
		_xscale = 100;
		_yscale = 100;
		mx.events.EventDispatcher.initialize(this);
		mcBoundingBox._visible = false;
		mcBoundingBox._width = 0;
		mcBoundingBox._height = 0;
	}

	private function createChildren():Void {
	}
  
	private function arrange():Void {
	}
}