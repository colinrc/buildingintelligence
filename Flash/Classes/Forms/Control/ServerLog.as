import mx.controls.*;
import mx.utils.Delegate;
import TextField.StyleSheet;
class Forms.Control.ServerLog extends Forms.BaseForm {
	private var levels_dg:DataGrid;
	private var defaults_btn:Button;
	private var log_ta:TextArea;
	private var my_styles:StyleSheet;
	private var dataObject:Object;
	private var serverConnection:Object;
	public function ServerLog() {
	}
	public function onLoad():Void {
		//setting the styles for the server log text area
		serverConnection.attachView(this);
		my_styles = new StyleSheet();
		my_styles.setStyle("time", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'10px', color:'#000000', textDecoration:'underline'});
		my_styles.setStyle("error", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#FF0000'});
		log_ta.html = true;
		log_ta.styleSheet = my_styles;
		log_ta.text = "";
		log_ta.text = serverConnection.getOutput();
		defaults_btn.addEventListener("click", Delegate.create(this, setDefault));
		getDebugLevels();		
	}
	public function onUnload():Void{
		serverConnection.detachView();
	}
	private function setDefault() {
		serverConnection.setDefault();
	}
	public function notifyChange():Void{
		log_ta.text = serverConnection.getOutput();
		generateDebugLevels(serverConnection.getLevels());
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
