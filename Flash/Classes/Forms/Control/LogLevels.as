import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.LogLevels {
	private var server:Objects.ServerObj;
	private var levels_list:mx.controls.List;
	private var levels_cb:mx.controls.ComboBox;
	private var levels_lb:mx.controls.Label;
	private var devices_lb:mx.controls.Label;
	private var levels_dataGrid:mx.controls.DataGrid;
	public function LogLevels() {
	}
	public function setSockets(inServer:Objects.ServerObj) {
		server = inServer;
	}
	public function init():Void {
		levels_cb.addEventListener("change", Delegate.create(this, comboSelection));
	}
	public function comboSelection(eventObj) {
			changeDebugLevels(levels_cb.selectedItem.data, levels_list.selectedItem.data);
	}
	public function setVisible(showing:Boolean):Void {
		if (showing == true) {
			getDebugLevels();
		}
		levels_list._visible = showing;
		levels_cb._visible = showing;
		devices_lb._visible = showing;
		levels_lb._visible = showing;
		levels_dataGrid._visible = showing;
	}
	public function generateDebugLevels(inLevels:XMLNode) {
		levels_list.removeAll();
		levels_dataGrid.removeAll();
		var inNode:XMLNode = inLevels.firstChild;
		while (inNode != null) {
			levels_list.addItem({label:inNode.attributes["SHORTNAME"], data:inNode.attributes["PACKAGENAME"]});
			levels_dataGrid.addItem({shortname:inNode.attributes["SHORTNAME"], packagename:inNode.attributes["PACKAGENAME"], level:inNode.attributes["LEVEL"]})
			inNode = inNode.nextSibling;
		}
	}
	private function changeDebugLevels(level:String, package:String) {
		var xmlMsg = new XML('<DEBUG PACKAGE="'+package+'" LEVEL="'+level+'" />\n');
		server.sendToServer(xmlMsg);
		getDebugLevels();
	}
	private function getDebugLevels() {
		var xmlMsg = new XML('<DEBUG_PACKAGES />\n');
		server.sendToServer(xmlMsg);
	}
}
