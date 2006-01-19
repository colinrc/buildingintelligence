import mx.controls.*;
import mx.utils.Delegate;
import Utils.Base64;
//import Utils.XMLHighlighter;
class Forms.Control.Files extends Forms.Control.AdminView {
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
	public var server_socket:XMLSocket;
	public var monitor_socket:XMLSocket;
	public function Files() {
	}
	public function init():Void {
		upload_btn.addEventListener("click", Delegate.create(this, uploadFile));
		download_btn.addEventListener("click", Delegate.create(this, downloadFile));
		default_btn.addEventListener("click", Delegate.create(this, setDefaultFile));
		files_cb.addEventListener("change", Delegate.create(this, comboChange));
		delete_btn.addEventListener("click", Delegate.create(this, deleteFile));
		files_list.labelFunction = function(item_obj:Object):String  {
			var label_str:String = item_obj.label+' "'+item_obj.desc+'" '+item_obj.mod;
			return label_str;
		};
		requestFiles();
	}
	public function setSockets(inServer_socket:XMLSocket, inMonitor_socket:XMLSocket):Void {
		server_socket = inServer_socket;
		monitor_socket = inMonitor_socket;
	}
	private function comboChange(eventObj:Object):Void {
		if (files_cb.selectedItem.label == "server/config") {
			default_btn.enabled = true;
		} else {
			default_btn.enabled = false;
		}
		requestFiles();
	}
	private function requestFiles():Void {
		files_list.removeAll();
		var xmlMsg = new XML('<ADMIN COMMAND = "LIST" DIR = "'+files_cb.selectedItem.label+'" FILTER = "'+filter_ti.text+'" />\n');
		monitor_socket.send(xmlMsg);
	}
	private function setDefaultFile():Void {
		if ((files_list.selectedIndex>-1) && (confirm_chk.selected)) {
			var xmlMsg = new XML('<ADMIN COMMAND = "SELECT" EXTRA="'+files_list.selectedItem.label+'" />\n');
			monitor_socket.send(xmlMsg);
		}
	}
	private function uploadFile():Void {
		if (confirm_chk.selected) {
			var b64:Base64 = new Base64();
			var xmlMsg = new XML('<ADMIN COMMAND = "UPLOAD" NAME="'+fileName_ti.text+'" DIR="'+files_cb.selectedItem.label+'" BASE64="Y"><![CDATA['+b64.encode(buffer_ta.text)+']]></ADMIN>\n');
			trace(xmlMsg);
			//var xmlMsg = new XML('<ADMIN COMMAND = "UPLOAD" NAME="'+fileName_ti.text+'" DIR="'+files_cb.selectedItem.label+'" BASE64="N"><![CDATA['+buffer_ta.text+']]></ADMIN>\n');
			monitor_socket.send(xmlMsg);
		}
	}
	private function downloadFile():Void {
		if ((files_list.selectedIndex>-1) && (confirm_chk.selected)) {
			var xmlMsg = new XML('<ADMIN COMMAND = "DOWNLOAD" DIR="'+files_cb.selectedItem.label+'" EXTRA="'+files_list.selectedItem.label+'" />\n');
			monitor_socket.send(xmlMsg);
		}
	}
	private function deleteFile():Void {
		if ((files_list.selectedIndex>-1) && (confirm_chk.selected)) {
			var xmlMsg = new XML('<ADMIN COMMAND = "DELETE" DIR="'+files_cb.selectedItem.label+'" EXTRA="'+files_list.selectedItem.label+'" />\n');
			monitor_socket.send(xmlMsg);
		}
	}
	public function filesList(inNode:XMLNode):Void {
		for (var child in inNode.childNodes) {
			files_list.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
		}
	}
	public function fileDownloaded(inNode:XMLNode):Void {
		//fileName_ti.text=inNode.attributes["NAME"];
		if (inNode.attributes["BASE64"] == "N") {
			if (inNode.attributes["NAME"].substring(inNode.attributes["NAME"].length-4, inNode.attributes["NAME"].length).toLowerCase() == ".xml") {
				//buffer_ta.html = true;
				buffer_ta.html = false;
				//buffer_ta.text = XMLHighlighter.highlight(new XML(inNode.firstChild.toString()));
				buffer_ta.text = inNode.firstChild.toString();
			} else {
				buffer_ta.text = inNode.firstChild.toString();
			}
		} else {
			if (inNode.attributes["NAME"].substring(inNode.attributes["NAME"].length-4, inNode.attributes["NAME"].length).toLowerCase() == ".xml") {
				//buffer_ta.html = true;
				buffer_ta.html = false;
				//buffer_ta.text = XMLHighlighter.highlight(new XML(Base64.Decode(inNode.firstChild.toString())));
				var b64:Base64 = new Base64();
				buffer_ta.text = b64.decode(inNode.firstChild.toString());
			} else {
				var b64:Base64 = new Base64();
				buffer_ta.text = b64.decode(inNode.firstChild.toString());
			}
		}
	}
	public function fileUploaded(inNode:XMLNode):Void {
		status_lb.text = "File upload "+inNode.attributes["RESULT"];
		requestFiles();
	}
	public function fileDeleted(inNode:XMLNode):Void {
		status_lb.text = inNode.firstChild.toString();
		requestFiles();
	}
	public function fileSelected(inNode:XMLNode):Void {
		status_lb.text = inNode.firstChild.toString();
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
				case "FILE" :
					fileDownloaded(inNode);
					trace(inNode);
					break;
				case "FILES" :
					filesList(inNode);
					break;
				case "DELETE" :
					fileDeleted(inNode);
					break;
				case "UPLOAD" :
					fileUploaded(inNode);
					break;
				case "SELECT" :
					fileSelected(inNode);
					break;
				}
			}
			inNode = inNode.nextSibling;
		}
	}
}
