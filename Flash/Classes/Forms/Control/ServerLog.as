import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.ServerLog {
	private var debug_ta:mx.controls.TextArea;
	private var tail_ch:mx.controls.CheckBox;
	private var clear_btn:mx.controls.Button;
	private var filter_ti:mx.controls.TextInput;
	private var filter_ch:mx.controls.CheckBox;
	private var inv_filter_ch:mx.controls.CheckBox;
	private var my_styles:TextField.StyleSheet;
	function ServerLog() {
	}
	public function init():Void {
		//setting the styles for the server log text area
		my_styles.setStyle("time", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'10px', color:'#000000', textDecoration:'underline'});
		my_styles.setStyle("node", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#00AA00'});
		my_styles.setStyle("attribute", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#000000'});
		my_styles.setStyle("command", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#0000FF'});
		my_styles.setStyle("error", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#FF0000'});
		debug_ta.styleSheet = my_styles;
		debug_ta.html = true;
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
	public function appendDebugText(inString:String) {
		if (inString != "") {
			debug_ta.text += inString;
			if (tail_ch.selected) {
				debug_ta.vPosition = debug_ta.maxVPosition;
			}
		}
	}
}
