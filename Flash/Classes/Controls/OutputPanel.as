import mx.utils.Delegate;
import mx.core.UIComponent;
class Controls.OutputPanel extends UIComponent {
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	private var mcBoundingBox:MovieClip;
	private var tabControl:MovieClip;
	private var description_ta:MovieClip;
	private var error_ta:MovieClip;
	private var __width:Number;
	private var __height:Number;
	function OutputPanel() {
	}
	public function setSize(inWidth:Number,inHeight:Number):Void{
		__width = inWidth;
		__height = inHeight;
		arrange();
	}
	private function init():Void {
		__width = mcBoundingBox._width;
		__height = mcBoundingBox._height;
		mcBoundingBox._visible = false;
		mcBoundingBox._width = 0;
		mcBoundingBox._height = 0;
	}
	private function draw():Void {
		if(error_ta.text == ""){
			tabControl.dataProvider = [{label:"Help"}];
			tabControl.selectedIndex = 0;
			description_ta._visible = true;
			error_ta._visible = false;
		} else{
			tabControl.dataProvider = [{label:"Help"},{label:"Error"}];
			tabControl.selectedIndex = 1;			
			description_ta._visible = false;
			error_ta._visible = true;			
		}
	}
	private function arrange():Void {
		tabControl.setSize(__width, 22);		
		description_ta.setSize(__width, (__height - tabControl.height));
		error_ta.setSize(__width, (__height - tabControl.height));
	}
	public function setDescription(inText:String){
		if (inText == undefined) {
			inText = "";
		}
		description_ta.text = inText;		
	}
	public function setError(inText:String){
		if (inText == undefined) {
			inText = "";
		}
		error_ta.text = inText;		
	}
	private function tabChange(eventObject) {
		if (tabControl.selectedItem.label == "Help") {
			description_ta._visible = true;
			error_ta._visible = false;
		} else {
			description_ta._visible = false;
			error_ta._visible = true;
		}
	}	
	private function createChildren():Void {
		description_ta = this.createObject("TextArea", "description_ta", 2);
		error_ta = this.createObject("TextArea", "error_ta", 1);
		tabControl = this.createObject("TabBar", "tabControl", 3);
		arrange();
		tabControl.addItem("Help");
		tabControl.addItem("Errors");
		description_ta._x = 0;
		description_ta._y = tabControl.height;
		description_ta.html = true;
		description_ta.
		error_ta._x = 0;
		error_ta._y = tabControl.height;
		error_ta.setStyle("borderStyle","none");
		description_ta.setStyle("borderStyle","none");
		error_ta.editable = false;
		description_ta.editable = false;
		error_ta.wordWrap = true;
		description_ta.wordWrap = true;		
		tabControl.addEventListener("change", Delegate.create(this, tabChange));
	}
}
