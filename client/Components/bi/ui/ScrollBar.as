class bi.ui.ScrollBar extends bi.ui.CoreUI {
	private var mcBoundingBox:MovieClip;
	private var scrollUp_btn:MovieClip;
	private var scrollTrack_mc:MovieClip;
	private var scrollDown_btn:MovieClip;
	private var scrollThumb_mc:MovieClip;
	
	private var _max:Number = 100;
	private var _min:Number = 0;
	private var _interval:Number;
	private var _scrollPos:Number = 0;
	private var _prevScroll:Number;
	private var _offset:Number;
	private var _buttonSize:Number = 40;

	public function set min(min:Number):Void {
		_min = min;
	}
	
	public function get min():Number {
		return _min;
	}
	
	public function set max(max:Number):Void {
		_max = max;
	}
	
	public function get max():Number {
		return _max;
	}
	
	public function set scrollPosition(scrollPos:Number):Void {
		_scrollPos = scrollPos;
		draw();
	}
	
	public function get scrollPosition():Number {
		var val:Number = (scrollThumb_mc._y - scrollTrack_mc._y) / (scrollTrack_mc._height - scrollThumb_mc._height) * (_max - _min) + _min;
		return Math.round(val);
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
		if (width) __width = width;
		if (height) __height = height;
		draw();
	}

	function ScrollBar() {
		createChildren();
		draw();
	}

	private function init():Void {
	}

	private function createChildren():Void {
		createEmptyMovieClip("scrollTrack_mc", 10);
		
		attachMovie("Button", "scrollUp_btn", 20, {iconName:"up-arrow"});
		scrollUp_btn.width = scrollUp_btn.height = _buttonSize;
		attachMovie("Button", "scrollDown_btn", 30, {iconName:"down-arrow"});
		scrollDown_btn.width = scrollDown_btn.height = _buttonSize;
		
		attachMovie("Icon", "scrollThumb_mc", 40, {iconName:"atom", size:_buttonSize - 4});

		var eventListener:Object = new Object();
		eventListener.onPress = function (eventObj:Object):Void {
			var p = eventObj.target._parent;
			switch (eventObj.target) {
				case p.scrollUp_btn:
					p._interval = setInterval(p, "nudge", 10, -1);
					break;
				case p.scrollDown_btn:
					p._interval = setInterval(p, "nudge", 10, 1);
					break;
			}
		}
		eventListener.onRelease = eventListener.onDragOut = function (eventObj:Object):Void {
			var p = eventObj.target._parent;
			switch (eventObj.target) {
				case p.scrollUp_btn:
					clearInterval(p._interval);
					break;
				case p.scrollDown_btn:
					clearInterval(p._interval);
					break;
			}
		}
		
		scrollUp_btn.addEventListener("onPress", eventListener);
		scrollUp_btn.addEventListener("onRelease", eventListener);
		scrollUp_btn.addEventListener("onDragOut", eventListener);
		scrollDown_btn.addEventListener("onPress", eventListener);
		scrollDown_btn.addEventListener("onRelease", eventListener);
		scrollDown_btn.addEventListener("onDragOut", eventListener);
		
		scrollTrack_mc.onPress = function ():Void {
			this._parent.scroll(this._ymouse);
		}
	}

	private function draw():Void {
		scrollTrack_mc.beginFill(0xFFFFFF, 30);
		scrollTrack_mc.drawRect(0, 0, _buttonSize, __height - (_buttonSize * 2));
		scrollTrack_mc.endFill();
		
		scrollTrack_mc._y = _buttonSize;
		scrollDown_btn._y = scrollTrack_mc._y + scrollTrack_mc._height;
		scrollThumb_mc._x = 2;
		var y:Number = ((_scrollPos - _min)/(_max - _min)) * (scrollDown_btn._y - scrollThumb_mc._height);
		if (y > scrollDown_btn._y - scrollThumb_mc._height) {
			y = scrollDown_btn._y - scrollThumb_mc._height;
		}
		else if (y < scrollTrack_mc._y) {
			y = scrollTrack_mc._y;
		}
		scrollThumb_mc._y = y;
	}
	
	private function scroll(y:Number):Void {
		var percent:Number = y / scrollTrack_mc._height;
		trace(percent)
		scrollThumb_mc._y = scrollTrack_mc._y + ((scrollTrack_mc._height - scrollThumb_mc._height) * percent);
		dispatchScrollEvent();
		updateAfterEvent();
	}
	
	private function nudge(increment:Number):Void {
		var upper:Number = scrollTrack_mc._y;
		var lower:Number = scrollDown_btn._y - scrollThumb_mc._height;
		scrollThumb_mc._y += increment;
		if (scrollThumb_mc._y < upper) {
			scrollThumb_mc._y = upper;
		} else if(scrollThumb_mc._y > lower) {
			scrollThumb_mc._y = lower;
		}
		dispatchScrollEvent();
		updateAfterEvent();
	}
	
	private function dispatchScrollEvent():Void {
		if (scrollThumb_mc._y != _prevScroll) {
			dispatchEvent({type:"scroll", target:this});
			_prevScroll = scrollThumb_mc._y;
		}
	}
}