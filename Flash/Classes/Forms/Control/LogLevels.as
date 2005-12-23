import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.LogLevels extends Forms.Control.AdminView {
	private var levels_list:mx.controls.List;
	private var levels_cb:mx.controls.ComboBox;
	private var levels_lb:mx.controls.Label;
	private var devices_lb:mx.controls.Label;
	private var defaults_btn:mx.controls.Button;
	private var levels_dataGrid:mx.controls.DataGrid;
	public var server_socket:XMLSocket;
	public var monitor_socket:XMLSocket;
	public function LogLevels() {
	}
	public function setSockets(inServer_socket:XMLSocket, inMonitor_socket:XMLSocket):Void {
		server_socket = inServer_socket;
		monitor_socket = inServer_socket;
	}
	public function init():Void {
		levels_cb.addEventListener("change", Delegate.create(this, comboSelection));
		defaults_btn.addEventListener("click", Delegate.create(this, setDefault));
		getDebugLevels();
	}
	public function setDefault() {
		for (var index:Number = 0; index<levels_list.length; index++) {
			changeDebugLevels("INFO", levels_list.getItemAt(index).data);
		}
	}
	public function comboSelection(eventObj):Void {
		changeDebugLevels(levels_cb.selectedItem.data, levels_list.selectedItem.data);
	}
	public function generateDebugLevels(inLevels:XMLNode):Void {
		levels_list.removeAll();
		levels_dataGrid.removeAll();
		var inNode:XMLNode = inLevels.firstChild;
		while (inNode != null) {
			levels_list.addItem({label:inNode.attributes["SHORTNAME"], data:inNode.attributes["PACKAGENAME"]});
			levels_dataGrid.addItem({shortname:inNode.attributes["SHORTNAME"], packagename:inNode.attributes["PACKAGENAME"], level:inNode.attributes["LEVEL"]});
			inNode = inNode.nextSibling;
		}
	}
	private function changeDebugLevels(level:String, package:String):Void {
		var xmlMsg = new XML('<DEBUG PACKAGE="'+package+'" LEVEL="'+level+'" />\n');
		server_socket.send(xmlMsg);
		getDebugLevels();
	}
	private function getDebugLevels():Void {
		var xmlMsg = new XML('<DEBUG_PACKAGES />\n');
		server_socket.send(xmlMsg);
	}
	public function processXML(inNode:XMLNode) {
		while (inNode != null) {
			/*if valid node, ignoreWhite isnt working properly*/
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "DEBUG_PACKAGES" :
					generateDebugLevels(inNode);
					break;
				}
			}
			inNode = inNode.nextSibling;
		}
	}
}
