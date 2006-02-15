import mx.controls.Button;
import mx.containers.ScrollPane;
import mx.utils.Delegate;

class Controls.MapEditor extends MovieClip {

	private var zoomOut_btn:Button;
	private var zoom100_btn:Button;
	private var zoomIn_btn:Button;
	private var centre_btn:Button;
	private var add_btn:Button;
	private var move_btn:Button;
	private var delete_btn:Button;
	
	private var scrollPane_sp:ScrollPane;
	
	private var _poly:Array;
	private var _mode:String;
	
	private var __width:Number;
	private var __height:Number;

	public var onMapLoad:Function;

	/* Getters and Setters */

	public function set poly(poly_str:String):Void {
		_poly = poly_str.split(",");
		
		drawPoly();
		
		drawHandles();
		
		zoomPoly();
	}
	
	public function get poly():String {
		return _poly.join(",");
	}
	
	public function set map(url:String):Void {
		var myListener = new Object();
		myListener.scrollPane_sp = scrollPane_sp;
		myListener.onLoadInit = function (map) {
			scrollPane_sp.invalidate();
			scrollPane_sp.content.background_mc._width = map._width + 20;
			scrollPane_sp.content.background_mc._height = map._height + 20;
		}
		var my_mcl = new MovieClipLoader();
		my_mcl.addListener(myListener);
		
		scrollPane_sp.contentPath = "MapEditor:content";
		var map_mc = scrollPane_sp.content.createEmptyMovieClip("map_mc", 0);
		my_mcl.loadClip(url, map_mc);
		
		var bg_mc = scrollPane_sp.content.background_mc;
		bg_mc.obj = this;
		bg_mc.useHandCursor = false;
		bg_mc.onPress = function () {
			if (this.obj.mode == "addPoints") {
				var content = this.obj.scrollPane_sp.content;
				this.obj.addPoint(content._xmouse, content._ymouse);
			}
		}
	}
	
	public function set mode(mode:String):Void {
		add_btn.selected = move_btn.selected = delete_btn.selected = false;
		switch (mode) {
			case "addPoints":
				add_btn.selected = true;
				break;
			case "movePoints":
				move_btn.selected = true;
				break;
			case "deletePoints":
				delete_btn.selected = true;
				break;			
		}
		_mode = mode;
	}

	public function get mode():String {
		return _mode;
	}
	
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
		if (width != null) __width = width;
		if (height != null) __height = height;
		
