import mx.controls.*;
import mx.utils.Delegate;

class Controls.MapEditor extends mx.core.View {
	private var zoomOut_btn:mx.controls.Button;
	private var zoom100_btn:mx.controls.Button;
	private var zoomIn_btn:mx.controls.Button;
	
	private var __width:Number;
	private var __height:Number;

	/* Getters and Setters */

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
	
	/* Public functions */
	
	public function setSize(width:Number, height:Number):Void {
		_xscale = 100;
		_yscale = 100;
		if (width) __width = width;
		if (height) __height = height;
		draw();
	}
	
	/* Constructor */
	
	function MapEditor() {
		init();
		draw();
	}
	
	/* Private functions */
	
	private function init():Void {
		if (!__width) __width = _width;
		if (!__height) __height = _height;
		
		_xscale = 100;
		_yscale = 100;
		
		zoomOut_btn.addEventListener("click", Delegate.create(this, zoomOut));
		zoom100_btn.addEventListener("click", Delegate.create(this, zoom100));
		zoomIn_btn.addEventListener("click", Delegate.create(this, zoomIn));
	}
	
	private function zoomOut():Void {
		trace("yaya");
	}
	
	private function zoom100():Void {
		trace("yaya2");
	}
	
	private function zoomIn():Void {
		trace("yaya3");
	}
	
	private function draw():Void {}
}