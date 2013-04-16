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
	private var dataGridHandler:Object;
	public function ServerLog() {
	}
	public function onLoad():Void {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		restrictions.editable = false;
		my_styles = new StyleSheet();
		my_styles.setStyle("time", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'10px', color:'#000000', textDecoration:'underline'});
		my_styles.setStyle("error", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#FF0000'});
		log_ta.html = true;
		log_ta.styleSheet = my_styles;
		log_ta.text = "";
		log_ta.text = serverConnection.getOutput();
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		levels_dg.resizableColumns = false;
		dataGridHandler.setDataGrid(levels_dg);
		dataGridHandler.addTextInputColumn("shortname", "Package", restrictions,false,150);
		dataGridHandler.addLogComboBoxColumn("level", "Level", [{label:"INFO"},{label:"WARNING"},{label:"FINE"},{label:"FINER"},{label:"FINEST"}], Delegate.create(this, comboSelection), 80);
		dataGridHandler.addHiddenColumn("packagename");		
		serverConnection.attachView(this);		
		defaults_btn.addEventListener("click", Delegate.create(this, setDefault));
		generateDebugLevels(serverConnection.getLevels());
	}
	public function onUnload():Void{
		serverConnection.detachView();
	}
	private function setDefault() {
		serverConnection.setDefault();
		generateDebugLevels(serverConnection.getLevels());
	}
	public function notifyChange():Void{
		log_ta.text = serverConnection.getOutput();
	}
	public function	needRefresh():Void{
		generateDebugLevels(serverConnection.getLevels());
	}
	public function comboSelection(package:String,level:String):Void {
		serverConnection.changeDebugLevels(level, package);
	}
	public function generateDebugLevels(inLevels:Array):Void {
		dataGridHandler.setDataGridDataProvider(inLevels);
	}
	private function getDebugLevels():Void {
		serverConnection.getDebugLevels();
	}
}
