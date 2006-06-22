import mx.utils.Delegate;
import mx.core.UIComponent;
class Controls.TreeSwitcher extends UIComponent {
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	private var bounds_mc:MovieClip;
	private var tab_tb:MovieClip;
	private var clip1:MovieClip;
	private var clip2:MovieClip;
	private var __width:Number;
	private var __height:Number;
	function TreeSwitcher() {
	}
	public function setSize(inWidth:Number,inHeight:Number):Void{
		__width = inWidth;
		__height = inHeight;
		arrange();
	}
	private function init():Void {
		__width = 244;//bounds_mc._width;
		__height = bounds_mc._height;
		bounds_mc._visible = false;
		bounds_mc._width = 0;
		bounds_mc._height = 0;
	}
	private function draw():Void {
		tab_tb.dataProvider = [{label:"Project"},{label:"Workflow"}];
		tab_tb.selectedIndex = 0;			
		clip1._visible = true;
		clip2._visible = false;			
	}
	private function arrange():Void {
		tab_tb.setSize(__width, 22);		
		clip1.setSize(__width, (__height - tab_tb.height));
		clip2.setSize(__width, (__height - tab_tb.height));
	}
	public function getClip1():MovieClip{
		return clip1;
	}
	public function getClip2():MovieClip{
		return clip2;
	}
	private function tabChange(eventObject) {
		if (tab_tb.selectedItem.label == "Project") {
			clip1._visible = true;
			clip2._visible = false;			
		} else {
			clip1._visible = false;
			clip2._visible = true;			
		}
	}	
	private function createChildren():Void {
		clip1 = this.createObject("Tree", "clip1", 2);
		clip2 = this.createObject("Tree", "clip2", 1);
		
		tab_tb = this.createObject("TabBar", "tab_tb", 3);
		arrange();
		tab_tb.addItem("Project");
		tab_tb.addItem("Workflow");
		clip1.setStyle("borderStyle","none");
		clip2.setStyle("borderStyle","none");
		clip1._x = 0;
		clip1._y = tab_tb.height;
		clip2._x = 0;
		clip2._y = tab_tb.height;
		tab_tb.addEventListener("change", Delegate.create(this, tabChange));
	}
}