		scrollPane_sp._width = __width;
		scrollPane_sp._height = __height - scrollPane_sp._y;
	}
	
	/* Constructor */
	
	function MapEditor() {
		init();
	}
	
	/* Private functions */
	
	private function init():Void {
		__width = _width;
		__height = _height;
		_xscale = 100;
		_yscale = 100;
		setSize(__width, __height);
	}

	private function onLoad():Void {		
		zoomOut_btn.addEventListener("click", Delegate.create(this, zoom));
		zoom100_btn.addEventListener("click", Delegate.create(this, zoom));
		zoomIn_btn.addEventListener("click", Delegate.create(this, zoom));
		
		centre_btn.addEventListener("click", Delegate.create(this, centrePoly));
		
		add_btn.addEventListener("click", Delegate.create(this, changeMode));
		move_btn.addEventListener("click", Delegate.create(this, changeMode));
		delete_btn.addEventListener("click", Delegate.create(this, changeMode));
		
		mode = "movePoints";
	}
	
	private function changeMode(eventObj:Object):Void {
		switch (eventObj.target._name) {
			case "add_btn":
				mode = "addPoints";
				break;
			case "move_btn":
				mode = "movePoints";
				break;
			case "delete_btn":
				mode = "deletePoints";
				break;			
		}
	}
	
	private function zoom(eventObj:Object):Void {
		switch (eventObj.target._name) {
			case "zoomOut_btn":
				scrollPane_sp.content._xscale = scrollPane_sp.content._yscale -= 10;
				break;
			case "zoom100_btn":
				scrollPane_sp.content._xscale = scrollPane_sp.content._yscale = 100;
				break;
			case "zoomIn_btn":
				scrollPane_sp.content._xscale = scrollPane_sp.content._yscale += 10;
				break;
		}
		scrollPane_sp.invalidate();
	}
	
	private function drawPoly():Void {
		var poly_mc:MovieClip = scrollPane_sp.content.createEmptyMovieClip("poly_mc", 10);
	
		var q = 0;
		var len = _poly.length;
		
		var minX = Number(_poly[0]);
		var minY = Number(_poly[1]);
		
		poly_mc.lineStyle(1, 0xFFCC00);
		poly_mc.beginFill(0xFFCC00, 50);
		for (q; q<len; q+=2) {
			if (_poly[q] < minX) minX = Number(_poly[q]);
			if (_poly[q+1] < minY) minY = Number(_poly[q+1]);
			if (q > 0) {
				poly_mc.lineTo(_poly[q], _poly[q+1]);
			} else {
				poly_mc.moveTo(_poly[0], _poly[1]);
			}
		}
		poly_mc.minX = minX;
		poly_mc.minY = minY;
		poly_mc.moveTo(0, 0);
		poly_mc.endFill();
	}
	
	private function drawHandles():Void {
		var points_mc:MovieClip = scrollPane_sp.content.createEmptyMovieClip("points_mc", 5);
		
		for (var q=0; q<_poly.length; q=q+2) {
			var handle_mc = points_mc.attachMovie("handle", "handle_mc", points_mc.getNextHighestDepth());
			handle_mc._x = _poly[q];
			handle_mc._y = _poly[q+1];
			handle_mc.idx = q;
			handle_mc.obj = this;
			
			handle_mc.onPress = function () {
				if (this.obj.mode == "movePoints") {
					var scrollPane_sp = this.obj.scrollPane_sp;
					var bg_mc = scrollPane_sp.content.background_mc;
					
					startDrag(this, true, 2, 2, bg_mc._width - 2, bg_mc._height - 2);
					this.onEnterFrame = function () {
						if (_root._xmouse < scrollPane_sp._x) {
							scrollPane_sp.hPosition -= 10;
							if (scrollPane_sp.hPosition < 10) scrollPane_sp.hPosition = 1;
						}
						if (_root._ymouse < scrollPane_sp._y) {
							scrollPane_sp.vPosition -= 10;
							if (scrollPane_sp.vPosition < 10) scrollPane_sp.vPosition = 1;
						}
						if (_root._xmouse > scrollPane_sp._x + scrollPane_sp.width) {
							scrollPane_sp.hPosition += 10;
							if (scrollPane_sp.hPosition > scrollPane_sp.maxHPosition + 10) scrollPane_sp.hPosition = scrollPane_sp.maxHPosition;
						}
						if (_root._ymouse > scrollPane_sp._y + scrollPane_sp.height) {
							scrollPane_sp.vPosition += 10;
							if (scrollPane_sp.vPosition > scrollPane_sp.maxVPosition + 10) scrollPane_sp.vPosition = scrollPane_sp.maxVPosition;
						}
						this.obj._poly[this.idx] = _x;
						this.obj._poly[this.idx+1] = _y;
						this.obj.drawPoly();
					}
				} else if (this.obj.mode == "deletePoints") {
					this.obj.removePoint(this.idx);
				}
			}
			handle_mc.onRelease = handle_mc.onReleaseOutside = function () {
				if (this.obj.mode == "movePoints") {
					stopDrag();
					this.onEnterFrame();
					delete this.onEnterFrame;				
				}
			}
		}
	}
	
	private function centrePoly():Void {
		var background_mc = scrollPane_sp.content.background_mc;
		var poly_mc = scrollPane_sp.content.poly_mc;
		
		var centerX = poly_mc.minX + (poly_mc._width / 2);
		var centerY = poly_mc.minY + (poly_mc._height / 2);

		scrollPane_sp.hPosition = scrollPane_sp.maxHPosition * (centerX / background_mc._width);
		scrollPane_sp.vPosition = scrollPane_sp.maxVPosition * (centerY / background_mc._height);
	}

	private function zoomPoly():Void {
		var poly_mc = scrollPane_sp.content.poly_mc;
		
		var ratioX:Number = scrollPane_sp.width / poly_mc._width;
		var ratioY:Number = scrollPane_sp.height / poly_mc._height;
		
		if (ratioX < ratioY) {
			// zoom to fit horizontally
			var scaleFactor:Number = ratioX;
		} else {
			// zoom to fit vertically
			var scaleFactor:Number = ratioY;
		}
		
		scrollPane_sp.content._xscale = scrollPane_sp.content._yscale = (scaleFactor * 80);
		scrollPane_sp.invalidate();
		
		var counter = 0;
		onEnterFrame = function () {
			if (counter++ == 2) {
				centrePoly();
				delete onEnterFrame;
			}
		}
	}
	
	private function addPoint(x:Number, y:Number):Void {
		if (_poly.length > 2) {
			var i = 0;
			var len = _poly.length;
			var p1, p2, dist1, dist2, vertDist;
			var smallestDist = Number.POSITIVE_INFINITY;
			var idx = 0;
			for (i; i<len; i+=2) {
				p1 = {x:_poly[i], y:_poly[i+1]};
				if (i < len - 2) {
					p2 = {x:_poly[i+2], y:_poly[i+3]};
				} else {
					p2 = {x:_poly[0], y:_poly[1]};
				}
				dist1 = Math.sqrt(Math.pow(p1.x - x, 2) + Math.pow(p1.y - y, 2));
				dist2 = Math.sqrt(Math.pow(p2.x - x, 2) + Math.pow(p2.y - y, 2));
				
				if (dist1 + dist2 < smallestDist) {
					smallestDist = dist1 + dist2;
					idx = i+2;
				}
			}
			_poly.splice(idx, 0, x, y);
		} else {
			_poly = _poly.concat([x, y]);
		}
		drawHandles();
		drawPoly();
	}
	
	private function removePoint(idx):Void {
		_poly.splice(idx, 2);
		drawHandles();
		drawPoly();
	}
	
	private function draw():Void {}
}