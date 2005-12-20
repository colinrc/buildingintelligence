import mx.controls.*;
import mx.utils.Delegate;
import TextField.StyleSheet;
class Forms.Control.ServerLog extends Forms.Control.AdminView {
	private var log_ta:mx.controls.TextArea;
	private var tail_ch:mx.controls.CheckBox;
	private var clear_btn:mx.controls.Button;
	private var filter_ti:mx.controls.TextInput;
	private var filter_ch:mx.controls.CheckBox;
	private var inv_filter_ch:mx.controls.CheckBox;
	private var my_styles:StyleSheet;
	public function ServerLog() {
	}
	public function init():Void {
		//setting the styles for the server log text area
		my_styles = new StyleSheet();
		my_styles.setStyle("time", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'10px', color:'#000000', textDecoration:'underline'});
		my_styles.setStyle("error", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#FF0000'});
		log_ta.html = true;
		log_ta.styleSheet = my_styles;
		log_ta.text = "";
		clear_btn.addEventListener("click", Delegate.create(this, clearDebugText));
	}
	public function clearDebugText():Void {
		log_ta.text = "";
	}
	public function appendDebugText(inNode:XMLNode):Void {
		var logMessage:String;
		log_ta.text += "<time>Time: "+convertTime(parseInt(inNode.attributes["TIME"]))+"</time>";
		log_ta.text += inNode.attributes["SRC"]+", "+inNode.attributes["LEVEL"]+", "+inNode.attributes["MSG"]+"\n";
		if (tail_ch.selected) {
			log_ta.vPosition = log_ta.maxVPosition;
		}
		/*need to implement filter*/ 
	}
	private function convertTime(inTime):String {
		var time:Date = new Date(inTime);
		return time.getDay()+"-"+time.getMonth()+"-"+time.getFullYear()+" "+time.getHours()+":"+time.getMinutes()+":"+time.getSeconds();
	}
	public function processXML(inNode:XMLNode):Void {
		while (inNode != null) {
			/*if valid node, ignoreWhite isnt working properly*/
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "ERROR" :
					appendDebugText(inNode);
					//trace(inNode);
					break;
				case "LOG" :
					appendDebugText(inNode);
					//trace(inNode);
					break;
				}
			}
			inNode = inNode.nextSibling;
		}
	}
}
