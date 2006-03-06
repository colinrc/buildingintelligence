import mx.controls.*;
class Forms.Project.Device.Serial extends Forms.BaseForm {
	private var node:XMLNode;
	private var port_ti:TextInput;
	private var supportsCd_chk:CheckBox;
	private var baud_cmb:ComboBox;
	private var parity_cmb:ComboBox;
	private var stopBits_cmb:ComboBox;
	private var dataBits_cmb:ComboBox;
	private var flow_cmb:ComboBox;
	public function Serial() {
	}
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		port_ti.addEventListener("change", changeListener);
		supportsCd_chk.addEventListener("change", changeListener);		
		baud_cmb.addEventListener("change", changeListener);
		parity_cmb.addEventListener("change", changeListener);		
		stopBits_cmb.addEventListener("change", changeListener);
		dataBits_cmb.addEventListener("change", changeListener);
		flow_cmb.addEventListener("change", changeListener);		
		port_ti.text = "";
		if (node.attributes["PORT"] != undefined) {
			port_ti.text = node.attributes["PORT"];
		}
		baud_cmb.selectedIndex = 1;
		if (node.attributes["BAUD"] != undefined) {
			for (var baud:Number = 0; baud < baud_cmb.dataProvider.length; baud++) {
				if (node.attributes["BAUD"] == baud_cmb.dataProvider[baud].label) {
					baud_cmb.selectedIndex = baud;
				}
			}
		}
		parity_cmb.selectedIndex = 0;
		if (node.attributes["PARITY"] != undefined) {
			for (var parity:Number = 0; parity < parity_cmb.dataProvider.length; parity++) {
				if (node.attributes["PARITY"] == parity_cmb.dataProvider[parity].label) {
					parity_cmb.selectedIndex = parity;
				}
			}
		}
		supportsCd_chk.selected = false;
		if (node.attributes["SUPPORTS_CD"] == "Y") {
			supportsCd_chk.selected = true;
		}
		stopBits_cmb.selectedIndex = 1;
		if (node.attributes["STOP_BITS"] != undefined) {
			if (node.attributes["STOP_BITS"] == "0") {
				stopBits_cmb.selectedIndex = 0;
			} else if (node.attributes["STOP_BITS"] == "1") {
				stopBits_cmb.selectedIndex = 1;
			} else if (node.attributes["STOP_BITS"] == "2") {
				stopBits_cmb.selectedIndex = 2;
			}
		}
		dataBits_cmb.selectedIndex = 0;
		if (node.attributes["DATA_BITS"] != undefined) {
			if (node.attributes["DATA_BITS"] == "8") {
				dataBits_cmb.selectedIndex = 0;
			} else {
				dataBits_cmb.selectedIndex = 1;
			}
		}
		flow_cmb.selectedIndex = 0;
		if (node.attributes["FLOW"] != undefined) {
			if (node.attributes["FLOW"] == "NONE") {
				flow_cmb.selectedIndex = 0;
			} else if (node.attributes["FLOW"] == "RTSCTS") {
				flow_cmb.selectedIndex = 1;
			}
		}
	}
	public function getData():Object {
		var dataObj = new Object();
		dataObj.port = port_ti.text;
		dataObj.baud = baud_cmb.selectedItem.label;
		dataObj.parity = parity_cmb.selectedItem.label;
		if (supportsCd_chk.selected) {
			dataObj.supportsCd = "Y";
		} else {
			dataObj.supportsCd = "N";
		}
		dataObj.stopBits = stopBits_cmb.selectedItem.label;
		dataObj.dataBits = dataBits_cmb.selectedItem.label;
		dataObj.flow = flow_cmb.selectedItem.label;
		return dataObj;
	}
}
