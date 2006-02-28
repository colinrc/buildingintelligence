import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Connection extends Forms.BaseForm {
	private var node:XMLNode;
	private var type_cb:ComboBox;
	private var details_mc:MovieClip;
	public function Connection() {
	}
	public function onLoad():Void {
		var dataObj = {node:node.firstChild};
		if (node.firstChild.nodeName == "IP") {
			details_mc = this.attachMovie("forms.project.device.ip", "connection_" + random(999) + "mc", 0, dataObj);
			details_mc.dataObj = dataObj;
			type_cb.selectedIndex = 0;
		} else {
			details_mc = this.attachMovie("forms.project.device.serial", "connection_" + random(999) + "mc", 0, dataObj);
			details_mc.dataObj = dataObj;
			type_cb.selectedIndex = 1;
		}
		details_mc._x = 0;
		details_mc._y = 50;
		type_cb.addEventListener("change", Delegate.create(this, typeChange));
	}
	private function typeChange(evtObj) {
		if (type_cb.selectedIndex == 0) {
			details_mc = this.attachMovie("forms.project.device.ip", "connection_" + random(999) + "mc", 0);
		} else {
			details_mc = this.attachMovie("forms.project.device.serial", "connection_" + random(999) + "mc", 0);
		}
		details_mc._x = 0;
		details_mc._y = 50;
	}
	public function getData():Object {
		var parentTag = new XMLNode(1, "CONNECTION");
		var type = type_cb.selectedItem.data;
		var connection = new XMLNode(1, type);
		connection.attributes["ACTIVE"] = "Y";
		var dataObj = details_mc.getData();
		if (type == "IP") {
			if (dataObj.address != "") {
				connection.attributes["IP_ADDRESS"] = dataObj.address;
			}
			if (dataObj.port != "") {
				connection.attributes["PORT"] = dataObj.port;
			}
		} else {
			if (dataObj.port != "") {
				connection.attributes["PORT"] = dataObj.port;
			}
			if (dataObj.baud != "") {
				connection.attributes["BAUD"] = dataObj.baud;
			}
			if (dataObj.parity != "") {
				connection.attributes["PARITY"] = dataObj.parity;
			}
			if (dataObj.supportsCd != "") {
				connection.attributes["SUPPORTS_CD"] = dataObj.supportsCd;
			}
			if (dataObj.stopBits != "") {
				connection.attributes["STOP_BITS"] = dataObj.stopBits;
			}
			if (dataObj.dataBits != "") {
				connection.attributes["DATA_BITS"] = dataObj.dataBits;
			}
			if (dataObj.flow != "") {
				connection.attributes["FLOW"] = dataObj.flow;
			}
		}
		parentTag.appendChild(connection);
		return parentTag;
	}
}
