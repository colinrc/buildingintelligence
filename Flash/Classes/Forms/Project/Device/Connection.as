import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Connection extends Forms.BaseForm {
	private var node:XMLNode;
	private var type_cb:ComboBox;
	private var type_mc:Loader;
	private var details_mc:MovieClip;
	public function Connection() {
	}
	public function init():Void {
		var dataObj = {node:node.firstChild};
		if(node.firstChild.nodeName == "IP"){
			details_mc = type_mc.attachMovie("forms.project.device.ip", "connection_mc", 0, dataObj);
			details_mc.dataObj = dataObj;
			type_cb.selectedIndex = 0;
		}
		else{
			details_mc = type_mc.attachMovie("forms.project.device.serial", "connection_mc", 0, dataObj);
			details_mc.dataObj = dataObj;
			type_cb.selectedIndex = 1;
		}
		type_cb.addEventListener("change", Delegate.create(this, typeChange));
	}
	private function typeChange(evtObj){
		if(type_cb.selectedIndex == 0){
			details_mc = type_mc.attachMovie("forms.project.device.ip", "connection_mc", 0);
		}
		else {
			details_mc = type_mc.attachMovie("forms.project.device.serial", "connection_mc", 0);
		}
	}
	public function getData():Object{
		var parentTag = new XMLNode(1, "CONNECTION");
		var type = type_cb.selectedItem.data;
		var connection = new XMLNode(1, type);
		connection.attributes["ACTIVE"] = "Y";
		var dataObj = details_mc.getData();
		if(type == "IP"){
			connection.attributes["IP_ADDRESS"] = dataObj.address;
			connection.attributes["PORT"] = dataObj.port;
		}
		else{
			connection.attributes["PORT"] = dataObj.port;
			connection.attributes["BAUD"] = dataObj.baud;
			connection.attributes["PARITY"] = dataObj.parity;
			connection.attributes["SUPPORTS_CD"] = dataObj.supportsCd;
			connection.attributes["STOP_BITS"] = dataObj.stopBits;
			connection.attributes["DATA_BITS"] = dataObj.dataBits;
			connection.attributes["FLOW"] = dataObj.flow;
		}
		parentTag.appendChild(connection);
		return parentTag;
	}
}