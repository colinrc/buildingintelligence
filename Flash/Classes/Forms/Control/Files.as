import mx.controls.*;
import mx.utils.Delegate;
import Utils.Base64;

class Forms.Control.Files {
	private var upload_btn:mx.controls.Button;
	private var download_btn:mx.controls.Button;
	private var default_btn:mx.controls.Button;
	private var confirm_chk:mx.controls.CheckBox;
	private var folder_lb:mx.controls.Label;
	private var files_cb:mx.controls.ComboBox;
	private var files_list:mx.controls.List;
	private var fileName_lb:mx.controls.Label;
	private var fileName_ti:mx.controls.TextInput;
	private var buffer_ta:mx.controls.TextArea;
	private var delete_btn:mx.controls.Button;
	private var filter_ti:mx.controls.TextInput;
	private var filter_lb:mx.controls.Label;
	private var status_lb:mx.controls.Label;
	private var server_socket:XMLSocket;
	private var monitor_socket:XMLSocket;
	function Files() {
	}
	function init():Void {
		upload_btn.addEventListener("click", Delegate.create(this, uploadFile));
		download_btn.addEventListener("click", Delegate.create(this, downloadFile));
		default_btn.addEventListener("click", Delegate.create(this, setDefaultFile));
		files_cb.addEventListener("change", Delegate.create(this, comboChange));
		delete_btn.addEventListener("click", Delegate.create(this, deleteFile));
	}
	public function setSockets(inMonitor_socket:XMLSocket, inServer_socket:XMLSocket) {
		server_socket = inServer_socket;
		monitor_socket = inMonitor_socket;
	}
	function comboChange(eventObj:Object):Void {
		if (files_cb.selectedItem.label == "server/config") {
			default_btn.enabled = true;
		} else {
			default_btn.enabled = false;
		}
		requestFiles();
	}
	function requestFiles():Void {
		files_list.removeAll();
		var xmlMsg = new XML('<ADMIN COMMAND = "LIST" DIR = "'+files_cb.selectedItem.label+'" FILTER = "'+filter_ti.text+'" />\n');
		monitor_socket.send(xmlMsg);
	}
	function setDefaultFile():Void {
		if ((files_list.selectedIndex>-1) && (confirm_chk.selected)) {
			var xmlMsg = new XML('<ADMIN COMMAND = "SELECT" EXTRA="'+files_list.selectedItem.label+'" />\n');
			monitor_socket.send(xmlMsg);
		}
	}
	function uploadFile():Void {
		if (confirm_chk.selected) {
			//var xmlMsg = new XML('<ADMIN COMMAND = "UPLOAD" NAME="'+fileName_ti.text+'" DIR="'+files_cb.selectedItem.label+'" BASE64="Y"><![CDATA['+Base64.Encode(buffer_ta.text)+']]></ADMIN>\n');
			var xmlMsg = new XML('<ADMIN COMMAND = "UPLOAD" NAME="'+fileName_ti.text+'" DIR="'+files_cb.selectedItem.label+'" BASE64="N"><![CDATA['+buffer_ta.text+']]></ADMIN>\n');
			monitor_socket.send(xmlMsg);
			trace(xmlMsg);
		}
	}
	function downloadFile():Void {
		if ((files_list.selectedIndex>-1) && (confirm_chk.selected)) {
			var xmlMsg = new XML('<ADMIN COMMAND = "DOWNLOAD" DIR="'+files_cb.selectedItem.label+'" EXTRA="'+files_list.selectedItem.label+'" />\n');
			monitor_socket.send(xmlMsg);
		}
	}
	function deleteFile():Void {
		if ((files_list.selectedIndex>-1) && (confirm_chk.selected)) {
			var xmlMsg = new XML('<ADMIN COMMAND = "DELETE" DIR="'+files_cb.selectedItem.label+'" EXTRA="'+files_list.selectedItem.label+'" />\n');
			monitor_socket.send(xmlMsg);
		}
	}
	function filesList(inNode:XMLNode):Void {
		for (var child in inNode.childNodes) {
			files_list.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
		}
	}
	function fileDownloaded(inNode:XMLNode):Void {
		//buffer_ta.text = inNode.toString();
		fileName_ti.text=inNode.attributes["NAME"];
		if(inNode.attributes["BASE64"] == "N") {
			buffer_ta.text = inNode.firstChild.toString();
		}
		else {
			buffer_ta.text = Base64.Decode(inNode.firstChild.toString());
		}
		//trace(inNode.toString());
	}
	function fileUploaded(inNode:XMLNode):Void {
		status_lb.text = inNode.toString();
		requestFiles();
	}
	function fileDeleted(inNode:XMLNode):Void {
		status_lb.text = inNode.toString();
		requestFiles();
	}
	function fileSelected(inNode:XMLNode):Void {
		status_lb.text = inNode.firstChild.toString();
	}
	function setVisible(showing:Boolean):Void {
		if (showing) {
			requestFiles();
		}
		upload_btn._visible = showing;
		download_btn._visible = showing;
		default_btn._visible = showing;
		confirm_chk._visible = showing;
		folder_lb._visible = showing;
		files_cb._visible = showing;
		files_list._visible = showing;
		fileName_lb._visible = showing;
		fileName_ti._visible = showing;
		buffer_ta._visible = showing;
		delete_btn._visible = showing;
		filter_ti._visible = showing;
		filter_lb._visible = showing;
		status_lb._visible = showing;
	}
	function convertTime(inTime):String {
		return new Date(inTime).toString();
	}
}
