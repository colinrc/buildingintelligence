import mx.controls.*;
import mx.utils.Delegate;
import TextField.StyleSheet;
class Forms.Control.ServerLog extends Forms.BaseForm {
	private var levels_dg:mx.controls.DataGrid;
	private var defaults_btn:mx.controls.Button;
	private var log_ta:mx.controls.TextArea;
	private var tail_ch:mx.controls.CheckBox;
	private var clear_btn:mx.controls.Button;
	private var filter_ti:mx.controls.TextInput;
	private var filter_ch:mx.controls.CheckBox;
	private var inv_filter_ch:mx.controls.CheckBox;
	private var my_styles:StyleSheet;
	private var serverConnection:Object;
	private var dataObject:Object;
	public function ServerLog() {
	}
	public function onLoad():Void {
		//setting the styles for the server log text area
		my_styles = new StyleSheet();
		my_styles.setStyle("time", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'10px', color:'#000000', textDecoration:'underline'});
		my_styles.setStyle("error", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#FF0000'});
		log_ta.html = true;
		log_ta.styleSheet = my_styles;
		log_ta.text = "";
		clear_btn.addEventListener("click", Delegate.create(this, clearDebugText));
		defaults_btn.addEventListener("click", Delegate.create(this, setDefault));
		getDebugLevels();		
	}
	public function clearDebugText():Void {
		log_ta.text = "";
	}/*
	public function appendDebugText(inNode:XMLNode):Void {
		var logMessage:String;
		log_ta.text += "<time>Time: "+convertTime(parseInt(inNode.attributes["TIME"]))+"</time>";
		log_ta.text += inNode.attributes["SRC"]+", "+inNode.attributes["LEVEL"]+", "+inNode.attributes["MSG"]+"\n";
		if (tail_ch.selected) {
			log_ta.vPosition = log_ta.maxVPosition;
		}
		//need to implement filter
	}*/
	private function convertTime(inTime):String {
		var time:Date = new Date(inTime);
		return time.getDay()+"-"+time.getMonth()+"-"+time.getFullYear()+" "+time.getHours()+":"+time.getMinutes()+":"+time.getSeconds();
	}
	private function setDefault() {
		serverConnection.setDefault();
	}
	public function processXML(inNode:XMLNode):Void {

	}
	/*public function comboSelection(eventObj):Void {
		changeDebugLevels(levels_cb.selectedItem.data, levels_list.selectedItem.data);
	}*/
	public function generateDebugLevels(inLevels:Array):Void {
		levels_dg.removeAll();
		levels_dg.dataProvider = inLevels;
	}
	private function getDebugLevels():Void {
		serverConnection.getLevels();
	}
}
