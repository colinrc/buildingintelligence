import mx.utils.Delegate;
import mx.controls.Button;
import mx.core.UIComponent;
class Controls.SplitPanel extends UIComponent {
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	private var mcBoundingBox:MovieClip;
	private var divider_mc:MovieClip;
	[Inspectable (defaultValue=101)]
	private var __dividerPosition:Number;	
	private var __firstContents_mc:MovieClip;
	private var __secondContents_mc:MovieClip;	
	private var ghostDivider_mc:MovieClip;
	private var __width:Number;
	private var __height:Number;	
	function SplitPanel() {
	}
	private function init():Void {
		__width=mcBoundingBox._width;
		__height=mcBoundingBox._height;
		mcBoundingBox._visible = false;
		mcBoundingBox._width = 0;
		mcBoundingBox._height = 0;
		mx.events.EventDispatcher.initialize(divider_mc);
	}
	private function draw():Void {
	}
	private function arrange():Void {
		__firstContents_mc._x = 0;
		__firstContents_mc._y = 0;
		__firstContents_mc.setSize(__width, divider_mc._y);				
		__secondContents_mc._x = 0;
		__secondContents_mc._y = divider_mc._y+divider_mc._height;
		__secondContents_mc.setSize(__width, (__height - divider_mc._height - divider_mc._y));		
	}
	public function set dividerPosition(newPosition:Number):Void{
		__dividerPosition = newPosition;
	}
	public function get dividerPosition():Number{
		return __dividerPosition;
	}	
	public function setFirstContents(linkageName:String,instanceName:String,depth:Number,initObject:Object):MovieClip{
		__firstContents_mc = this.createObject(linkageName, instanceName, depth, initObject);
		this.arrange();
		return __firstContents_mc;
	}
	public function setSecondContents(linkageName:String,instanceName:String,depth:Number,initObject:Object):MovieClip{
		__secondContents_mc = this.createObject(linkageName, instanceName, depth, initObject);
		this.arrange();		
		return __secondContents_mc;
	}
	private function createChildren():Void {
		divider_mc = this.createObject("Vdivider","divider_mc",99);
		divider_mc.bg_mc._alpha = 0;
		ghostDivider_mc = this.createObject("Vdivider","ghostDivider_mc",100);
		ghostDivider_mc._visible = false;
		ghostDivider_mc._alpha = 50;
		divider_mc._x = 1;
		if((__dividerPosition != undefined)&&(__dividerPosition > 100)&&(__dividerPosition < (__height-100))){
			divider_mc._y = __dividerPosition;
		} else{
			divider_mc._y = (__height-10)/2;
			__dividerPosition = divider_mc._y;			
		}
		divider_mc._width = __width-3;
		divider_mc._height = 10;
		ghostDivider_mc._x = divider_mc._x;
		ghostDivider_mc._y = divider_mc._y;
		ghostDivider_mc._width = divider_mc._width;
		ghostDivider_mc._height = divider_mc._height;
		divider_mc.onPress = Delegate.create(this, function () {
			this.onMouseMove = function() {
				ghostDivider_mc._visible = true;
				var newVal = _ymouse;
				if ((newVal < (__height-100)) && (newVal > 100)) {
					ghostDivider_mc._y = newVal;
				}
			};
		});
		divider_mc.onRelease = Delegate.create(this, function () {
			delete this.onMouseMove;
			divider_mc._y = ghostDivider_mc._y;
			__dividerPosition = divider_mc._y;			
			ghostDivider_mc._visible = false;			
			this.arrange();
		});
		divider_mc.onReleaseOutside = Delegate.create(this, function () {
			delete this.onMouseMove;
			divider_mc._y = ghostDivider_mc._y;
			__dividerPosition = divider_mc._y;			
			ghostDivider_mc._visible = false;			
			this.arrange();
		});
	}
}
