import mx.utils.Delegate;
import mx.controls.Button;
import mx.core.UIComponent;
class Controls.SplitPanel extends UIComponent {
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	private var mcBoundingBox:MovieClip;
	private var divider_mc:MovieClip;
	private var firstContents_mc:MovieClip;
	private var secondContents_mc:MovieClip;
	private var ghostDivider_mc:MovieClip;
	private var __width:Number;
	private var __height:Number;	
	function SplitPanel() {
	}
	private function init():Void {
		__width=mcBoundingBox._width-1;
		__height=mcBoundingBox._height-1;
		mcBoundingBox._visible = false;
		mcBoundingBox._width = 0;
		mcBoundingBox._height = 0;
		mx.events.EventDispatcher.initialize(divider_mc);
	}
	private function draw():Void {
	}
	private function arrange():Void {
	}
	private function createChildren():Void {
		ghostDivider_mc._visible = false;
		ghostDivider_mc._alpha = 50;
		firstContents_mc = this.createObject("Button", "firstContents_mc", 1, {label:"1", _x:0,_y:0,_width:200,_height:342});
		secondContents_mc = this.createObject("Button", "secondContents_mc", 0, {label:"2",_x:0,_y:352,_width:200,_height:342});
		divider_mc._x = 0;
		divider_mc._y = 342;
		divider_mc._width = 200;
		divider_mc._height = 10;
		divider_mc.swapDepths(99);
		ghostDivider_mc.swapDepths(100);
		ghostDivider_mc._x = divider_mc._x;
		ghostDivider_mc._y = divider_mc._y;
		ghostDivider_mc._width = divider_mc._width;
		ghostDivider_mc._height = divider_mc._height;
		divider_mc.onPress = Delegate.create(this, function () {
			this.onMouseMove = function() {
				ghostDivider_mc._visible = true;
				var newVal = _ymouse;
				if ((newVal < 584) && (newVal > 100)) {
					ghostDivider_mc._y = newVal;
				}
			};
		});
		divider_mc.onRelease = Delegate.create(this, function () {
			delete this.onMouseMove;
			divider_mc._y = ghostDivider_mc._y;
			ghostDivider_mc._visible = false;
		});
		divider_mc.onReleaseOutside = Delegate.create(this, function () {
			delete this.onMouseMove;
			divider_mc._y = ghostDivider_mc._y;
			firstContents_mc.setSize(__width, divider_mc._y);
			secondContents_mc._y = divider_mc._y+divider_mc._height;
			secondContents_mc.setSize(__width, __height - divider_mc._height - firstContents_mc._height);
			ghostDivider_mc._visible = false;
		});
	}
}
