import mx.controls.*;
import mx.utils.Delegate;
import TextField.StyleSheet;
class Forms.Control.ServerLog {
	private var debug_ta:mx.controls.TextArea;
	private var tail_ch:mx.controls.CheckBox;
	private var clear_btn:mx.controls.Button;
	private var filter_ti:mx.controls.TextInput;
	private var filter_ch:mx.controls.CheckBox;
	private var inv_filter_ch:mx.controls.CheckBox;
	private var my_styles:StyleSheet;
	function ServerLog() {
	}
	public function init():Void {
		//setting the styles for the server log text area
		my_styles = new StyleSheet();
		my_styles.setStyle("time", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'10px', color:'#000000', textDecoration:'underline'});
		my_styles.setStyle("error", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#FF0000'});
		debug_ta.html = true;
		debug_ta.styleSheet = my_styles;
		debug_ta.text = "";
		clear_btn.addEventListener("click", Delegate.create(this, clearDebugText));
	}
	public function setVisible(showing:Boolean):Void {
		/*cannot use _visible property with CheckBox...*/
		debug_ta._visible = showing;
		tail_ch.visible = showing;
		clear_btn._visible = showing;
		filter_ti._visible = showing;
		filter_ch.visible = showing;
		inv_filter_ch.visible = showing;
	}
	public function clearDebugText() {
		debug_ta.text = "";
	}
	public function appendDebugText(inNode:XMLNode) {
		var logMessage:String;
		debug_ta.text += "<time>Time: "+convertTime(parseInt(inNode.attributes["TIME"]))+"</time>";
		debug_ta.text += inNode.attributes["SRC"]+", "+inNode.attributes["LEVEL"]+", "+inNode.attributes["MSG"]+"\n";
		if (tail_ch.selected) {
			debug_ta.vPosition = debug_ta.maxVPosition;
		}
		/*need to implement filter*/
	}
	function convertTime(inTime):String {
		var time:Date = new Date(inTime);
		return time.getDay()+"-"+time.getMonth()+"-"+time.getFullYear()+" "+time.getHours()+":"+time.getMinutes()+":"+time.getSeconds();
	}
}
